;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'js2-mode nil t)
  (add-hook 'js2-mode-hook
	    (lambda ()
	      ;; (when (require 'auto-complete nil t)
	      ;;   (make-variable-buffer-local 'ac-sources)
	      ;;   (auto-complete-mode t))
	      (setq indent-tabs-mode nil)
	      (setq tab-width 2)
	      (setq c-basic-offset 2)
	      (setq js2-basic-offset 2)
	      (setq c-hanging-comment-ender-p nil)
	      (setq js-switch-indent-offset 2)
	      (c-toggle-hungry-state t)
	      (c-set-offset 'case-label' 2)
	      (c-set-offset 'arglist-intro' 2)
	      (c-set-offset 'arglist-close' 0)
	      (when (require 'auto-highlight-symbol nil t)
		(auto-highlight-symbol-mode t))
	      ;; (set-face-background 'js2-error "orange")
	      ;; (set-face-foreground 'js2-error "#0000F1")
	      ;; (set-face-background 'js2-external-variable nil)
	      ;; (set-face-foreground 'js2-external-variable "#0000F1")))
	      ;; Disable auto newline insertion after input semi colon (;) at javascript-mode
	      ;; http://insnvlovn.blogspot.jp/2010/04/emacs-php-mode.html
	      (setq-local electric-layout-rules '((?\{ . after) (?\} . before)))))

  (flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
  (add-hook 'js2-jsx-mode-hook 'flycheck-mode)
  )
(when (require 'flycheck nil t)
  (add-hook 'js2-mode-hook
	    (lambda ()
	      (flycheck-mode))))
;;;