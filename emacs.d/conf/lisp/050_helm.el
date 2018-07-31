;;; package --- Summary
;;; Commentary:
;;; Code:

(when (require 'helm-config nil t)
  (helm-mode 1)
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)
  (global-set-key (kbd "C-x b") #'helm-mini)
  (global-set-key (kbd "C-x C-b") #'helm-buffers-list)

  (helm-autoresize-mode t)
  (setq helm-autoresize-max-height 0)
  (setq helm-autoresize-min-height 40)

  (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
  (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
  (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

  (setq helm-split-window-inside-p            nil	; open helm buffer inside current window, not occupy whole other window
	helm-move-to-line-cycle-in-source     nil	; move to end or beginning of source when reaching top or bottom of source.
	helm-ff-search-library-in-sexp        t		; search for library in `require' and `declare-function' sexp.
	helm-scroll-amount                    8		; scroll 8 lines other window using M-<next>/M-<prior>
	helm-ff-file-name-history-use-recentf t
	helm-echo-input-in-header-line t)

  (when (executable-find "curl")
    (setq helm-net-prefer-curl t))
 )

(when (require 'helm-gtags nil t)
  (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-find-tag)
  (define-key helm-gtags-mode-map (kbd "C-c s") 'helm-gtags-find-symbol)
  (define-key helm-gtags-mode-map (kbd "C-c r") 'helm-gtags-find-rtag)
  (define-key helm-gtags-mode-map (kbd "C-c t") 'helm-gtags-find-tag)
  (define-key helm-gtags-mode-map (kbd "C-c f") 'helm-gtags-parse-file)
  (define-key helm-gtags-mode-map (kbd "M-p") 'helm-gtags-pop-stack)
  (add-hook 'php-mode-hook
	    (lambda ()
	      (helm-gtags-mode t)))
  (add-hook 'ruby-mode-hook
	    (lambda ()
	      (helm-gtags-mode t))))

(when (require 'helm-swoop nil t))

(when (require 'helm-ghq nil t)
  (define-key global-map (kbd "C-]") 'helm-ghq))

(when (require 'helm-descbinds nil t)
  (helm-descbinds-mode)
  (define-key global-map (kbd "C-h C-b")  'helm-descbinds)
  '(defun describe-bindings ()
     (helm-descbindings)))

(ido-mode nil)
(ido-everywhere nil)
