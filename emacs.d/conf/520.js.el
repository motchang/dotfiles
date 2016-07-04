(add-hook 'js-mode-hook
         (lambda ()
             ;; (when (require 'auto-complete nil t)
	     ;;   (make-variable-buffer-local 'ac-sources)
	     ;;   (auto-complete-mode t))
	     (setq tab-width 2)
	     (setq indent-tabs-mode nil)
	     (c-toggle-hungry-state t)
	     (setq c-basic-offset 2)
	     (c-set-offset 'case-label' 2)
	     (c-set-offset 'arglist-intro' 2)
	     (c-set-offset 'arglist-close' 0)
	     (setq tab-width 2
		   c-basic-offset 2
		   c-hanging-comment-ender-p nil
		   indent-tabs-mode nil)
	     ))
