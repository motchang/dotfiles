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
