;;; package --- Summary
;;; Commentary:
;;; Code:
(dolist (dir (list
	      "/usr/local/bin"
	      "/sbin"
	      "/usr/sbin"
	      "/bin"
	      "/usr/bin"
	      (expand-file-name "~/bin")
	      (expand-file-name "~/.emacs.d/bin")
	      (expand-file-name "~/.rbenv/shims")))
  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(defvar oldemacs-p (<= emacs-major-version 22)) ; 22 以下
(defvar emacs23-p (<= emacs-major-version 23))  ; 23 以下
(defvar emacs24-p (>= emacs-major-version 24))  ; 24 以上
(defvar darwin-p (eq system-type 'darwin))      ; Mac OS X 用
(defvar nt-p (eq system-type 'windows-nt))      ; Windows 用

(if (eq emacs-major-version 21)
    (setq confirm-kill-emacs 'yes-or-no-p)
  (defun my-save-buffers-kill-emacs ()
    (interactive)
    (if (yes-or-no-p "quit emacs? ")
	(save-buffers-kill-emacs)))
  (global-set-key "\C-x\C-c" 'my-save-buffers-kill-emacs))

;; (defun add-to-load-path (&rest paths)
;;  (let (path)
;;     (dolist (path paths paths)
;;       (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
;; 	(add-to-list 'load-path default-directory)
;; 	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    ;; (normal-top-level-add-subdirs-to-load-path))))))

;; (add-to-load-path "conf")

;; (byte-recompile-directory (expand-file-name "~/.emacs.d") 0)
(byte-recompile-directory (expand-file-name "~/.emacs.d/conf") 0)

;; (setq install-elisp-repository-directory "~/.emacs.d/elisp")

;; (add-hook 'after-init-lambda
;;           '(hook ()
;;              (let* ((el (expand-file-name "init.el" user-emacs-directory))
;;                     (elc (concat el "c")))
;;               (when (file-newer-than-file-p el elc)
;; (byte-compile-file el)))))

(require 'ido)
(ido-mode nil)
(ido-everywhere 0)
;;;
