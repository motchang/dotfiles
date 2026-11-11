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

# terminal-browser

A browser that runs inside a terminal pane (zenbu-labs/terminal-browser). It
replaces herdr-browser, which is deprecated in its favour. It draws with Kitty
graphics, so it needs a terminal that supports them (Ghostty and the like); the
browser itself ships with it, so no Chrome is needed.

	curl -fsSL https://terminal-browser.sh/install -o install.sh
	bash install.sh

That puts the command in ~/.local/bin, which zshrc puts on PATH. Its `setup`
symlinks its agent skill into ~/.claude/skills and ~/.agents/skills; ~/.claude
is a repository of its own (see below), so the link shows up there rather than
here.

	terminal-browser setup

Under herdr, terminal-browser switches `[experimental] kitty_graphics` on in
herdr's config.toml the first time it opens if it finds it off. That file is
the tracked one here, through the symlink above, and it already has the setting
on, so nothing gets rewritten. The `prefix+alt+b` keybinding, which opens one in
a split to the right, is tracked in config.toml as well.

`terminal-browser action -- <command>` drives an open tab from Bash in Claude
Code (snapshot, click, eval and so on). For a markdown preview, `blueline --
<command>` does the same with the preview's tab already named.

A machine that had herdr-browser has a stale ~/bin/herdr-browser symlink into
this repository, which no longer has the wrapper. Remove it, and the plugin with
it.

	command rm -f ~/bin/herdr-browser
	herdr plugin uninstall official.browser

# blueline

Markdown previews come from `blueline`, which lives in its own repository now -
motchang/bluelines. It is a single binary: a file opens in a desktop browser tab,
`--term` puts it in a terminal-browser pane in this herdr tab, and `blueline --
<command>` drives that pane's page. Its README has the install options and the
full usage; nothing for it is tracked here.

The quickest install needs only Rust, from mise or rustup; `cargo install` puts
the binary in ~/.cargo/bin, which zshenv puts on PATH for every shell, agent
Bash included.

	cargo install --locked --git https://github.com/motchang/bluelines

The GitHub Releases of motchang/bluelines have prebuilt binaries too, for a
machine without Rust: put `blueline` from the archive somewhere on PATH, ~/bin
for one.

A machine that had mdpreview from this repository has a ~/bin/mdpreview symlink
into this checkout, and may still have its bun render server running on 43128,
the port blueline uses too - blueline does not recognise that server and would
leave stale pages on it. Before pulling the removal, stop the server and drop the
link:

	mdpreview --stop
	command rm -f ~/bin/mdpreview

Already pulled, the script is gone: stop the server by hand instead (`lsof -ti
tcp:43128` names it) and remove the link the same way. `MDPREVIEW_PORT` is not
read any more; set `BLUELINE_PORT` if you had changed it. The ~/bin/bun shim the
old steps made can go as well, if nothing else uses bun.

# Claude Code skills

`~/.claude` is a repository of its own now - motchang/.claude - and the markdown
preview skill moved there with everything else that lives under that directory. Nothing
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
