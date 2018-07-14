;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
;;; Code:
(package-initialize)

(setq debug-on-error nil)
;; install cask
;;   `curl -fsSkL https://raw.github.com/cask/cask/master/go | python`
;; on mac
;;   `brew install cask`

;; `cask upgrade`

(require 'cask "cask.el")
(cask-initialize)

(require 'init-loader)
(setq init-loader-show-log-after-init "error-only")
(init-loader-load "~/.emacs.d/conf/lisp")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(custom-safe-themes
   (quote
    ("e80932ca56b0f109f8545576531d3fc79487ca35a9a9693b62bf30d6d08c9aaf" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "211bb9b24001d066a646809727efb9c9a2665c270c753aa125bace5e899cb523" default)))
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(helm-boring-file-regexp-list (quote ("~$")))
 '(helm-buffer-max-length 35)
 '(helm-delete-minibuffer-contents-from-point t)
 '(helm-ff-skip-boring-files t)
 '(helm-ls-git-show-abs-or-relative (quote relative))
 '(helm-mini-default-sources
   (quote
    (helm-source-buffers-list helm-source-recentf helm-source-buffer-not-found)))
 '(helm-truncate-lines t t)
 '(package-selected-packages
   (quote
    (yasnippet-snippets yaml-mode web-mode use-package twittering-mode tide terraform-mode sws-mode string-inflection smex smarty-mode smartparens slim-mode slack shader-mode scss-mode sass-mode ruby-end ruby-block rspec-mode robe rinari rainbow-mode projectile prodigy popwin php-mode pallet omnisharp nyan-mode nodejs-repl nginx-mode multiple-cursors migemo markdown-mode magit json-mode js2-mode jade-mode init-loader idle-highlight-mode htmlize helm-swoop helm-gtags helm-descbinds gtags go-complete flymake-go flymake-cursor flymake-coffee flycheck-pos-tip flycheck-cask find-file-in-repository expand-region exec-path-from-shell ess drag-stuff dockerfile-mode ctags-update csv-mode color-theme-wombat coffee-mode auto-highlight-symbol auto-async-byte-compile apache-mode)))
 '(rspec-use-rake-when-possible nil)
 '(rspec-use-spring-when-possible nil)
 '(safe-local-variable-values
   (quote
    ((eval setq-local flycheck-command-wrapper-function
	   (lambda
	     (command)
	     (append
	      (quote
	       ("bundle" "exec"))
	      command)))
     (ruby-compilation-executable . "ruby")
     (ruby-compilation-executable . "ruby1.8")
     (ruby-compilation-executable . "ruby1.9")
     (ruby-compilation-executable . "rbx")
     (ruby-compilation-executable . "jruby")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-type-face ((t (:foreground "brightcyan" :weight bold))))
 '(my-hl-line-face ((t (:background "dark blue" :underline nil)))))
