;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'json-mode nil t)
  (add-hook 'json-mode-hook
	    (lambda ()
	      (make-local-variable 'js-indent-level)
	      (setq js-indent-level 2))))
