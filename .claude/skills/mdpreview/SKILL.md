---
name: mdpreview
description: Render a markdown file in a herdr-browser pane - mermaid diagrams, GitHub alerts, syntax highlighting, and a table of contents - with live reload on save. Use when the user asks to preview, render, or visually check a .md file ("プレビュー", "レンダリング結果を見せて", "mermaid が描けているか確認して"), or asks whether a diagram or the structure of a markdown file comes out right. Also use when an open preview pane stops scrolling or ignores the mouse ("スクロールが効かない"), which is a wedged Chrome tab rather than a page problem - `mdpreview --reset` replaces it. Requires a herdr session. Not for reading markdown as text - use Read for that - and not something to do to a markdown file the user has not asked to see.
---

# mdpreview

Previews one markdown file in a Chromium pane embedded in the current herdr tab.
Mermaid renders; the page reloads itself when the file is saved.

## Usage

```sh
mdpreview path/to/file.md
```

That is the whole flow. The command starts the render server on first use,
reuses it afterwards, and settles the pane itself: an existing browser pane in
this tab is reused, and a tab without one gets a fresh pane split off to the
right. Running it twice does not stack up panes, so it is safe to just run it.
After an edit to a file that is already being previewed, do nothing at all: the
page reloads on save.

**Do not work out the state of the preview yourself.** Whether this tab has a
browser pane, which pane it is, which view belongs to it, whether Chrome has
registered that view yet - every mode of `mdpreview` answers all of that
internally, waiting where a wait is needed. Running `herdr pane list`,
`herdr-browser views`, or `jq` over either of them to decide what to do next is
work the script has already done, and it is slower and less correct than the
answer already in the script: a view is registered before it knows its pane, so a
view list read from outside reports "nothing here" for a pane that is perfectly
fine.

`HERDR_BROWSER_VIEW_ID` never needs to be exported, and bare `herdr-browser`
never needs to be called. `mdpreview <anything else>` is `herdr-browser` with
this tab's preview already named:

```sh
mdpreview text                                # rendered text content
mdpreview console                             # page errors
mdpreview screenshot --output /tmp/preview.png
mdpreview eval 'document.title'
```

Any herdr-browser command works this way - the word is passed straight through,
and herdr-browser rejects one it does not have. A first argument ending in `.md`
or containing a `/` is a file to preview instead, so a file whose name looks like
a command needs `./` in front of it.

## Scope

One file at a time. The server tracks a single current file, so previewing a
second file navigates the pane away from the first - it does not open a second
preview beside it.

Preview the file the user is working on or asked about. Do not preview a
markdown file nobody mentioned just because it was read or edited in passing.

## Reading the result back

The rendered page is readable without asking the user to describe it, in one
command each:

```sh
mdpreview README.md && mdpreview text            # preview, then read it back
mdpreview screenshot --output /tmp/preview.png   # then Read the png
```

Reach for `mdpreview console` when a mermaid block renders as an error box -
mermaid parses in the browser, so its diagnostics only surface there.

`mdpreview --view` still prints the view id for a command that needs it in the
environment, and `mdpreview --pane` prints this tab's pane ids. Neither is needed
for the commands above.

## When the pane stops responding to the mouse

Chrome sometimes stops acknowledging pointer input while everything else about
the page stays healthy. The wheel scrolls nothing, and the pane fills up with

```
mouse move failed: timed out waiting for CDP Input.dispatchMouseEvent
```

which the viewer writes straight onto the page, so it surfaces on the next
redraw - pressing the herdr prefix is usually what reveals it. `herdr-browser
status` still answers, `text` still returns the document, and a reload does not
clear it: the wedge belongs to the Chrome tab, not to the document.

```sh
mdpreview --reset
```

Run it from the tab whose preview is stuck - like everything else here it is
tab-scoped, so from another tab it just opens a second preview somewhere the
stuck one is not. It replaces this tab's preview pane with a fresh one on the
same file, then dispatches a zero-delta wheel to check that pointer input
answers before reporting. If a new pane is not enough it restarts the browser
daemon and tries once more, which also covers a Chrome that has stopped
answering altogether.

`mdpreview --reset path/to/other.md` resets onto a different file instead.

The daemon restart is the second stage only, and it is session-wide: every other
herdr-browser pane in the session drops to "session ended" until reopened. It
says so on stderr when it gets that far, so a reset that reports
`reset ok - new preview pane` disturbed nothing else.

Do not reset a preview the user has not complained about and that reads back
fine - `mdpreview text` working is not evidence that scrolling does.

## Reading the pane's own errors

The viewer reports its failures by writing them onto the pane and nowhere else -
there is no log file. They are still readable without asking the user what the
pane says:

```sh
mdpreview --screen
```

That is the pane's visible screen: the toolbar line, and under it whatever the
viewer has written over the page. It is the counterpart to `mdpreview console`,
which reports the page's errors rather than the viewer's.

## Shutting down

```sh
mdpreview --stop        # stops the render server; the pane stays
```

Closing the preview pane is the user's call - leave it alone unless asked.
`--reset` is the exception: replacing the pane is the whole point of it.

## When it fails

- `dependencies missing - run 'bun install' in ...` - the render server's
  node_modules are absent. Run `bun install` in that directory.
- `could not read the herdr-browser view list` - `herdr-browser` is not on PATH,
  or the plugin is not installed
  (`herdr plugin install ogulcancelik/herdr-browser`).
- `could not read the herdr pane list` - `herdr` itself is the problem, not the
  browser plugin. Nothing was previewed; the pane is untouched.
- `the herdr-browser pane in this tab has not registered a view` - a browser pane
  is there but its Chrome never came up. `mdpreview --reset` replaces the pane
  and, failing that, the daemon behind it.
- `nothing is being previewed` - `--reset` with no file argument restores what the
  render server currently holds, and the server is not up. Name the file:
  `mdpreview --reset path/to/file.md`.
- `reset failed - pointer input still times out` - a new pane and a new daemon
  both came up and neither took pointer input, so this is not the usual wedge.
  The page itself still renders and reads back; report that rather than resetting
  again in a loop.
- Outside a herdr pane (no `HERDR_TAB_ID`/`HERDR_PANE_ID`) there is no tab to
  scope to: any existing view is reused, and a new pane is split off whichever
  pane has focus - possibly in a tab the caller cannot see. Previewing from a
  plain terminal is not useful.
- The port is 43128 by default; `MDPREVIEW_PORT` overrides it. Note that a
  second port means a second server, not a second visible pane.
