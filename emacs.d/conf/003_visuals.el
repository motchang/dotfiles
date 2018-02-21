;;; package --- Summary
;;; Commentary:
;;; Code:
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
;; (set-face-background 'default "black")
(set-face-foreground 'font-lock-comment-face "#00AA00")
(set-face-foreground 'font-lock-string-face "#AABBEE")
;; (set-face-foreground 'font-lock-type-face "color-45")
(set-face-foreground 'font-lock-type-face "cyan1")
;; (setq eww-search-prefix "https://www.google.co.jp/search?q="))
(when (require 'color-theme nil t)
;;   ;; カラーテーマの選択
;;   ;; M-x color-theme-select
;;   ;; テーマを読み込むための設定
  (color-theme-initialize)
  (color-theme-standard)
  (color-theme-billw)
;;   ;; テーマを変更する
  ;; (color-theme-dark-laptop)
;;   ;; (color-theme-xemacs)
;;   ;; (color-theme-sitaramv-solaris)
;;   (color-theme-deep-blue)
  ;; (load-theme 'wombat t)
;;   ;; (load-theme 'manoj-dark t)
;;   ;; (load-theme 'pastels-on-dark t)
;;   ;; Wheat Billw Midnight dark-laptop
  )


;;; (set-face-foreground 'region "white")
;; (set-face-background 'region "yellow")

;; paren-mode 対応する括弧を強調して表示する
;; 表示まての秒数。初期値は0.125
(setq show-paren-delay 0.0)
(show-paren-mode t)

;; parenのスタイル: expression は括弧内も強調表示
;;(setq show-paren-style 'expression)
;; mixed だと画面内に収まらない時にカッコ内も表示する
(setq show-paren-style 'mixed)

(set-face-background 'show-paren-match-face "DeepPink")
;;(set-face-background 'show-paren-match-face nil)
;;(set-face-underline-p 'show-paren-match-face "yellow")
;;(set-face-underline-p 'show-paren-match-face t)
;;(setq show-paren-match-face 'underline)

(when (require 'rainbow-mode nil t)
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'scss-mode-hook 'rainbow-mode)
  (add-hook 'php-mode-hook 'rainbow-mode)
  (add-hook 'html-mode-hook 'rainbow-mode)
  (add-hook 'lisp-mode-hook 'rainbow-mode)
  (add-hook 'web-mode-hook 'rainbow-mode))
;;;
