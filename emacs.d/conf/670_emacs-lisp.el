;;; package --- Summary
;;; Commentary:
;;; Code:
(add-hook 'after-save-hook
	  (function (lambda ()
		      (if (eq major-mode 'emacs-lisp-mode)
			  (save-excursion
			    (byte-compile-file buffer-file-name))))))
