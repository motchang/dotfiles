// Local markdown preview server.
//
// Markdown, syntax highlighting, GitHub alerts and the table of contents are
// rendered here in Bun. Mermaid is the one thing that needs a DOM, so its
// fences are passed through as <pre class="mermaid"> and drawn by mermaid.js
// in the browser that displays the page.
//
// Which file a page shows is carried in its own URL - /?file=<path> - and not in
// a variable here. That is the whole difference between this and the version
// before it. With one currentFile every surface pointed at this server shared
// it: opening B navigated the pane that was showing A, a herdr pane and a
// desktop tab could not hold different files, and neither could two tabs. The
// path in the query makes each page independent, and the reload channel is keyed
// the same way so that saving a file only wakes the pages actually showing it.
//
// A bare / still renders the last file opened as the current one, so a page from
// before this change, or a URL someone kept, still resolves to something.
//
// Putting the path in the query is also what makes a relative link inside the
// document something this server has to answer for. A browser resolves one
// against the page URL, and that URL is / with the path in the query and no
// directory in it at all, so `design/05-corpus.md` next to docs/design.md is
// asked for as /design/05-corpus.md - a path this server does not serve and
// could not pick a file for if it did. The document's own directory is the
// missing half and it is known here: see previewHref, which rewrites those links
// into ?file= URLs of their own, and previewSrc, which does the same for a
// relative image and points it at the /image route.

import { realpathSync, statSync, watch, type FSWatcher } from "node:fs";
import { basename, dirname, extname, resolve } from "node:path";

import hljs from "highlight.js";
import { Marked } from "marked";
import markedAlert from "marked-alert";
import { getHeadingList, gfmHeadingId } from "marked-gfm-heading-id";

// Coerce with || rather than ??: an exported-but-empty MDPREVIEW_PORT would
// otherwise become Number("") === 0 and make Bun listen on a random port, while
// bin/mdpreview's ${MDPREVIEW_PORT:-43128} still talks to 43128.
const PORT = Number(process.env.MDPREVIEW_PORT) || 43128;
// .mdown is here because bin/mdpreview's own classifier takes it as a markdown
// path. Without it the command advertised a spelling this then refused, and the
// refusal named the file rather than the mismatch that caused it.
const MARKDOWN_EXTENSIONS = new Set([".md", ".markdown", ".mdown"]);
// The image suffixes /image will serve, and what each is served as. A whitelist
// and not a table with a fallback: the content type is what the browser acts on,
// so a suffix with no entry here is a file this has no business deciding about,
// and previewSrc leaves the reference alone rather than guessing. Written with
// `| undefined` because a miss is the point of the table and the index
// signature's optimism would hide it.
const IMAGE_TYPES: Record<string, string | undefined> = {
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".avif": "image/avif",
  ".bmp": "image/bmp",
  ".ico": "image/x-icon",
  ".svg": "image/svg+xml",
};
// The names the page is ever legitimately reached under. A DNS rebinding attack
// resolves the attacker's own hostname to 127.0.0.1, and the Host header is what
// gives that away.
const ALLOWED_HOSTS = new Set([`127.0.0.1:${PORT}`, `localhost:${PORT}`]);

const ASSETS: Record<string, string> = {
  "/assets/github-markdown.css": "github-markdown-css/github-markdown.css",
  "/assets/hljs-light.css": "highlight.js/styles/github.min.css",
  "/assets/hljs-dark.css": "highlight.js/styles/github-dark.min.css",
  "/assets/mermaid.min.js": "mermaid/dist/mermaid.min.js",
};

const marked = new Marked(
  gfmHeadingId(),
  markedAlert(),
  {
    gfm: true,
    breaks: false,
    // Asked for outright, because renderPage depends on parse being synchronous
    // and the dependency is not obvious from the call. See the comment there:
    // the table of contents comes out of a module-level list that the next parse
    // clears, so nothing may yield between the parse and the read, and `await`
    // was that yield. Setting it here rather than passing it per call keeps the
    // renderer and the plugins above from going through an options merge on
    // every render.
    async: false,
    // Rewrites a relative link into this server's URL for the file it names.
    //
    // Done to the token rather than from a link renderer so that marked still
    // builds the anchor: the title, the markup inside the link text and the URL
    // cleaning it does on the way out are all things there is no reason to
    // reimplement in order to change one field.
    walkTokens(token) {
      if (token.type === "link") {
        token.href = previewHref(token.href);
      } else if (token.type === "image") {
        token.href = previewSrc(token.href);
      }
    },
    renderer: {
      code({ text, lang }) {
        const language = (lang ?? "").trim().split(/\s+/)[0] ?? "";
        // Hand mermaid to the browser instead of highlighting it.
        if (language === "mermaid") {
          return `<pre class="mermaid">${escapeHtml(text)}</pre>`;
        }
        if (language && hljs.getLanguage(language)) {
          const { value } = hljs.highlight(text, { language, ignoreIllegals: true });
          return `<pre><code class="hljs language-${escapeHtml(language)}">${value}</code></pre>`;
        }
        return `<pre><code class="hljs">${escapeHtml(text)}</code></pre>`;
      },
    },
  },
);

