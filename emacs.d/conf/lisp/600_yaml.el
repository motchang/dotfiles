;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'yaml-mode nil t))

(when (require 'highlight-indent-guides nil t)
  (add-hook 'yaml-mode-hook  'highlight-indent-guides-mode)
  (add-hook 'prog-mode-hook  'highlight-indent-guides-mode)

  (setq highlight-indent-guides-auto-enabled t)
  (setq highlight-indent-guides-responsive t)
  (setq highlight-indent-guides-method 'character)) ; column
