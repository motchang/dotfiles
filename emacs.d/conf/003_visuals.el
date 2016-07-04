(cond ((eq emacs24-p t)
       (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
       ;; (load-theme 'wombat t)
       ;; (load-theme 'manoj-dark t)
       (load-theme 'pastels-on-dark t)
       (set-face-background 'default "black")
       (set-face-foreground 'font-lock-comment-face "#00AA00")
       (set-face-foreground 'font-lock-string-face "#AABBEE")
       ;; (set-face-foreground 'font-lock-type-face "color-45")
       (set-face-foreground 'font-lock-type-face "cyan1")
       (setq eww-search-prefix "https://www.google.co.jp/search?q="))
      ((when (require 'color-theme nil t)
         ;; カラーテーマの選択
         ;; M-x color-theme-select
         ;; カラーテーマの例
         ;; http://gnuemacscolorthemetest.googlecode.com/svn/html/index-c.html
         ;; テーマを読み込むための設定
         (color-theme-initialize)
         ;; テーマを変更する
         (color-theme-dark-laptop)
         ;; いい感しの
         ;; Wheat Billw Midnight dark-laptop
        )))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(custom-safe-themes
   (quote
    ("e80932ca56b0f109f8545576531d3fc79487ca35a9a9693b62bf30d6d08c9aaf" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "211bb9b24001d066a646809727efb9c9a2665c270c753aa125bace5e899cb523" default)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(rspec-use-rake-when-possible nil)
 '(safe-local-variable-values
   (quote
    ((engine . scss)
     (encoding . utf-8)
     (ruby-compilation-executable . "ruby")
     (ruby-compilation-executable . "ruby1.8")
     (ruby-compilation-executable . "ruby1.9")
     (ruby-compilation-executable . "rbx")
     (ruby-compilation-executable . "jruby")))))

(set-face-foreground 'region "black")
(set-face-background 'region "yellow")

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

(defface my-hl-line-face
   ;; 背景が dark なら
   '((((class color) (background dark))
      ;; (:background "maroon4" :underline nil))
      (:background "dark blue" :underline nil))
     ;; 背景かlightなら
     (((class color) (background light))
      (:background "LightGoldenrodYellow" t))
     ;; (t (:bold t))
     (t :underline t)
     )
   "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)

;; 現在行をハイライト表示
(global-hl-line-mode t)

(when (require 'rainbow-mode nil t)
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'scss-mode-hook 'rainbow-mode)
  (add-hook 'php-mode-hook 'rainbow-mode)
  (add-hook 'html-mode-hook 'rainbow-mode)
  (add-hook 'lisp-mode-hook 'rainbow-mode)
  (add-hook 'web-mode-hook 'rainbow-mode))
