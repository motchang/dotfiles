;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'magit nil t)
  (add-hook 'magit-mode-hook
	    '(lambda ()
	       (add-to-list 'process-coding-system-alist '("git" utf-8 . utf-8))
	       (set-default-coding-systems 'utf-8)
	       (prefer-coding-system 'utf-8))))

;; -----------------------------------------------------------------------------
;; http://qiita.com/alpha22jp/items/01e614474e7dbfd78305
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

;; -----------------------------------------------------------------------------
;; git-link
(when (require 'git-link nil t)
  (setq git-link-open-in-browser t))