// Every path /open has accepted, and the only paths ?file= will render.
//
// This is the load-bearing half of putting the path in the URL. Without it the
// query would be an instruction to read and serve any file on the machine to
// whoever asked - and whoever asked includes every page already open in the
// user's browser, which can point an iframe or a window at 127.0.0.1 without
// being able to read the result but perfectly able to make the read happen. The
// markdown-extension check narrows that; it does not close it. Registration
// does: a path arrives here by way of /open, which nothing but local tooling can
// reach - see the Origin refusal there - or as a relative link inside a document
// /open already accepted, which previewHref adds so that following the link
// renders instead of 404ing.
//
// That second route widens the set, and by how much is worth saying plainly. It
// reaches one hop out from a file the user asked to see, and only to a markdown
// file already sitting on disk beside it. So a document can make a path
// renderable by naming it, to a caller that has to know the spelling to ask and
// is a page in a local browser either way. Refusing it would hold the set to
// exactly what /open said, at the price of every relative link in every document
// rendered - which is the thing being protected against being clicked.
//
// It only grows. A preview server is a per-session thing and the set is a
// handful of strings; evicting would mean deciding that a path someone may still
// have a tab on is no longer allowed to render, which is the worse failure.
const registered = new Set<string>();

// Every image a rendered document has pointed at, and what to serve each as.
// The only files /image will hand over.
//
// Kept apart from `registered` rather than folded into it, because the two admit
// different things and answer different routes. A path in here is bytes with a
// content type on them; one in there is read, parsed and rendered as a page.
// Merging the two would make an image reference enough to get a file rendered
// and a markdown link enough to get one served raw.
//
// A map rather than a set so that one lookup answers both questions serveImage
// has - whether this file may be served, and as what - and so that the type is
// decided where the suffix was checked rather than a second time on the way out.
//
// It widens reads the way previewHref does, one hop out from a document already
// registered, with the suffix list deciding what counts, and it grows for the
// same reason that one does.
const images = new Map<string, string>();

// The file a bare / renders, and the file the empty-keyed reload channel
// follows. Only /open with current !== false moves it - see registerFile for why
// --browser deliberately does not.
let lastOpened: string | null = null;
// The most recent /open of any kind, current or not. bin/mdpreview's --browser
// resumes from this: it never sets lastOpened, so without a second field a
// server that had only ever served --browser would report nothing being
// previewed while holding a tab's worth of it.
let lastRegistered: string | null = null;

// One reload channel per path, plus one under the empty key that follows
// whatever lastOpened is. That is where a page reached through a bare / sits,
// since the file behind that URL moves and the URL itself says nothing about
// which file it is.
//
// The watchers belong to the channel rather than to the server, and that is what
// makes them refcounted: a path is watched while at least one page is looking at
// it and not otherwise. Watching every path ever opened would hold an fs watch
// per preview for the life of the process, and a channel with nobody connected
// has nothing to deliver a reload to anyway.
interface Channel {
  // The surface each client declared, so that /viewers can answer for browser
  // tabs without counting herdr panes. Both are Chrome speaking HTTP; nothing
  // about the connection itself tells them apart.
  clients: Map<ReadableStreamDefaultController<Uint8Array>, string>;
  watchers: FSWatcher[];
  watchedState: string;
  reloadTimer: ReturnType<typeof setTimeout> | null;
}
const channels = new Map<string, Channel>();

// Callers drop the result into text nodes and double-quoted attributes, so &#39;
// buys nothing today -- it is there so a future single-quoted attribute cannot
// be broken out of. & stays first or it would re-escape the entities below it.
function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

// The file a channel key stands for. Every key is its own path except the empty
// one, which means "whatever is current" and therefore moves.
function channelPath(key: string): string | null {
  return key === "" ? lastOpened : key;
}

function broadcastReload(key: string): void {
  const channel = channels.get(key);
  if (!channel) {
    return;
  }
  const payload = new TextEncoder().encode("data: reload\n\n");
  for (const client of channel.clients.keys()) {
    try {
      client.enqueue(payload);
    } catch {
      // Only a cancelled stream ever lands here. enqueue on the controller of a
      // stream that has been cancelled throws "Controller is already closed";
      // enqueue on one whose start() threw does not throw at all, so this is not
      // a general reaper and must not be read as one. The guard around watch()
      // in startWatching is what covers that other case.
      channel.clients.delete(client);
    }
  }
  // Dropping the last client here has to close the watch as well. Otherwise the
  // channel outlives the only audience its watchers had and they go on firing
  // into an empty map - which is the state unsubscribe exists to prevent, and it
  // is the only other place that runs this path.
  if (channel.clients.size === 0) {
    stopWatching(channel);
    channels.delete(key);
  }
}

