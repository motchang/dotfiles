// Local markdown preview server.
//
// Markdown, syntax highlighting, GitHub alerts and the table of contents are
// rendered here in Bun. Mermaid is the one thing that needs a DOM, so its
// fences are passed through as <pre class="mermaid"> and drawn by mermaid.js
// in the browser that displays the page.

import { watch, type FSWatcher } from "node:fs";
import { basename, dirname, extname, resolve } from "node:path";

import hljs from "highlight.js";
import { Marked } from "marked";
import markedAlert from "marked-alert";
import { getHeadingList, gfmHeadingId, resetHeadings } from "marked-gfm-heading-id";

const PORT = Number(process.env.MDPREVIEW_PORT ?? 43128);
const MARKDOWN_EXTENSIONS = new Set([".md", ".markdown"]);

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
let watcher: FSWatcher | null = null;
let reloadTimer: ReturnType<typeof setTimeout> | null = null;
const clients = new Set<ReadableStreamDefaultController<Uint8Array>>();

function escapeHtml(value: string): string {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
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

// Watch the containing directory rather than the file: editors that save by
// writing a temp file and renaming it over the original break a file watch.
function watchFile(file: string): void {
  watcher?.close();
  const name = basename(file);
  watcher = watch(dirname(file), (_event, changed) => {
    if (changed !== name) {
      return;
    }
    if (reloadTimer) {
      clearTimeout(reloadTimer);
    }
    reloadTimer = setTimeout(broadcastReload, 50);
  });
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

async function renderPage(): Promise<Response> {
  if (!currentFile) {
    return new Response(shell("mdpreview", "", "<p>No file selected.</p>"), {
      headers: { "content-type": "text/html; charset=utf-8" },
    });
  }
  const source = await Bun.file(currentFile).text();
  resetHeadings();
  const body = await marked.parse(source);
  return new Response(shell(basename(currentFile), currentFile, body, renderToc()), {
    headers: { "content-type": "text/html; charset=utf-8" },
  });
}

function shell(title: string, path: string, body: string, toc = ""): string {
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
<script src="/assets/mermaid.min.js"></script>
<script>
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

    if (pathname === "/health") {
      return Response.json({ ok: true, file: currentFile });
    }

    if (pathname === "/open" && request.method === "POST") {
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
      return new Response(
        new ReadableStream({
          start(controller) {
            clients.add(controller);
          },
          cancel(controller) {
            clients.delete(controller);
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

console.log(`mdpreview listening on http://127.0.0.1:${server.port}`);
