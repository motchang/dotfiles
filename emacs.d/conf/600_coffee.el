(when (require 'coffee-mode nil t)
  (setq whitespace-action '(auto-cleanup))
  ;; only show bad whitespace
  (setq whitespace-style '(trailing space-before-tab indentation empty space-after-tab))
  (defun coffee-custom ()
    "coffee-mode-hook"
    ;; CoffeeScript uses two spaces.
    (custom-set-variables '(tab-width 2)))
    (custom-set-variables '(coffee-tab-width 2))
  (add-hook 'coffee-mode-hook 'coffee-custom))

(when (require 'flymake-coffee nil t)
  (add-hook 'coffee-mode-hook 'flymake-coffee-load)
  (setq flymake-coffee-coffeelint-configuration-file "~/src/dotfiles/coffeelint.json"))