// A stat fingerprint of the watched file. The inode changes when an editor
// renames a freshly written file over the original, and "missing" covers the
// window while the file is gone.
function fileState(file: string): string {
  try {
    const info = statSync(file);
    return `${info.ino}:${info.size}:${info.mtimeMs}`;
  } catch {
    return "missing";
  }
}

// The literal path with every symlink -- the file itself and any parent
// directory -- resolved away. Falls back to the path as given, which is what a
// broken link or a file that vanished mid-save leaves us with.
function realPath(path: string): string {
  try {
    return realpathSync(path);
  } catch {
    return path;
  }
}

function stopWatching(channel: Channel): void {
  for (const open of channel.watchers) {
    open.close();
  }
  channel.watchers = [];
  if (channel.reloadTimer) {
    clearTimeout(channel.reloadTimer);
    channel.reloadTimer = null;
  }
}

// Watch the containing directory rather than the file: editors that save by
// writing a temp file and renaming it over the original break a file watch.
// macOS reports only the source name for that rename, so the watched file's own
// name may never show up in an event. Fall back to comparing the fingerprint,
// which also keeps unrelated saves in the same directory from reloading.
//
// A symlinked target needs the real file's directory watched as well: writes
// land over there and the link's own directory never hears about them, so no
// event arrives and the fingerprint -- which statSync already reads through the
// link -- never gets an occasion to be compared. The link's directory stays
// watched too, so repointing or replacing the link itself still reloads.
// Directories are keyed by their resolved path, so the ordinary case where the
// two differ only in a parent symlink (/tmp vs /private/tmp) collapses back to
// the single watch it has always been.
//
// Per channel rather than per server now, which is what keeps a save to one
// preview's file from reloading another's page. The state and the timer moved
// onto the channel with it for the same reason: two files being edited at once
// would otherwise share one debounce and one fingerprint, and the second event
// would cancel the first file's pending reload.
function startWatching(key: string): void {
  const channel = channels.get(key);
  if (!channel) {
    return;
  }
  stopWatching(channel);
  const file = channelPath(key);
  // The empty-keyed channel before anything has been opened: nothing to watch
  // yet, and retargetCurrent comes back here once there is.
  if (!file) {
    return;
  }
  channel.watchedState = fileState(file);
  const names = new Map<string, Set<string>>();
  for (const path of [file, realPath(file)]) {
    const dir = realPath(dirname(path));
    const known = names.get(dir) ?? new Set<string>();
    known.add(basename(path));
    names.set(dir, known);
  }
  for (const [dir, known] of names) {
    // watch() throws synchronously - ENOENT - when the directory is not there,
    // which is what a preview whose directory has been removed or renamed under
    // it looks like. Letting that escape is what must not happen, and the reason
    // is entirely about where this is called from. startWatching runs inside the
    // ReadableStream start() of /events, a start() that throws propagates out of
    // the constructor without cancel() ever running, and subscribe has already
    // recorded the client by then - so the client stays in the channel with no
    // stream behind it. Nothing reaps it later either: enqueue on a controller
    // whose start() threw does not throw, so broadcastReload's catch never sees
    // it. The channel would then report a phantom tab to /viewers and suppress
    // --browser on that path for as long as the server lived.
    //
    // Giving up on the directory instead leaves the channel with no watchers,
    // which is an inert state that already exists: it is what the empty key
    // produces whenever nothing has been opened yet. The page stays connected
    // and silent until /open comes back for the path - see rearmWatching - and
    // that is also what the version before per-path channels did, only louder.
    // There, watchFile was called from setCurrentFile inside /open's own try, so
    // a missing directory came back as a clean 400 and /events was never part of
    // it. Silence is the closer match to that than a 500 on the reload stream.
    try {
      channel.watchers.push(
        watch(dir, (_event, changed) => {
          // Fingerprint the path as opened, not the resolved one: statSync follows
          // the link, so one comparison covers both an edit to the real file and a
          // link repointed at a different file.
          const state = fileState(file);
          if (!known.has(changed ?? "") && state === channel.watchedState) {
            return;
          }
          channel.watchedState = state;
          if (channel.reloadTimer) {
            clearTimeout(channel.reloadTimer);
          }
          channel.reloadTimer = setTimeout(() => broadcastReload(key), 50);
        }),
      );
    } catch {
      // This directory cannot be watched. Another entry in `names` still might -
      // a symlinked target whose own directory survived, say - so the loop goes
      // on rather than giving up on the file.
    }
  }
}

