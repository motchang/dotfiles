;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'go-mode nil t)
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH")
  (add-hook 'go-mode-hook
            '(lambda ()
               (setq tab-width 2)
               (setq indent-tabs-mode nil)))
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (eval-after-load "go-mode"
    '(require 'flymake-go)))
(when (require 'go-complete nil t)
  (add-hook 'completion-at-point-functions 'go-complete-at-point))
