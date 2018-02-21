;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'company nil t)
  (global-company-mode t)
  (setq company-idle-delay 0) ; デフォルトは0.5
  (setq company-minimum-prefix-length 4) ; デフォルトは4
  ; (setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
  (global-set-key (kbd "M-i") 'company-complete)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "C-h") nil)
  (eval-after-load 'company
    '(progn
       (push 'company-robe company-backends)))
  (eval-after-load 'company
    '(push 'company-robe company-backends))
  ;; (add-hook 'ruby-mode-hook
  ;; 	    (lambda ()
  ;; 	      (set (make-local-variable 'company-backends) '(company-abbrev company-gtags company-etags company-keywords))))
  )
