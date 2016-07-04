;; -----------------------------------------------------------------------------
;; sql-mode
;; -----------------------------------------------------------------------------
;; C-c C-c : 'sql-send-paragraph
;; C-c C-r : 'sql-send-region
;; C-c C-s : 'sql-send-string
;; C-c C-b : 'sql-send-buffer
(when (require 'sql nil t)
  (add-hook 'sql-interactive-mode-hook
	    #'(lambda ()
		(interactive)
		(set-buffer-process-coding-system 'utf-8 'utf-8 )
		              (setq show-trailing-whitespace nil)))
  ;; starting SQL mode loading sql-indent / sql-complete
  (eval-after-load "sql"
    '(progn
       (load-library "sql-indent")
       (load-library "sql-complete")
       (load-library "sql-transform"))))
