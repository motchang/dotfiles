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

Previews markdown in a herdr-browser pane. Embedded mermaid renders too, and
saving the file reloads the page. Nothing goes out to the network - mermaid.js
and highlight.js are both served locally.

Markdown, syntax highlighting, GitHub alerts and the table of contents are
rendered on the Bun side; only mermaid, which needs a DOM, is drawn in the
browser.

	cd ~/src/github.com/motchang/dotfiles/.config/herdr/mdpreview-server && bun install

	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/bin/mdpreview ~/bin/mdpreview

Usage (the port is 43128 by default; `MDPREVIEW_PORT` overrides it):

	mdpreview README.md
	mdpreview text          # any herdr-browser command, aimed at this tab's preview
	mdpreview console
	mdpreview --screen      # the viewer's own errors, as written onto the pane
	mdpreview --reset       # rebuild a pane that has stopped scrolling
	mdpreview --stop        # stop the render server; the pane stays

A herdr-browser pane in the same tab is reused; a tab without one gets a fresh
pane split off to the right, without taking focus. A view in another tab is not a
candidate for reuse - nobody in this tab can see it. Outside herdr (no
HERDR_TAB_ID / HERDR_PANE_ID) there is no tab to scope to, so any existing view
is used and, failing that, the focused pane is split.

With two or more browser panes open, herdr-browser cannot pick a target for
itself (409), so which view to aim at has to be named. Working that out is
mdpreview's job: `mdpreview <herdr-browser command>` names this tab's view and
then calls herdr-browser. Nothing on the calling side has to read the pane or
view list. `--view` (view id) and `--pane` (pane id) are still there for a
command that wants an id in the environment.

The render server lives in `.config/herdr/mdpreview-server` (bun) and logs to
`${TMPDIR}/mdpreview-server.log`. It sits at a different layer from the command
(`bin/mdpreview`), so it carries a `-server` suffix instead of sharing the name.

# Claude Code skills

`~/.claude` is a repository of its own now - motchang/.claude - and the mdpreview
skill moved there with everything else that lives under that directory. Nothing
below `.claude/` is tracked here any more; follow that repository's README to set
the skills up.

# secret guard

`.githooks/pre-commit` and `.githooks/pre-push` keep work-machine leftovers out of
a public repository: absolute home paths, credentials that look like tokens, and
vocabulary that would name an employer. Cloning does not switch them on - git
only reads `.githooks` once this repository is pointed at it, and only this
repository.

	git config core.hooksPath .githooks

Never do that with `git config --global core.hooksPath`. A global setting arms
the same hooks in every repository on the machine, including the ones where an
absolute path or an internal project name is entirely legitimate, and ordinary
commits there would start failing.

The two hooks are stubs. The checks live in `.config/dotfiles-guard/guard.sh` and
are reached through a fixed path outside the repository, so a checkout that has
the stubs but not the body fails loudly rather than committing unchecked - which
is what pointing core.hooksPath straight at a missing directory would do.

	mkdir -p ~/.config/dotfiles-guard
	ln -sf ~/src/github.com/motchang/dotfiles/.config/dotfiles-guard/guard.sh \
	       ~/.config/dotfiles-guard/guard.sh

The structural rules - absolute paths, token shapes, private keys - are in
guard.sh, where they can be read by anyone. The words that would identify an
employer cannot be written down in public, so they stay in a private dotfiles
repository and are linked in beside the body as `patterns`.

	ln -sf <private dotfiles repo>/.config/dotfiles-guard/patterns \
	       ~/.config/dotfiles-guard/patterns

The guard fails closed: with no patterns file it refuses every commit and push
instead of letting them through half-checked. `DOTFILES_GUARD_DIR` overrides
`~/.config/dotfiles-guard` for both halves.
