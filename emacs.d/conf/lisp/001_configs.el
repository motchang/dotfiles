;;; package --- Summary
;;; Commentary:
;;; Code:
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

(setq inhibit-startup-screen nil)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq scroll-conservatively 1)
(setq next-line-add-newlines nil)
(setq make-backup-files nil)

(tool-bar-mode 0)
; (scroll-bar-mode 0)
(menu-bar-mode 0)

(line-number-mode t)
(column-number-mode t)
(global-font-lock-mode t)

(setq transient-mark-mode t)
(setq search-highlight t)
(setq query-replace-highlight t)

(global-set-key (kbd "C-x C-o") 'other-window)
(setq diff-switches "-w")

;; 165が¥（円マーク） , 92が\（バックスラッシュ）を表す
(define-key global-map [165] [92])


;; C-c C-l で折り返し表示をトグル
(defun toggle-truncate-lines ()
  "折り返し表示をトグル"
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  )
(global-set-key (kbd "C-c l") 'toggle-truncate-lines)
(setq truncate-partial-width-windows nil)

(add-hook 'linum-mode-hook
	  '(lambda ()
	     (set-face-foreground 'linum "#00ff00")
	     (set-face-background 'linum nil)))

;;kill-ring の最大値. デフォルトは 30.
(setq kill-ring-max 100)

(defun create-temporary-buffer ()
  "テンポラリバッファを作成し、それをウィンドウに表示します。"
  (interactive)
  ;; *temp* なバッファを作成し、それをウィンドウに表示します。
  (switch-to-buffer (generate-new-buffer "*temp*"))
  ;; セーブが必要ないことを示します？
  (setq buffer-offer-save nil))
;; C-c t でテンポラリバッファを作成します。
(global-set-key "\C-ct" 'create-temporary-buffer)
(exec-path-from-shell-initialize)

(when (require 'multi-term nil t))

;;;
