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

;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(package-selected-packages
   (quote
    (yasnippet yaml-mode web-mode use-package twittering-mode tide terraform-mode sws-mode string-inflection smex smarty-mode smartparens slim-mode slack shader-mode scss-mode sass-mode ruby-end rubocop rspec-mode robe rinari rainbow-mode rainbow-delimiters projectile prodigy popwin php-mode pallet omnisharp nyan-mode nodejs-repl nginx-mode multiple-cursors multi-term migemo markdown-mode magit json-mode js2-mode jade-mode init-loader idle-highlight-mode htmlize helm-swoop helm-ls-git helm-gtags helm-ghq helm-descbinds go-complete git-link ggtags flymake-go flymake-cursor flymake-coffee flycheck-pos-tip flycheck-cask find-file-in-repository expand-region exec-path-from-shell ess drag-stuff dockerfile-mode ctags-update csv-mode company-inf-ruby coffee-mode bundler auto-highlight-symbol auto-async-byte-compile atom-dark-theme apache-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-type-face ((t (:foreground "#66ccff" :weight bold)))))