// Re-arms the watch on a path that has pages connected to it.
//
// This is the recovery route for a channel startWatching gave up on: a preview
// whose directory went away is connected and silent, and comes back the moment
// something registers the path again. /open is the right place to do it from
// because bin/mdpreview re-registers the file on every preview, so the thing
// anyone does when a preview looks dead - run mdpreview again - is already the
// fix, with nothing new to know.
function rearmWatching(key: string): void {
  const channel = channels.get(key);
  if (!channel || channel.clients.size === 0) {
    return;
  }
  startWatching(key);
}

function subscribe(
  key: string,
  surface: string,
  client: ReadableStreamDefaultController<Uint8Array>,
): void {
  let channel = channels.get(key);
  if (!channel) {
    channel = { clients: new Map(), watchers: [], watchedState: "", reloadTimer: null };
    channels.set(key, channel);
  }
  const first = channel.clients.size === 0;
  channel.clients.set(client, surface);
  if (first) {
    startWatching(key);
  }
}

function unsubscribe(key: string, client: ReadableStreamDefaultController<Uint8Array>): void {
  const channel = channels.get(key);
  if (!channel) {
    return;
  }
  channel.clients.delete(client);
  if (channel.clients.size > 0) {
    return;
  }
  // Last one out closes the watch and takes the channel with it. The
  // empty-keyed channel is no exception: recreating it costs a map insert, and
  // leaving it behind would leave an fs watch on a file nobody is showing.
  stopWatching(channel);
  channels.delete(key);
}

// Browser tabs currently showing a path, as distinct from herdr panes.
// bin/mdpreview asks before opening a tab, so that running --browser twice does
// not stack two tabs on the same preview.
//
// Panes are excluded on purpose. A pane already showing the file is not a reason
// to refuse someone who asked for a browser tab, and counting it would make the
// command report a tab that does not exist. Nothing about the connection says
// which is which, so each page declares it in its own /events URL, put there by
// whichever half of bin/mdpreview opened it.
//
// A page only counts while its EventSource is connected, so a background tab
// that Chrome has discarded or frozen reads as absent and a second tab opens.
// That is the failure worth having: the other direction refuses to open a tab
// because of one the user can no longer see.
function tabsShowing(key: string): number {
  const channel = channels.get(key);
  if (!channel) {
    return 0;
  }
  let count = 0;
  for (const surface of channel.clients.values()) {
    if (surface === "tab") {
      count += 1;
    }
  }
  return count;
}

// Points the follow-the-current-file channel at whatever lastOpened has become
// and tells the pages sitting in it to reload: their URL has not changed but the
// file behind it has.
function retargetCurrent(): void {
  if (!channels.has("")) {
    return;
  }
  startWatching("");
  broadcastReload("");
}

// Registers a path and, unless told otherwise, makes it the current one.
//
// The split exists for --browser, and it is not visible from either side alone.
// A browser preview has to be able to open B without disturbing a herdr pane
// showing A. Panes navigate to their own ?file= URL, so lastOpened does not
// reach them - but a page on a bare /, which is any page from before this change
// and any URL a person typed, follows lastOpened and would be dragged onto B.
// Registering without making it current gives --browser exactly what it needs, a
// path that ?file= will serve and a channel to reload, and none of what it does
// not.
async function registerFile(rawPath: string, makeCurrent: boolean): Promise<string> {
  const file = resolve(rawPath);
  if (!MARKDOWN_EXTENSIONS.has(extname(file).toLowerCase())) {
    throw new Error(`not a markdown file: ${file}`);
  }
  if (!(await Bun.file(file).exists())) {
    throw new Error(`no such file: ${file}`);
  }
  registered.add(file);
  lastRegistered = file;
  if (makeCurrent) {
    lastOpened = file;
  }
  return file;
}

// The path a request is asking for, or the sentinel for "whatever is current".
//
// A query naming a path this server was never told about is refused here, before
// anything resolves or reads it, which is the whole point of the registry. The
// refusal is a 404 rather than a 403 so that it says the same thing about a path
// that exists on disk and one that does not.
type Target = { ok: true; key: string; file: string | null } | { ok: false };

function targetFor(url: URL): Target {
  // searchParams has already percent-decoded, which is what bin/mdpreview's
  // @uri encoding on the way out is for: paths hold spaces, & and # as readily
  // as anything else, and an unencoded # would cut the path in half before it
  // ever reached the server.
  const raw = url.searchParams.get("file");
  if (raw === null) {
    return { ok: true, key: "", file: lastOpened };
  }
  const file = resolve(raw);
  if (!registered.has(file)) {
    return { ok: false };
  }
  return { ok: true, key: file, file };
}

// Only two surfaces exist, and an unknown one has to be read as one of them. A
// tab is the safe reading: miscounting a pane as a tab at worst suppresses one
// tab someone asked for, while the reverse stacks tabs on every run.
function surfaceFor(url: URL): string {
  return url.searchParams.get("surface") === "pane" ? "pane" : "tab";
}

