(when (require 'gtags nil t)
;; (autoload 'gtags-mode "" t)
;; (setq gtags-mode-hook
;;       '(lambda ()
;; 	 (define-key gtags-mode-map (kbd "M-.") 'gtags-find-tag-from-here)
;;          (define-key gtags-mode-map (kbd "C-c s") 'gtags-find-symbol)
;;          (define-key gtags-mode-map (kbd "C-c r") 'gtags-find-rtag)
;;          (define-key gtags-mode-map (kbd "C-c t") 'gtags-find-tag)
;;          (define-key gtags-mode-map (kbd "C-c f") 'gtags-parse-file)
;;          (define-key gtags-mode-map (kbd "M-p") 'gtags-pop-stack)))

;; (global-set-key (kbd "M-p") 'gtags-pop-stack)
;; (add-hook 'php-mode-hook
;; 	  (lambda ()
;; 	    (gtags-mode t)))

;; (add-hook 'ruby-mode-hook
;; 	  (lambda ()
;; 	    (gtags-mode t)))
  )

; gtags auto update
(defun update-gtags (&optional prefix)
  (interactive "P")
  (let ((rootdir (gtags-get-rootpath))
        (args (if prefix "-v" "-iv")))
    (when rootdir
      (let* ((default-directory rootdir)
             (buffer (get-buffer-create "*update GTAGS*")))
        (save-excursion
          (set-buffer buffer)
          (erase-buffer)
	  (let ((result (start-process "gtags" "*update GTAGS*" "gtags" args "-w" "--gtagsconf" (expand-file-name "~/gtags.conf") "--gtagslabel=pygments")))	))))))
(add-hook 'after-save-hook 'update-gtags)
