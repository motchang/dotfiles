
(when (require 'typescript-mode) nil t
      (add-to-list 'auto-mode-alist '("\\.ts[x]\\'" . typescript-mode)))

(when (require 'tide) nil t
      (defun setup-tide-mode ()
				(interactive)
				(tide-setup)
				(flycheck-mode +1)
				(setq flycheck-check-syntax-automatically '(save mode-enabled))
				(eldoc-mode +1)
				(tide-hl-identifier-mode +1)
				;; company is an optional dependency. You have to
				;; install it separately via package-install
				;; `M-x package-install [ret] company`
				(company-mode +1))

      ;; aligns annotation to the right hand side
      (setq company-tooltip-align-annotations t)
      (setq tide-format-options '(:indentSize 2 :tabSize 2 :insertSpaceAfterFunctionKeywordForAnonymousFunctions t :placeOpenBraceOnNewLineForFunctions nil))

      ;; formats the buffer before saving
      (add-hook 'before-save-hook 'tide-format-before-save)
      )

(when (require 'web-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (add-hook 'web-mode-hook
            (lambda ()
						  (setq-default tab-width 2)
						  (setq tab-width 2)
						  (setq indent-tabs-mode nil)
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
								(setup-tide-mode))))
  ;; enable typescript-tslint checker
  (flycheck-add-mode 'typescript-tslint 'web-mode)
	)

(require 'company)
;;; C-n, C-pで補完候補を選べるように
(define-key company-active-map (kbd "M-n") nil)
(define-key company-active-map (kbd "M-p") nil)
(define-key company-active-map (kbd "C-n") 'company-select-next)
(define-key company-active-map (kbd "C-p") 'company-select-previous)
;;; C-hがデフォルトでドキュメント表示にmapされているので、文字を消せるようにmapを外す
(define-key company-active-map (kbd "C-h") nil)
;;; 1つしか候補がなかったらtabで補完、複数候補があればtabで次の候補へ行くように
(define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
;;; ドキュメント表示
(define-key company-active-map (kbd "M-d") 'company-show-doc-buffer)

(setq company-minimum-prefix-length 3) ;; 1文字入力で補完されるように
 ;;; 候補の一番上でselect-previousしたら一番下に、一番下でselect-nextしたら一番上に行くように
(setq company-selection-wrap-around t)

;;; 色の設定。出来るだけ奇抜にならないように
(set-face-attribute 'company-tooltip nil
                    :foreground "black"
                    :background "lightgray")
(set-face-attribute 'company-preview-common nil
                    :foreground "dark gray"
                    :background "black"
                    :underline t)
(set-face-attribute 'company-tooltip-selection nil
                    :background "steelblue"
                    :foreground "white")
(set-face-attribute 'company-tooltip-common nil
                    :foreground "black"
                    :underline t)
(set-face-attribute 'company-tooltip-common-selection nil
                    :foreground "white"
                    :background "steelblue"
                    :underline t)
(set-face-attribute 'company-tooltip-annotation t
                    :foreground "red")