// The /events URL for a page, built here rather than in the page's own script so
// that the path never has to be re-derived from location.search by hand.
function eventsUrl(url: URL): string {
  const params = new URLSearchParams();
  const raw = url.searchParams.get("file");
  if (raw !== null) {
    params.set("file", raw);
  }
  params.set("surface", surfaceFor(url));
  return `/events?${params.toString()}`;
}

// A URL that already says where it points: a scheme of its own - http:, mailto:,
// vscode: - or a protocol-relative //host/path. There is nothing in one to
// resolve against a document, so previewHref leaves it as written.
const ABSOLUTE_URL = /^(?:[a-zA-Z][a-zA-Z0-9+.-]*:|\/\/)/;

// The directory that relative links in the document being rendered resolve
// against, and the surface the page reading it declared. Null outside a render.
//
// Module-level for the same reason marked-gfm-heading-id's heading list is:
// marked is built once, up there, and walkTokens is handed a token and nothing
// else. That brings the same rule with it - nothing may yield between setting
// this and the parse that reads it - and renderPage already has to hold exactly
// that invariant for the table of contents. See the comment there.
let linkBase: { dir: string; surface: string } | null = null;

// Whether a path is a file that can be read right now. statSync follows
// symlinks, so a link into a symlinked tree answers for the file at the end of
// it rather than for the link.
function isFile(path: string): boolean {
  try {
    return statSync(path).isFile();
  } catch {
    return false;
  }
}

// The existing file a reference names, with whatever fragment followed it, or
// null when there is no local file in it to find.
//
// Existence is settled here rather than by the callers because it is what makes
// leaving the reference alone the right answer in all of their cases: a target
// never written, a directory, an image someone has yet to add. Rewriting one of
// those would trade a reference the browser reports as broken for a URL of ours
// that renders an error, which is a worse account of the same missing file.
function localTarget(dir: string, reference: string): { file: string; hash: string } | null {
  const raw = reference.trim();
  // An anchor into this same page, and everything already absolute.
  if (raw === "" || raw.startsWith("#") || ABSOLUTE_URL.test(raw)) {
    return null;
  }
  const marker = raw.indexOf("#");
  const path = marker === -1 ? raw : raw.slice(0, marker);
  if (path === "") {
    return null;
  }
  // A reference is a URL, so a space in the file name is written %20 and a # in
  // one is written %23. resolve() would take those literally and look for a file
  // nobody has.
  let target: string;
  try {
    target = decodeURIComponent(path);
  } catch {
    // A lone % that is not an escape. Take the path as it was written rather
    // than dropping the reference over it.
    target = path;
  }
  const file = resolve(dir, target);
  if (!isFile(file)) {
    return null;
  }
  return { file, hash: marker === -1 ? "" : raw.slice(marker) };
}

// The href to put in the page for a link the document wrote, which for a
// relative one is this server's URL for the file it names.
//
// Only markdown is claimed. A link to a PDF, to a directory, to the source file
// next to the document is left exactly as it was written, which is the behaviour
// from before this: it still goes nowhere useful, and it goes nowhere useful in
// the same way it always did.
//
// The surface rides along because the page it opens has to declare one of its
// own: a link followed inside a herdr pane must not leave the new page counting
// itself as a browser tab, or the duplicate-tab check on /viewers starts
// refusing tabs on the strength of a pane.
function previewHref(href: string): string {
  const base = linkBase;
  if (base === null) {
    return href;
  }
  const target = localTarget(base.dir, href);
  if (target === null || !MARKDOWN_EXTENSIONS.has(extname(target.file).toLowerCase())) {
    return href;
  }
  // The link is only worth rewriting if the URL it becomes will be served, and
  // targetFor serves a registered path and nothing else. See the registry above
  // for what this widens.
  registered.add(target.file);
  const params = new URLSearchParams({ file: target.file, surface: base.surface });
  // The fragment as the document wrote it: heading ids on the far side are made
  // by the same gfmHeadingId that made this side's, so an anchor that worked in
  // the source works here.
  return `/?${params.toString()}${target.hash}`;
}

// The src to put in the page for an image the document wrote.
//
// The same problem a relative link had, and not the same fix. There is no page
// to open for an image, only bytes to hand over, so this goes to /image rather
// than to a ?file= URL of its own, and it carries no surface because nothing on
// the other end declares one.
//
// The fragment survives for the one thing that reads one - an SVG addressed by
// view or by element id - and means nothing to the rest, which is why it is
// passed on rather than interpreted.
function previewSrc(src: string): string {
  const base = linkBase;
  if (base === null) {
    return src;
  }
  const target = localTarget(base.dir, src);
  if (target === null) {
    return src;
  }
  const type = IMAGE_TYPES[extname(target.file).toLowerCase()];
  if (type === undefined) {
    return src;
  }
  images.set(target.file, type);
  const params = new URLSearchParams({ file: target.file });
  return `/image?${params.toString()}${target.hash}`;
}

