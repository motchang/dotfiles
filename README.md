#install

	mkdir -p src/github.com/motchang/dotfiles
	rm -f ./.emacs
	git clone https://github.com/motchang/dotfiles.git src/github.com/motchang/dotfiles/
	ln -sf src/github.com/motchang/dotfiles/bashrc ~/.bashrc
	ln -sf src/github.com/motchang/dotfiles/bash_profile ~/.bash_profile
	ln -sf src/github.com/motchang/dotfiles/emacs.d ~/.emacs.d
	ln -sf src/github.com/motchang/dotfiles/tmux.conf ~/.tmux.conf
	ln -sf src/github.com/motchang/dotfiles/gitignore_global ~/.gitignore_global
	ln -sf src/github.com/motchang/dotfiles/zshrc ~/.zshrc
	ln -sf src/github.com/motchang/dotfiles/zshenv ~/.zshenv
	mkdir -p ~/.config/zsh/local
	ln -sf src/github.com/motchang/dotfiles/.config/zsh/local/00-claude-multirepo.zsh ~/.config/zsh/local/00-claude-multirepo.zsh
