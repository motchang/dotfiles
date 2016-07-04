(when (require 'ruby-mode nil t)
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
	       (set-face-foreground 'font-lock-type-face "cyan")
	       ;; (when (require 'flycheck nil t)
	       ;; 	 (lambda ()
	       ;; 	   (flycheck-mode)
	       ;; 	   (flycheck-select-checker 'ruby-rubocop)
	       ;; 	   (flycheck-disable-checker 'ruby-rubylint)))
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
		 (define-key ruby-mode-map (kbd "\M-r") 'run-rails-test-or-ruby-buffer))
	       (when (require 'auto-complete nil t)
		 ;; http://qiita.com/tadsan/items/ab3c3b594b5bf6203f02
		 (make-local-variable 'ac-ignore-case)
		 (setq ac-ignore-case nil)
		 (abbrev-mode 1))))
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
   '(font-lock-type-face ((t (:foreground "brightcyan" :weight bold))))
   '(my-hl-line-face ((t (:background "dark blue" :underline nil))))))

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
   '(custom-safe-themes
     (quote
      ("e80932ca56b0f109f8545576531d3fc79487ca35a9a9693b62bf30d6d08c9aaf" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "211bb9b24001d066a646809727efb9c9a2665c270c753aa125bace5e899cb523" default)))
   '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
   '(rspec-use-rake-flag nil)
   '(rspec-use-rake-when-possible nil)
   '(rspec-use-spring-when-possible nil)
   )
  (add-hook 'rspec-mode-hook
	    (lambda ()
	      (define-key ruby-mode-map (kbd "C-c r") 'execute-rspec)
	      (linum-mode))))