function renderToc(): string {
  const headings = getHeadingList().filter((heading) => heading.level <= 3);
  if (headings.length < 2) {
    return "";
  }
  const items = headings
    .map(
      (heading) =>
        `<li class="toc-l${heading.level}"><a href="#${escapeHtml(heading.id)}">${heading.text}</a></li>`,
    )
    .join("");
  return `<nav class="toc"><div class="toc-title">Contents</div><ul>${items}</ul></nav>`;
}

function newNonce(): string {
  const bytes = new Uint8Array(16);
  crypto.getRandomValues(bytes);
  return btoa(String.fromCharCode(...bytes));
}

// The page's own two scripts carry this request's nonce, and script-src trusts
// nothing else -- no host source, no 'unsafe-inline'. That is what makes the raw
// HTML marked passes through inert: an injected <script> has no nonce, and an
// onerror= attribute cannot be nonced at all, so both are refused.
function contentSecurityPolicy(nonce: string): string {
  return [
    "default-src 'none'",
    `script-src 'nonce-${nonce}'`,
    // The two stylesheet links are 'self'; mermaid injects <style> at runtime.
    "style-src 'self' 'unsafe-inline'",
    // README badges are remote, and github-markdown-css inlines data: SVGs.
    "img-src 'self' data: https:",
    // new EventSource("/events?file=...&surface=...").
    "connect-src 'self'",
    "object-src 'none'",
    "base-uri 'none'",
  ].join("; ");
}

function htmlResponse(
  nonce: string,
  title: string,
  path: string,
  body: string,
  events: string,
  toc = "",
): Response {
  return new Response(shell(nonce, title, path, body, events, toc), {
    headers: {
      "content-type": "text/html; charset=utf-8",
      "content-security-policy": contentSecurityPolicy(nonce),
    },
  });
}

async function renderPage(url: URL): Promise<Response> {
  const nonce = newNonce();
  const target = targetFor(url);
  if (!target.ok) {
    return new Response("not found", { status: 404 });
  }
  const events = eventsUrl(url);
  const file = target.file;
  if (!file) {
    return htmlResponse(nonce, "mdpreview", "", "<p>No file selected.</p>", events);
  }
  let source: string;
  try {
    source = await Bun.file(file).text();
  } catch (error) {
    // An editor or `git checkout` can leave the file missing for a moment. Serve
    // the shell anyway so the page keeps its /events listener and recovers on the
    // next change, instead of turning into Bun's 500 page and going deaf.
    const message = error instanceof Error ? error.message : String(error);
    return htmlResponse(nonce, basename(file), file, `<p>${escapeHtml(message)}</p>`, events);
  }
  // What the relative links in this document resolve against. Set here because
  // this is where the file is known; a token on its own says nothing about which
  // document it came out of.
  linkBase = { dir: dirname(file), surface: surfaceFor(url) };
  // No await between this parse and renderToc, and that is the fix rather than
  // a tidy-up.
  //
  // renderToc reads marked-gfm-heading-id's heading list, which lives at module
  // scope, and gfmHeadingId's preprocess hook clears it at the start of every
  // parse. So a body is only safely paired with its own table of contents while
  // nothing else parses in between - and `await` was exactly that gap. parse is
  // synchronous with this plugin set (hence `async: false` above), so the await
  // bought nothing but a microtask yield, and any other render landing in it left
  // this response holding the other file's headings.
  //
  // It was invisible before per-file URLs, because the server only ever rendered
  // one file and two concurrent renders read the same headings. Rendering
  // different files at once is the entire point of those URLs, so it is not
  // invisible now.
  //
  // Reading the list sooner would not help: the clobber happens during the yield,
  // not after it. Atomicity is the property being bought, and the only way to
  // have it is for there to be no yield at all. renderPage stays async for the
  // file read above, which is a real await and harmless - it is before the parse.
  const body = marked.parse(source);
  linkBase = null;
  // A future plugin that makes parse asynchronous again would otherwise render
  // "[object Promise]" into the page and quietly bring the interleaving back.
  // Better to stop here and say which invariant broke.
  if (typeof body !== "string") {
    throw new Error(
      "marked.parse returned a promise: renderToc can no longer be trusted to " +
        "match the body it is paired with",
    );
  }
  return htmlResponse(nonce, basename(file), file, body, events, renderToc());
}

