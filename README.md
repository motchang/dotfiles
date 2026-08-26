# install

Homebrew (https://brew.sh) and mise (https://mise.jdx.dev) come first, from their
own installers rather than from here. zshrc evals both of them unguarded - `brew
shellenv`, and `mise activate` out of `~/.local/bin/mise` where mise's installer
puts it - so linking zshrc before they exist makes every new shell print an
error. Homebrew's installer is also what brings the Xcode command line tools, and
with them the git the clone below needs.

	mkdir -p src/github.com/motchang/dotfiles
	git clone https://github.com/motchang/dotfiles.git src/github.com/motchang/dotfiles/

The Brewfile goes in next, ahead of the shell configs and not merely ahead of
gibo: zshrc hooks direnv unguarded too, and direnv is a formula.

	# A fresh Homebrew leaves brew off this shell's PATH; zshrc does the same eval for later ones.
	eval "$(/opt/homebrew/bin/brew shellenv)"
	brew bundle --file ~/src/github.com/motchang/dotfiles/Brewfile

	ln -sf src/github.com/motchang/dotfiles/zshrc ~/.zshrc
	ln -sf src/github.com/motchang/dotfiles/zshenv ~/.zshenv

	mkdir -p ~/.config/zsh/local
	ln -sf ~/src/github.com/motchang/dotfiles/.config/zsh/local/00-claude-multirepo.zsh ~/.config/zsh/local/00-claude-multirepo.zsh

	ln -sf src/github.com/motchang/dotfiles/bashrc ~/.bashrc
	ln -sf src/github.com/motchang/dotfiles/bash_profile ~/.bash_profile

	ln -sf src/github.com/motchang/dotfiles/tmux.conf ~/.tmux.conf

	mkdir -p ~/.config/git
	gibo dump macOS Emacs JetBrains > ~/.config/git/ignore

	mkdir -p ~/.config/ghostty
	ln -sf ~/src/github.com/motchang/dotfiles/.config/ghostty/config ~/.config/ghostty/config

On macOS Ghostty reads both `~/.config/ghostty/config` and `~/Library/Application
Support/com.mitchellh.ghostty/config`, in that order, so the template it writes
into Application Support the first time it starts shadows every key set here.
Delete it.

	rm -f ~/Library/Application\ Support/com.mitchellh.ghostty/config

	mkdir -p ~/.config/herdr
	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/config.toml ~/.config/herdr/config.toml

	mkdir -p ~/.config/hunk
	ln -sf ~/src/github.com/motchang/dotfiles/.config/hunk/config.toml ~/.config/hunk/config.toml

	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/claude-fork
	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/claude-fresh
	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/hunk-diff
	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/hunk-gh-diff

# herdr-browser

A plugin that embeds Chromium in a pane. Needs a terminal with Kitty graphics
support (Ghostty and the like), Chrome/Chromium, and bun. The
`[experimental] kitty_graphics = true` setting and the `prefix+alt+b` keybinding
are already tracked in config.toml.

	herdr plugin install ogulcancelik/herdr-browser --yes

bun comes from mise, installed at the very top - it is not in the Brewfile.

	mise use -g bun@latest

`mise activate` only puts bun on PATH in an interactive zsh. Put the shim in
~/bin - which zshenv adds to PATH - so the herdr server can find it when it
spawns a plugin pane.

	ln -sfn ~/.local/share/mise/shims/bun ~/bin/bun

The CLI wrapper (`herdr-browser open <url>`, `text`, `selector-click`, `console`
and so on, for driving from Bash in Claude Code):

	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/bin/herdr-browser ~/bin/herdr-browser

# mdpreview

Previews markdown in a herdr-browser pane, or in an ordinary desktop browser
tab. Embedded mermaid renders too, and saving the file reloads the page. Nothing
goes out to the network - mermaid.js and highlight.js are both served locally.

Markdown, syntax highlighting, GitHub alerts and the table of contents are
rendered on the Bun side; only mermaid, which needs a DOM, is drawn in the
browser. `.md`, `.markdown` and `.mdown` all count as markdown.

	cd ~/src/github.com/motchang/dotfiles/.config/herdr/mdpreview-server && bun install

	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/bin/mdpreview ~/bin/mdpreview

Usage (the port is 43128 by default; `MDPREVIEW_PORT` overrides it):

	mdpreview README.md
	mdpreview --browser README.md
	mdpreview --browser     # the same, for the file most recently previewed
	mdpreview text          # any herdr-browser command, aimed at this tab's preview
	mdpreview console
	mdpreview --screen      # the viewer's own errors, as written onto the pane
	mdpreview --reset       # rebuild a pane that has stopped scrolling
	mdpreview --stop        # stop the render server; the pane stays

A herdr-browser pane in the same tab is reused; a tab without one gets a fresh
pane split off to the right, without taking focus. A view in another tab is not a
candidate for reuse - nobody in this tab can see it. Outside herdr (no
HERDR_TAB_ID / HERDR_PANE_ID) there is no tab to scope to and no pane to split
from, so a file argument goes to the desktop browser instead, taking focus with
it - the same tab `--browser` would open, on a path that never asked for one. The
render server has no herdr in it - it is plain HTTP on the loopback port - so the
page is the same one either way.

`--browser` asks for that tab outright, and works inside a herdr session too:
it is how a preview goes to the browser that is already open rather than into a
pane. It needs `open` (macOS) or `xdg-open` (Linux) and refuses outright with
neither - the plainest way this can fail that the pane path has no equivalent
for; an opener that is installed but cannot reach a display (`xdg-open` with no
`DISPLAY`, say) fails later, and reports whatever it has to say for itself. It
also takes focus, unlike a pane: a pane is already on screen in the tab being
looked at, whereas asking for a browser tab is asking to be shown one.

With no file argument it reuses the most recent file any surface was pointed at,
and says so if there is none. `--reset` with no argument comes back to the file
the pane modes last opened instead, which is the one a pane is actually showing.
Either way, handing the file back over broadcasts a reload, so a page already
open on a long document scrolls back to the top.

Previews are independent of each other. Each page carries its own file in its
URL - `/?file=<path>` - so a pane in this tab, a pane in another and any number
of browser tabs each hold a different file, and saving one reloads only the pages
showing that one. `--browser B.md` while a pane shows `A.md` leaves that pane on
`A.md`. Only a bare `/`, which is what a hand-typed URL and a page from before
this gets, follows a file it was not told about - and it follows the one the pane
modes last opened, not the most recent of all: `--browser B.md` leaves a bare-`/`
page on `A.md` too, which is the same distinction `--reset` and `--browser` draw
between them above.

Running `--browser` twice does not stack tabs: the server knows whether a live
page is already showing the file and the second run reloads that instead of
opening another. It knows by counting connected reload streams, which leaves two
windows where a spare tab still appears. One is a tab Chrome has discarded or
frozen in the background, which reads as gone. The other is two runs close
enough together that the first tab has not finished loading and connecting its
stream - the easier of the two to hit, and no heuristic is going to tell that
apart from a tab that never opened. A spare tab is the better failure than
refusing to show a preview that is not on screen. Panes are not counted either;
a pane on the file is no reason to withhold a tab from someone who asked for one.

What a tab still cannot do is be driven. `mdpreview text` and the rest of the
passthrough need a view, so inside a herdr session they report having no preview
in this tab even while a `--browser` tab is open on one.

`?file=` only serves paths that were registered by previewing them. A markdown
file sitting on disk that mdpreview was never pointed at comes back 404, and so
does anything else - the query is not a way to ask this server to read a file.

With two or more browser panes open, herdr-browser cannot pick a target for
itself (409), so which view to aim at has to be named. Working that out is
mdpreview's job: `mdpreview <herdr-browser command>` names this tab's view and
then calls herdr-browser. Nothing on the calling side has to read the pane or
view list. Those commands reach the page over CDP, which gets to a herdr-browser
pane and to nothing else - a desktop tab has no view to attach to - so outside
herdr they say so rather than answering about a Chrome in some other tab.
`--view` (view id) and `--pane` (pane id) are still there for a command that
wants an id in the environment. Outside herdr `--view` still answers with
whatever view the daemon has, since asking for an id by name is asking for that;
what it cannot do is produce one for a `--browser` tab, which has no view id, so
with no pane open anywhere it refuses instead.

The render server lives in `.config/herdr/mdpreview-server` (bun) and logs to
`${TMPDIR}/mdpreview-server.log`. It sits at a different layer from the command
(`bin/mdpreview`), so it carries a `-server` suffix instead of sharing the name.

# Claude Code skills

`~/.claude` is a repository of its own now - motchang/.claude - and the mdpreview
skill moved there with everything else that lives under that directory. Nothing
below `.claude/` is tracked here any more; follow that repository's README to set
the skills up.

# secret guard

Two hooks keep work-machine leftovers out of a public repository: absolute home
paths, credentials that look like tokens, and vocabulary that would name an
employer. Cloning does not switch them on, and neither does anything inside the
repository - the hooks are installed outside it and pointed at by absolute path.

	mkdir -p ~/.config/dotfiles-guard/hooks
	cp .config/dotfiles-guard/hooks/pre-commit \
	   .config/dotfiles-guard/hooks/pre-push \
	   ~/.config/dotfiles-guard/hooks/
	chmod +x ~/.config/dotfiles-guard/hooks/pre-commit \
	         ~/.config/dotfiles-guard/hooks/pre-push
	ln -sf ~/src/github.com/motchang/dotfiles/.config/dotfiles-guard/guard.sh \
	       ~/.config/dotfiles-guard/guard.sh
	git config core.hooksPath "$HOME/.config/dotfiles-guard/hooks"

Write that last path so the shell expands it rather than leaving a `~` for git to
interpret. The expansion lands in `.git/config`, which is not tracked, so the
absolute path it records is never published.

Never use `git config --global core.hooksPath`. A global setting arms the same
hooks in every repository on the machine, including the ones where an absolute
path or an internal project name is entirely legitimate, and ordinary commits
there would start failing.

The stubs are copied rather than linked, and the hooksPath is absolute rather
than relative, because git does not report a hooksPath that is not there - it
skips the hooks and says nothing. A relative in-repo path is therefore armed
only on the branches that carry the directory: check out one that does not and
the guard silently comes off, while `git config core.hooksPath` still answers
as though everything were in place. A symlinked stub fails the same way, since
its target disappears on checkout and an unexecutable hook is skipped just as
quietly. A real file outside the repository survives every branch switch.

They stay tracked here even so, so the code that gates every commit can be
reviewed and versioned like anything else. The cost is that the installed copies
can drift: edit a stub and install it again, or the machine keeps running the
old one. Because the directory sits outside any working tree, several
repositories can share one installation - `~/.claude` will point at this same
guard.

The stubs only locate the body and exec it, so the checks themselves live in
`.config/dotfiles-guard/guard.sh` and are reached through a fixed path. That half
is a symlink on purpose: if it vanishes, the stub notices and refuses the commit
instead of letting it through unchecked.

The structural rules - absolute paths, token shapes, private keys - are in
guard.sh, where they can be read by anyone. The words that would identify an
employer cannot be written down in public, so they stay in a private dotfiles
repository and are linked in beside the body as `patterns`.

	ln -sf <private dotfiles repo>/.config/dotfiles-guard/patterns \
	       ~/.config/dotfiles-guard/patterns

The guard fails closed: with no patterns file it refuses every commit and push
instead of letting them through half-checked. `DOTFILES_GUARD_DIR` overrides
`~/.config/dotfiles-guard` for both halves.
