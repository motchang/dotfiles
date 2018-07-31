;;; package --- Summary
;;; Commentary:
;;; Code:
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(cond ((eq darwin-p t)
       ;; Mac の文字コード
       (require 'ucs-normalize)
       (set-file-name-coding-system 'utf-8-nfd)
       (require 'ls-lisp)
       (setq ls-lisp-use-insert-directory-program nil)
       (setq dired-use-ls-dired t)
       ;; (setq dired-listing-switches "-FlL --group-directories-first")
       )
      (t
       ;; そのほかのOSの設定(Unicodeの場合)
       (set-file-name-coding-system 'utf-8)))

(cond ((eq emacs24-p t)
       (setq buffer-file-coding-system 'utf-8))
      (setq default-buffer-file-coding-system 'utf-8))
(prefer-coding-system 'utf-8)
(set-language-environment "Japanese")
