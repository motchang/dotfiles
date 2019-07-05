;;; package --- Summary
;;; Commentary:
;;; Code:
(if (window-system)
    (progn
      ;; (set-face-foreground 'font-lock-comment-face "#8C9C8C")
      ;; (set-face-foreground 'font-lock-comment-face "#8C9C8C")
      (load-theme 'dracula t)
      ;; (setq atom-dark-theme-force-faces-for-mode nil))
      )
  (load-theme 'wombat t))
;; (load-theme 'wombat t)
;; (load-theme 'manoj-dark t)
;; (load-theme 'tsdh-light t)
;; (load-theme 'misterioso t)
;; (load-theme 'misterioso t)
;; (load-theme 'tango t)
;; (load-theme 'tango-dark t)
;; (color-theme-taylor)

;; paren-mode 対応する括弧を強調して表示する
;; 表示まての秒数。初期値は0.125
(setq show-paren-delay 0.0)
(show-paren-mode t)

;; parenのスタイル: expression は括弧内も強調表示
(setq show-paren-style 'mixed)
;; mixed だと画面内に収まらない時にカッコ内も表示する
;; (setq show-paren-style 'mixed)

;; (if (window-system)
;;     (set-face-attribute 'show-paren-match nil
;; 			:background "#003366" :foreground nil
;; 			:underline nil :weight 'bold)
;;   (set-face-attribute 'show-paren-match nil
;;                       :background "#444444" :foreground nil
;;                       :underline nil :weight 'bold))

(when (require 'rainbow-mode nil t)
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'scss-mode-hook 'rainbow-mode)
  (add-hook 'php-mode-hook 'rainbow-mode)
  (add-hook 'html-mode-hook 'rainbow-mode)
  (add-hook 'lisp-mode-hook 'rainbow-mode)
  (add-hook 'web-mode-hook 'rainbow-mode))

(when (require 'rainbow-delimiters nil t)
  (rainbow-delimiters-mode t)
  (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
  ;; https://yoo2080.wordpress.com/2013/12/21/small-rainbow-delimiters-tutorial/#sec-5-1
  ;; 5.1. using stronger colors
  (require 'cl-lib)
  (require 'color)
  (cl-loop
   for index from 1 to rainbow-delimiters-max-face-count
   do
   (let ((face (intern (format "rainbow-delimiters-depth-%d-face" index))))
     (cl-callf color-saturate-name (face-foreground face) 30))))

(set-cursor-color "Green")
(global-hl-line-mode 1)
;; (if (window-system)
;;     (set-face-background 'hl-line "#002266")
;;   (set-face-background 'hl-line "#444444"))

(set-face-foreground 'hl-line nil)
(set-face-foreground 'highlight nil)

(when (require 'all-the-icons nil t))

(when (require 'doom-modeline nil t)
  (doom-modeline-mode t)
  (setq doom-modeline-buffer-file-name-style 'truncate-with-project)
  (setq doom-modeline-icon t)
  (setq doom-modeline-major-mode-icon nil)
  (setq doom-modeline-minor-modes nil))

;;;