function shell(
  nonce: string,
  title: string,
  path: string,
  body: string,
  events: string,
  toc = "",
): string {
  // JSON.stringify is what makes this a JS string literal, and on its own it is
  // already enough: `events` comes out of URLSearchParams.toString(), which
  // percent-encodes everything outside [A-Za-z0-9*-._], so a path spelling a
  // closing script tag arrives as %3C%2Fscript%3E and a U+2028 as %E2%80%A8 - no
  // <, quote, backslash or line separator survives to reach it. The extra escape
  // below therefore guards a string that currently cannot contain a <. It is
  // kept as depth, so that building this URL some other way later cannot quietly
  // turn a path into markup.
  const eventsLiteral = JSON.stringify(events).replaceAll("<", "\\u003c");
  return `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escapeHtml(title)}</title>
<link rel="stylesheet" href="/assets/github-markdown.css">
<link rel="stylesheet" href="/assets/hljs-light.css" media="(prefers-color-scheme: light)">
<link rel="stylesheet" href="/assets/hljs-dark.css" media="(prefers-color-scheme: dark)">
<style>
  :root { color-scheme: light dark; }
  body { margin: 0; background: var(--bgColor-default, #fff); }
  .layout { display: flex; gap: 32px; align-items: flex-start;
            max-width: 1280px; margin: 0 auto; padding: 32px; }
  .content { flex: 1 1 auto; min-width: 0; }
  .path { font: 12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace;
          color: var(--fgColor-muted, #59636e); margin-bottom: 8px; }
  .markdown-body { border: 1px solid var(--borderColor-default, #d1d9e0);
                   border-radius: 6px; padding: 32px; }
  .toc { position: sticky; top: 32px; flex: 0 0 240px; font-size: 13px;
         border-left: 1px solid var(--borderColor-default, #d1d9e0); padding-left: 16px; }
  .toc-title { font-weight: 600; margin-bottom: 8px;
               color: var(--fgColor-muted, #59636e); }
  .toc ul { list-style: none; margin: 0; padding: 0; }
  .toc li { margin: 4px 0; }
  .toc a { color: var(--fgColor-default, #1f2328); text-decoration: none; }
  .toc a:hover { text-decoration: underline; }
  .toc-l2 { padding-left: 12px; }
  .toc-l3 { padding-left: 24px; }
  pre.mermaid { background: none; text-align: center; }
  @media (max-width: 900px) { .toc { display: none; } }
</style>
</head>
<body>
<div class="layout">
  <div class="content">
    <div class="path">${escapeHtml(path)}</div>
    <article class="markdown-body">${body}</article>
  </div>
  ${toc}
</div>
<script src="/assets/mermaid.min.js" nonce="${nonce}"></script>
<script nonce="${nonce}">
  const dark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  mermaid.initialize({ startOnLoad: false, theme: dark ? "dark" : "default" });
  mermaid.run({ querySelector: "pre.mermaid" });
  new EventSource(${eventsLiteral}).onmessage = () => location.reload();
</script>
</body>
</html>`;
}

// One image a rendered document pointed at, served as bytes.
//
// Everything deciding whether that is allowed happened at render time: previewSrc
// resolved the reference against the document's own directory, checked the suffix
// and put the path in `images` with the type to serve it as. So the query here is
// not a path to go and read, it is a name to look up in that map, and anything
// else is a 404 for the same reason an unregistered ?file= is - it says the same
// thing about a file that exists and one that does not.
//
// The two security headers are for the one suffix in the list that is also a
// document. An <img src> cannot run script in an SVG, but a URL can be navigated
// to, and an SVG served from this origin would then run as a page here with this
// server's routes reachable from inside it. `default-src 'none'; sandbox` leaves
// it able to draw itself and nothing else, and nosniff keeps the declared type
// from being second-guessed.
//
// no-store because nothing reloads a page when an image under it changes - the
// watch is on the markdown file - so reloading by hand has to be worth
// something. Cached, it would go on showing the old picture.
async function serveImage(url: URL): Promise<Response> {
  const raw = url.searchParams.get("file");
  if (raw === null) {
    return new Response("not found", { status: 404 });
  }
  const file = resolve(raw);
  const type = images.get(file);
  if (type === undefined) {
    return new Response("not found", { status: 404 });
  }
  const body = Bun.file(file);
  if (!(await body.exists())) {
    // Removed or renamed since the page was rendered. The image is broken either
    // way; this only decides whether it breaks as a 404 or as a 500.
    return new Response("not found", { status: 404 });
  }
  return new Response(body, {
    headers: {
      "content-type": type,
      "cache-control": "no-store",
      "x-content-type-options": "nosniff",
      "content-security-policy": "default-src 'none'; sandbox",
    },
  });
}

async function serveAsset(pathname: string): Promise<Response> {
  const relative = ASSETS[pathname];
  if (!relative) {
    return new Response("not found", { status: 404 });
  }
  const file = Bun.file(resolve(import.meta.dir, "node_modules", relative));
  if (!(await file.exists())) {
    return new Response("asset missing - run bun install", { status: 500 });
  }
  return new Response(file, {
    headers: {
      "content-type": pathname.endsWith(".css")
        ? "text/css; charset=utf-8"
        : "text/javascript; charset=utf-8",
    },
  });
}

