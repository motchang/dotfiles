// Local markdown preview server.
//
// Markdown, syntax highlighting, GitHub alerts and the table of contents are
// rendered here in Bun. Mermaid is the one thing that needs a DOM, so its
// fences are passed through as <pre class="mermaid"> and drawn by mermaid.js
// in the browser that displays the page.

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
const MARKDOWN_EXTENSIONS = new Set([".md", ".markdown"]);
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

let currentFile: string | null = null;
let watchers: FSWatcher[] = [];
let watchedState = "";
let reloadTimer: ReturnType<typeof setTimeout> | null = null;
const clients = new Set<ReadableStreamDefaultController<Uint8Array>>();

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

function broadcastReload(): void {
  const payload = new TextEncoder().encode("data: reload\n\n");
  for (const client of clients) {
    try {
      client.enqueue(payload);
    } catch {
      clients.delete(client);
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
function watchFile(file: string): void {
  for (const open of watchers) {
    open.close();
  }
  watchers = [];
  watchedState = fileState(file);
  const names = new Map<string, Set<string>>();
  for (const path of [file, realPath(file)]) {
    const dir = realPath(dirname(path));
    const known = names.get(dir) ?? new Set<string>();
    known.add(basename(path));
    names.set(dir, known);
  }
  for (const [dir, known] of names) {
    watchers.push(
      watch(dir, (_event, changed) => {
        // Fingerprint the path as opened, not the resolved one: statSync follows
        // the link, so one comparison covers both an edit to the real file and a
        // link repointed at a different file.
        const state = fileState(file);
        if (!known.has(changed ?? "") && state === watchedState) {
          return;
        }
        watchedState = state;
        if (reloadTimer) {
          clearTimeout(reloadTimer);
        }
        reloadTimer = setTimeout(broadcastReload, 50);
      }),
    );
  }
}

async function setCurrentFile(rawPath: string): Promise<string> {
  const file = resolve(rawPath);
  if (!MARKDOWN_EXTENSIONS.has(extname(file).toLowerCase())) {
    throw new Error(`not a markdown file: ${file}`);
  }
  if (!(await Bun.file(file).exists())) {
    throw new Error(`no such file: ${file}`);
  }
  currentFile = file;
  watchFile(file);
  return file;
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
    // new EventSource("/events").
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
  toc = "",
): Response {
  return new Response(shell(nonce, title, path, body, toc), {
    headers: {
      "content-type": "text/html; charset=utf-8",
      "content-security-policy": contentSecurityPolicy(nonce),
    },
  });
}

async function renderPage(): Promise<Response> {
  const nonce = newNonce();
  if (!currentFile) {
    return htmlResponse(nonce, "mdpreview", "", "<p>No file selected.</p>");
  }
  let source: string;
  try {
    source = await Bun.file(currentFile).text();
  } catch (error) {
    // An editor or `git checkout` can leave the file missing for a moment. Serve
    // the shell anyway so the page keeps its /events listener and recovers on the
    // next change, instead of turning into Bun's 500 page and going deaf.
    const message = error instanceof Error ? error.message : String(error);
    return htmlResponse(
      nonce,
      basename(currentFile),
      currentFile,
      `<p>${escapeHtml(message)}</p>`,
    );
  }
  // gfmHeadingId's preprocess hook clears the heading list on every parse.
  const body = await marked.parse(source);
  return htmlResponse(nonce, basename(currentFile), currentFile, body, renderToc());
}

function shell(nonce: string, title: string, path: string, body: string, toc = ""): string {
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
  new EventSource("/events").onmessage = () => location.reload();
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
    const { pathname } = new URL(request.url);

    if (!ALLOWED_HOSTS.has(request.headers.get("host") ?? "")) {
      return new Response("forbidden", { status: 403 });
    }

    if (pathname === "/health") {
      return Response.json({ ok: true, file: currentFile });
    }

    if (pathname === "/open" && request.method === "POST") {
      // Only local tooling posts here. A page in a browser always attaches an
      // Origin, so its presence means the request came from somewhere else.
      if (request.headers.get("origin") !== null) {
        return new Response("forbidden", { status: 403 });
      }
      const { path } = (await request.json()) as { path?: string };
      if (!path) {
        return Response.json({ ok: false, error: "missing path" }, { status: 400 });
      }
      try {
        const file = await setCurrentFile(path);
        broadcastReload();
        return Response.json({ ok: true, file });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return Response.json({ ok: false, error: message }, { status: 400 });
      }
    }

    if (pathname === "/events") {
      // cancel() is handed the cancellation reason, not the controller, so hold
      // our own reference to drop the client when the page goes away.
      let client: ReadableStreamDefaultController<Uint8Array> | null = null;
      return new Response(
        new ReadableStream({
          start(controller) {
            client = controller;
            clients.add(controller);
          },
          cancel() {
            if (client) {
              clients.delete(client);
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
      return renderPage();
    }

    return new Response("not found", { status: 404 });
  },
});

const initial = process.argv[2];
if (initial) {
  await setCurrentFile(initial);
}

console.log(`mdpreview-server listening on http://127.0.0.1:${server.port}`);
