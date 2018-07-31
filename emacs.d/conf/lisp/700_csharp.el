;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'csharp-mode)
  (add-hook 'csharp-mode-hook '(lambda () (omnisharp-mode) (flycheck-mode))))

(when (require 'omnisharp) nil t
      (setq omnisharp-server-executable-path "/usr/local/omnisharp-server/OmniSharp/bin/Debug/OmniSharp.exe")
      (define-key omnisharp-mode-map (kbd "<C-tab>") 'omnisharp-auto-complete)
      (define-key omnisharp-mode-map "." 'omnisharp-add-dot-and-auto-complete)
      (add-hook 'after-init-hook #'global-flycheck-mode))

(when (require 'ctags-update) nil t)

(when (require 'shader-mode) nil t)
