#install

	mkdir -p src/dotfiles
	rm -f ./.emacs
	git clone https://github.com/motchang/dotfiles.git src/dotfiles/
	ln -sf src/dotfiles/bashrc ~/.bashrc
	ln -sf src/dotfiles/bash_profile ~/.bash_profile
	ln -sf src/dotfiles/emacs.d ~/.emacs.d
	ln -sf src/dotfiles/tmux.conf ~/.tmux.conf
	ln -sf src/dotfiles/gitignore_global ~/.gitignore_global
	ln -sf ~/src/dotfiles/zshrc ~/.zshrc
	ln -sf ~/src/dotfiles/zshenv ~/.zshenv
	ln -sf ~/src/dotfiles/Renviron ~/.Renviron
	ln -sf ~/src/dotfiles/Rprofile ~/.Rprofile
