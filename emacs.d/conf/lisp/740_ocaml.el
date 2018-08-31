;;;
;;;
;;; Code
(when (require 'caml nil t))

(when (require 'tuareg nil t)
  (add-hook 'tuareg-mode-hook #'(lambda() (setq mode-name "🐫")))
  (when (require 'rainbow-delimiters nil t)
    (add-hook 'tuareg-mode-hook 'rainbow-delimiters-mode))
  )

;;;
