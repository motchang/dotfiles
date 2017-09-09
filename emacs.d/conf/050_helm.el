;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'helm nil t)
  (require 'helm-config)
  (helm-mode t)
  (define-key global-map (kbd "M-x")      'helm-M-x)
  (define-key global-map (kbd "C-x C-f")  'helm-find-files)
  (define-key global-map (kbd "M-y")      'helm-show-kill-ring)
  (define-key global-map (kbd "<f5> a i") 'helm-imenu)
  (define-key global-map (kbd "C-x b")    'helm-mini)
  (define-key global-map (kbd "C-x C-b")  'helm-mini)
  (define-key helm-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
  (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
  (custom-set-variables
   '(helm-truncate-lines t)
   '(helm-buffer-max-length 35)
   '(helm-delete-minibuffer-contents-from-point t)
   '(helm-ff-skip-boring-files t)
   '(helm-boring-file-regexp-list '("~$"))
   '(helm-ls-git-show-abs-or-relative 'relative)
   '(helm-mini-default-sources '(helm-source-buffers-list
                                 helm-source-recentf
                                 helm-source-buffer-not-found))))

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

(when (require 'helm-descbinds nil t)
  (helm-descbinds-mode)
  (define-key global-map (kbd "C-h C-b")  'helm-descbinds)
  '(defun describe-bindings ()
     (helm-descbindings)))

(when (require 'popwin nil t)
  (when (require 'helm nil t)
    (setq helm-full-frame nil)
    (setq display-buffer-function 'popwin:display-buffer)
    (setq popwin:special-display-config '(("*compilatoin*" :noselect t)
					  ("helm" :regexp t :height 0.4)))))