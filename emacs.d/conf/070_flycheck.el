(when (require 'flycheck nil t)
  (when (require 'ruby-mode nil t)
    (add-hook 'ruby-mode-hook
	      (lambda ()
		(flycheck-mode)
		(flycheck-select-checker 'ruby-rubocop)
		(flycheck-disable-checker 'ruby-rubylint))))
  (when (require 'rspec-mode nil t)
    (add-hook 'rspec-mode-hook
	      (lambda ()
		(flycheck-mode))))
  (when (require 'js2-mode nil t)
    (add-hook 'js2-mode-hook
	      (lambda ()
		(flycheck-mode)))))

(when (require 'flycheck-pos-tip nil t)
  (eval-after-load 'flycheck
    '(custom-set-variables
      '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages))))
