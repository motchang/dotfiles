;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'ruby-mode nil t)
  (when (require 'robe nil t)
    (add-hook 'robe-mode-hook
	      '(lambda ()
		 (define-key ruby-mode-map (kbd "M-j") 'robe-jump)))
    (add-hook 'ruby-mode-hook 'robe-mode))
  (setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
  (add-hook 'ruby-mode-hook
	    '(lambda ()
	       ;; http://stackoverflow.com/questions/7961533/emacs-ruby-method-parameter-indentation
	       (defadvice ruby-indent-line (after unindent-closing-paren activate)
		 (let ((column (current-column))
		       indent offset)
		   (save-excursion
		     (back-to-indentation)
		     (let ((state (syntax-ppss)))
		       (setq offset (- column (current-column)))
		       (when (and (eq (char-after) ?\))
				  (not (zerop (car state))))
			 (goto-char (cadr state))
			 (setq indent (current-indentation)))))
		   (when indent
		     (indent-line-to indent)
		     (when (> offset 0) (forward-char offset)))))
	       ;;
	       (set-default-coding-systems 'utf-8)
	       (setq c-toggle-hungry-state t)
	       (setq ruby-insert-encoding-magic-comment nil)
	       ;; (define-key ruby-mode-map (kbd "M-.") 'find-tag)
	       ;; (define-key ruby-mode-map (kbd "M-p") 'pop-tag-mark)
	       (define-key ruby-mode-map (kbd "<backspace>") 'c-hungry-delete)
	       (define-key ruby-mode-map (kbd "<delete>") 'c-hungry-delete)
	       (electric-indent-mode t)
	       (electric-layout-mode t)
	       (setq ruby-deep-indent-paren-style nil)
	       (setq truncate-lines t)
	       (electric-pair-mode 0)
	       (when (require 'ruby-block nil t)
		 (ruby-block-mode t)
		 ;; ミニバッファに表示し, かつ, オーバレイする.
		 (setq ruby-block-highlight-toggle t))
	       (when (require 'ruby-end nil t)
		 (ruby-end-mode t)
		 (setq ruby-end-insert-newline nil)
		 (setq ruby-end-check-statement-modifiers nil))
	       (when (require 'rinari nil t)
		 (rinari-minor-mode 1))
	       (when (require 'ruby-compilation nil t)
		 (setq company-minimum-prefix-length 4)
		 (define-key ruby-mode-map (kbd "\M-r") 'run-rails-test-or-ruby-buffer))))
  ;; set ruby-mode indent
  (setq ruby-indent-level 2)
  (setq ruby-indent-tabs-mode nil)
  ;; http://d.hatena.ne.jp/khiker/20071130/emacs_ruby_block
  ;; rbenv の ruby を参照するようにする
  (setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
  (setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   (if (window-system)
       '(font-lock-type-face ((t (:foreground "#0077ff" :weight bold))))
     '(font-lock-type-face ((t (:foreground "brightcyan" :weight bold))))
     )
   ;; '(my-hl-line-face ((t (:background "dark blue" :underline nil))))
   ))

(when (require 'inf-ruby nil t)
  (setq inf-ruby-default-implementation "pry")
  (setq inf-ruby-eval-binding "Pry.toplevel_binding")
  (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'inf-ruby-mode-hook 'ansi-color-for-comint-mode-on))

;; rspec-mode
(when (require 'rspec-mode nil t)
  (when (require 'flycheck nil t)
    (add-hook 'rspec-mode-hook
	      (lambda ()
		(flycheck-mode))))
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   )
  (add-hook 'rspec-mode-hook
	    (lambda ()
	      (define-key ruby-mode-map (kbd "C-c r") 'execute-rspec)
	      (linum-mode))))

;; https://github.com/endofunky/bundler.el
(when (require 'bundler nil t))
;;;
