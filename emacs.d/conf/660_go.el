(when (require 'go-mode nil t)
  (add-hook 'go-mode-hook
	    '(lambda ()
	       (setq tab-width 2)
	       (setq indent-tabs-mode nil)
	       )))
