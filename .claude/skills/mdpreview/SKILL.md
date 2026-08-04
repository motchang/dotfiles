---
name: mdpreview
description: Render a markdown file in a herdr-browser pane - mermaid diagrams, GitHub alerts, syntax highlighting, and a table of contents - with live reload on save. Use when the user asks to preview, render, or visually check a .md file ("プレビュー", "レンダリング結果を見せて", "mermaid が描けているか確認して"), or asks whether a diagram or the structure of a markdown file comes out right. Requires a herdr session. Not for reading markdown as text - use Read for that - and not something to do to a markdown file the user has not asked to see.
---

# mdpreview

Previews one markdown file in a Chromium pane embedded in the current herdr tab.
Mermaid renders; the page reloads itself when the file is saved.

## Usage

```sh
mdpreview path/to/file.md
```

That is the whole flow. The command starts the render server on first use,
reuses it afterwards, and settles the pane itself.

- **A herdr-browser pane already in this tab** is reused - the preview replaces
  whatever it was showing.
- **No browser pane in this tab** (including one that only exists in another
  tab, which nobody here can see) gets a fresh pane split off to the right.

Running it twice in a row does not stack up panes, so it is safe to just run it.
After an edit to a file that is already being previewed, do nothing at all: the
page reloads on save.

## Scope

One file at a time. The server tracks a single current file, so previewing a
second file navigates the pane away from the first - it does not open a second
preview beside it.

Preview the file the user is working on or asked about. Do not preview a
markdown file nobody mentioned just because it was read or edited in passing.

## Reading the result back

The rendered page is readable without asking the user to describe it. Name the
view first: `herdr-browser` refuses to choose for itself as soon as a second
browser pane is open anywhere in the session, and its choice is not tab-aware
even when it does choose.

```sh
export HERDR_BROWSER_VIEW_ID=$(mdpreview --view)
herdr-browser text                                  # rendered text content
herdr-browser console                               # page errors, e.g. mermaid parse failures
herdr-browser screenshot --output /tmp/preview.png  # then Read the png
```

Reach for `console` when a mermaid block renders as an error box - mermaid parses
in the browser, so its diagnostics only surface there.

## Shutting down

```sh
mdpreview --stop        # stops the render server; the pane stays
```

Closing the preview pane is the user's call - leave it alone unless asked.

## When it fails

- `dependencies missing - run 'bun install' in ...` - the render server's
  node_modules are absent. Run `bun install` in that directory.
- `could not read the herdr-browser view list` - `herdr-browser` is not on PATH,
  or the plugin is not installed
  (`herdr plugin install ogulcancelik/herdr-browser`).
- `could not read the herdr pane list` - `herdr` itself is the problem, not the
  browser plugin. Nothing was previewed; the pane is untouched.
- `the herdr-browser pane in this tab has not registered a view` - a browser pane
  is there but its Chrome never came up. Check `herdr-browser status`.
- Outside a herdr pane (no `HERDR_TAB_ID`/`HERDR_PANE_ID`) there is no tab to
  scope to: any existing view is reused, and a new pane is split off whichever
  pane has focus - possibly in a tab the caller cannot see. Previewing from a
  plain terminal is not useful.
- The port is 43128 by default; `MDPREVIEW_PORT` overrides it. Note that a
  second port means a second server, not a second visible pane.