const server = Bun.serve({
  hostname: "127.0.0.1",
  port: PORT,
  idleTimeout: 0,
  async fetch(request) {
    const url = new URL(request.url);
    const { pathname } = url;

    if (!ALLOWED_HOSTS.has(request.headers.get("host") ?? "")) {
      return new Response("forbidden", { status: 403 });
    }

    if (pathname === "/health") {
      // `file` keeps its old meaning, the file a bare / renders, because an
      // older bin/mdpreview reads exactly that field. `recent` is the addition,
      // and its absence is how a newer script recognises an older server.
      return Response.json({ ok: true, file: lastOpened, recent: lastRegistered });
    }

    if (pathname === "/open" && request.method === "POST") {
      // Only local tooling posts here. A page in a browser always attaches an
      // Origin, so its presence means the request came from somewhere else.
      if (request.headers.get("origin") !== null) {
        return new Response("forbidden", { status: 403 });
      }
      const { path, current } = (await request.json()) as {
        path?: string;
        current?: boolean;
      };
      if (!path) {
        return Response.json({ ok: false, error: "missing path" }, { status: 400 });
      }
      try {
        // Absent means current, so a script from before this change still works.
        const makeCurrent = current !== false;
        const file = await registerFile(path, makeCurrent);
        // Before the reload, not after: a channel whose watch was given up on -
        // its directory had gone - is watching nothing until this runs, and a
        // page told to reload first would come back to a still-dead stream.
        rearmWatching(file);
        // The file's own channel first, then the follow-current one if this
        // moved it. A page in both at once would be an odd thing to arrange and
        // the worst it costs is a second reload of a page that just reloaded.
        broadcastReload(file);
        if (makeCurrent) {
          retargetCurrent();
        }
        return Response.json({ ok: true, file });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return Response.json({ ok: false, error: message }, { status: 400 });
      }
    }

    if (pathname === "/viewers") {
      // Not for pages to call. It answers a question about what the user has
      // open, and no page has a use for the answer - bin/mdpreview is what asks,
      // before deciding whether to open a tab.
      //
      // The check is weaker here than on /open, and worth being honest about.
      // What makes it decisive there is that browsers attach Origin to every
      // cross-origin POST. A cross-origin GET made no-cors does not carry one -
      // an <img src>, an iframe, a stylesheet link - so all this turns away is
      // the fetch and XHR shapes, which same-origin policy already stops from
      // reading the reply. Nothing follows from that on this route: it has no
      // side effect and its body is unreadable cross-origin. The check stays
      // because the route is not meant for pages, not because it is what makes
      // that so.
      if (request.headers.get("origin") !== null) {
        return new Response("forbidden", { status: 403 });
      }
      const target = targetFor(url);
      // An unregistered path has no channel and therefore no viewers. Answering
      // 0 rather than 404 keeps this from doubling as a way to ask which paths
      // are registered.
      const count = target.ok ? tabsShowing(target.key) : 0;
      return Response.json({ ok: true, count });
    }

    if (pathname === "/events") {
      // Reachable from the page, unlike /open and /viewers: this is the one
      // endpoint the preview itself has to call, and an EventSource is how it
      // calls it. So it allows an Origin, which means any page anywhere can
      // subscribe with an <img src="/events?file=..."> if it already knows a
      // registered path's absolute spelling.
      //
      // The registry check covers what that would otherwise be worth - having
      // the server watch a path of the caller's choosing and report when it
      // changed. It does not cover the counting: surfaceFor reads such a client
      // as a tab, so the trick can cost one suppressed --browser tab on a path
      // the caller already knew the name of. That is the whole of it, and it
      // does not earn any machinery.
      const target = targetFor(url);
      if (!target.ok) {
        return new Response("not found", { status: 404 });
      }
      const key = target.key;
      const surface = surfaceFor(url);
      // cancel() is handed the cancellation reason, not the controller, so hold
      // our own reference to drop the client when the page goes away.
      let client: ReadableStreamDefaultController<Uint8Array> | null = null;
      return new Response(
        new ReadableStream({
          start(controller) {
            client = controller;
            subscribe(key, surface, controller);
          },
          cancel() {
            if (client) {
              unsubscribe(key, client);
            }
          },
        }),
        {
          headers: {
            "content-type": "text/event-stream",
            "cache-control": "no-cache",
            connection: "keep-alive",
          },
        },
      );
    }

    if (pathname === "/image") {
      return serveImage(url);
    }

    if (pathname.startsWith("/assets/")) {
      return serveAsset(pathname);
    }

    if (pathname === "/") {
      return renderPage(url);
    }

    return new Response("not found", { status: 404 });
  },
});

const initial = process.argv[2];
if (initial) {
  await registerFile(initial, true);
}

console.log(`mdpreview-server listening on http://127.0.0.1:${server.port}`);
