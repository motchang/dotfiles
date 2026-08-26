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
// does: a path arrives here only by way of /open, which nothing but local
// tooling can reach - see the Origin refusal there.
//
// It only grows. A preview server is a per-session thing and the set is a
// handful of strings; evicting would mean deciding that a path someone may still
// have a tab on is no longer allowed to render, which is the worse failure.
const registered = new Set<string>();

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
      channel.clients.delete(client);
    }
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
  }
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
  // gfmHeadingId's preprocess hook clears the heading list on every parse.
  const body = await marked.parse(source);
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
  // JSON.stringify makes the URL a JS string literal; < is escaped on top of
  // that because JSON.stringify leaves it alone, and a path spelling a closing
  // script tag would otherwise end the block early.
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
      // before deciding whether to open a tab. A same-origin GET carries no
      // Origin, so this turns away a cross-origin caller rather than our own
      // page; the cross-origin one is the caller it is here to turn away.
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
      // calls it. The registry check is what keeps that from being a way to ask
      // the server to watch an arbitrary path and report when it changes.
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
