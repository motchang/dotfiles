;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'web-mode nil t)
  (defun my/web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-html-offset                  2)
    (setq web-mode-markup-indent-offset         2)
    (setq web-mode-css-offset                   2)
    (setq web-mode-script-offset                2)
    (setq web-mode-php-offset                   2)
    (setq web-mode-java-offset                  2)
    (setq web-mode-asp-offset                   2)
    (setq indent-tabs-mode                      nil)
    (setq tab-width                             2)
    (setq web-mode-enable-auto-pairing          t)
    (setq web-mode-enable-auto-closing          t)
    (setq web-mode-enable-auto-quoting          t)
    (setq web-mode-enable-auto-indentation      t)
    (if (window-system)
	'(web-mode-type-face ((t (:foreground "#66ccfff" :weight bold))))
      ))
  (add-hook 'web-mode-hook 'my/web-mode-hook))

(when (require 'rinari nil t)
  (setq rinari-minor-mode t))
