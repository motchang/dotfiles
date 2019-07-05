;;; package --- Summmary
;;; Commentary:
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

(add-to-list 'load-path "~/.cask")
(require 'cask)
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
 '(company-box-color-icon nil)
 '(company-box-enable-icon nil)
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(helm-autoresize-max-height 0)
 '(helm-autoresize-min-height 40)
 '(helm-autoresize-mode t)
 '(helm-descbinds-mode t)
 '(helm-echo-input-in-header-line t)
 '(helm-ff-file-name-history-use-recentf t)
 '(helm-ff-search-library-in-sexp t)
 '(helm-mode t)
 '(helm-net-prefer-curl t)
 '(helm-scroll-amount 8)
 '(magit-dispatch-arguments nil)
 '(max-lisp-eval-depth 10000)
 '(max-specpdl-size 10000)
 '(package-selected-packages
   (quote
    (helm-dash helm-chrome yasnippet yaml-mode web-mode use-package twittering-mode tide terraform-mode sws-mode string-inflection smex smarty-mode smartparens slim-mode slack shader-mode scss-mode sass-mode ruby-end rubocop rspec-mode robe rinari rainbow-mode rainbow-delimiters projectile prodigy popwin php-mode pallet omnisharp nyan-mode nodejs-repl nginx-mode multiple-cursors multi-term migemo markdown-mode magit json-mode js2-mode jade-mode init-loader idle-highlight-mode htmlize helm-swoop helm-ls-git helm-gtags helm-ghq helm-descbinds go-complete git-link ggtags flymake-go flymake-cursor flymake-coffee flycheck-pos-tip flycheck-cask find-file-in-repository expand-region exec-path-from-shell ess drag-stuff dockerfile-mode ctags-update csv-mode company-inf-ruby coffee-mode bundler auto-highlight-symbol auto-async-byte-compile atom-dark-theme apache-mode)))
 '(ruby-block-highlight-toggle (quote minibuffer))
 '(safe-local-variable-values
   (quote
    ((Coding . utf-8)
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
 '(company-box-annotation ((t nil)))
 '(company-box-background ((t (:background "SteelBlue3" :foreground "gray10"))))
 '(company-box-candidate ((t (:background "SteelBlue3" :foreground "white"))))
 '(company-echo ((t nil)) t)
 '(font-lock-doc-face ((t (:foreground "MediumPurple1"))))
 '(font-lock-type-face ((t (:foreground "#66ccff" :weight bold))))
 '(helm-selection ((t (:inherit hl-line :underline nil))))
 '(hl-line ((t (:background "#44475a")))))


;;; init.el ends here
