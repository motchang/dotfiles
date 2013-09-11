#install

	mkdir -p src/dotfiles
	rm -f ./.emacs
	git clone https://github.com/motchang/dotfiles.git src/dotfiles/
	ln -sf src/dotfiles/bashrc ~/.bashrc
	ln -sf src/dotfiles/bash_profile ~/.bash_profile
	ln -sf src/dotfiles/emacs.d ~/.emacs.d
	ln -sf src/dotfiles/tmux.conf ~/.tmux.conf
