;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'scss-mode nil t)
  ;; インデント幅を2にする
  ;; SASSの自動コンパイルをオフ
  (defun scss-custom ()
    "scss-mode-hook"
    (and
     (setq tab-width 2)
     (setq indent-tabs-mode nil)
     (set (make-local-variable 'css-indent-offset) 2)
     (set (make-local-variable 'scss-compile-at-save) nil)))
  (add-hook 'scss-mode-hook
						'(lambda() (scss-custom))))

(when (require 'sass-mode nil t)
  (defun sass-custom ()
    "sass-mode-hook"
    (and
     (setq tab-width 2)
     (setq indent-tabs-mode nil)
     (setq sass-indent-offset 2)))
  (add-hook 'sass-mode-hook
	    '(lambda() (sass-custom))))
