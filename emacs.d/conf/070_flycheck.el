(when (require 'flycheck nil t)
  (require 'flycheck-pos-tip)
  (eval-after-load 'flycheck
    '(custom-set-variables
      '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))
  (when (require 'ruby-mode nil t)
    (add-hook 'ruby-mode-hook
	      (lambda ()
		(setq flycheck-ruby-rubocop-executable "~/.rbenv/shims/rubocop")
		(flycheck-select-checker 'ruby-rubocop)
		(flycheck-disable-checker 'ruby-rubylint)
		(flycheck-mode)))
    (when (require 'rspec-mode nil t)
      (add-hook 'rspec-mode-hook
		(lambda ()
		  (flycheck-mode)))))
  (when (require 'js2-mode nil t)
    (add-hook 'js2-mode-hook
	      (lambda ()
		(flycheck-mode)))))
