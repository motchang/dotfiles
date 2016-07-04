(when (require 'company nil t)
  (eval-after-load 'company
    '(progn
       (push 'company-inf-ruby company-backends)
       (push 'company-robe company-backends)))
  (eval-after-load 'company
    '(push 'company-robe company-backends))
  (add-hook 'ruby-mode-hook
	    (lambda ()
	      (set (make-local-variable 'company-backends) '(company-abbrev company-gtags company-etags company-keywords))
	      )))
