;;; package --- Summary
;;; Commentary:
;;; Code:
(require 'php-mode)
(add-hook 'php-mode-hook
         (lambda ()
             (require 'php-completion)
             (php-completion-mode t)
             (define-key php-mode-map "\C-o" 'phpcmp-complete)
	     (define-key php-mode-map "\C-cb" 'geben-set-breakpoint-line)
             ;; (when (require 'auto-complete nil t)
	     ;;   (make-variable-buffer-local 'ac-sources)
	     ;;   (add-to-list 'ac-sources 'ac-source-php-completion)
	     ;;   (auto-complete-mode t))
	     (setq tab-width 4)
	     (setq indent-tabs-mode nil)
	     (c-toggle-hungry-state t)
	     (c-set-offset 'case-label' 4)
	     (c-set-offset 'arglist-intro' 4)
	     (c-set-offset 'arglist-close' 0)
	     ;; pear style
	     (setq tab-width 4
		   c-basic-offset 4
		   c-hanging-comment-ender-p nil
		   indent-tabs-mode nil)
	     ))

(add-hook 'php-mode-user-hook
	  '(lambda ()
	     (setq php-manual-path "~/share/doc/php/xhtml/")
	     (setq php-search-url "http://www.php.net/ja/")
	     (setq php-manual-url "http://www.php.net/manual/ja/")
	     ))

;; geben
(when (require 'geben nil t)
  (autoload 'geben-set-breakpoint-line "geben" "Set a breakpoint at the current line." t)
  (setq geben-dbgp-default-port 9005))

(when (require 'smarty-mode nil t)
  (setq smarty-left-delimiter "({")
  (setq smarty-right-delimiter "})"))
