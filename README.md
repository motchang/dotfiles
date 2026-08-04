# install

	mkdir -p src/github.com/motchang/dotfiles
	git clone https://github.com/motchang/dotfiles.git src/github.com/motchang/dotfiles/

	ln -sf src/github.com/motchang/dotfiles/bashrc ~/.bashrc
	ln -sf src/github.com/motchang/dotfiles/bash_profile ~/.bash_profile

	ln -sf src/github.com/motchang/dotfiles/tmux.conf ~/.tmux.conf

	mkdir -p ~/.config/git
	gibo dump macOS Emacs JetBrains > ~/.config/git/ignore

	ln -sf src/github.com/motchang/dotfiles/zshrc ~/.zshrc
	ln -sf src/github.com/motchang/dotfiles/zshenv ~/.zshenv

	mkdir -p ~/.config/zsh/local
	ln -sf ~/src/github.com/motchang/dotfiles/.config/zsh/local/00-claude-multirepo.zsh ~/.config/zsh/local/00-claude-multirepo.zsh

	mkdir -p ~/.config/herdr
	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/config.toml ~/.config/herdr/config.toml

	mkdir -p ~/.config/hunk
	ln -sf ~/src/github.com/motchang/dotfiles/.config/hunk/config.toml ~/.config/hunk/config.toml

	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/claude-fork
	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/hunk-diff
	herdr plugin link ~/src/github.com/motchang/dotfiles/.config/herdr/plugins/hunk-gh-diff

# herdr-browser

Chromium をペインに埋め込むプラグイン。Kitty graphics 対応ターミナル (Ghostty など)、
Chrome/Chromium、bun が必要。config.toml の `[experimental] kitty_graphics = true`
と `prefix+alt+b` のキーバインドは追跡済み。

	herdr plugin install ogulcancelik/herdr-browser --yes

	mise use -g bun@latest

bun は `mise activate` 経由なので対話 zsh にしか PATH が通らない。herdr サーバーが
プラグインペインを spawn するときに見つけられるよう、シムを ~/bin (zshenv で PATH に
入る) に置く。

	ln -sfn ~/.local/share/mise/shims/bun ~/bin/bun

CLI ラッパー (`herdr-browser open <url>`, `text`, `selector-click`, `console` など。
Claude Code から Bash で叩く用):

	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/bin/herdr-browser ~/bin/herdr-browser

# mdpreview

Markdown を herdr-browser のペインでプレビューする。埋め込み mermaid も描画され、
ファイルを保存すると自動でリロードされる。ネットワークには出ない (mermaid.js も
highlight.js もローカル配信)。

markdown・シンタックスハイライト・GitHub alerts・目次は Bun 側でレンダリングし、
DOM を必要とする mermaid だけをブラウザ側で描画する。

	cd ~/src/github.com/motchang/dotfiles/.config/herdr/mdpreview && bun install

	ln -sf ~/src/github.com/motchang/dotfiles/.config/herdr/bin/mdpreview ~/bin/mdpreview

使い方 (ポートは MDPREVIEW_PORT で変更可、既定 43128):

	mdpreview README.md
	mdpreview --stop
