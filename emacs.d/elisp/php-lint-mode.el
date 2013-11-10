;;; php-lint-mode.el --- Minor mode to require php -l clean php.

;;; To use this, add the following code to your .emacs file and copy
;;; php-lint-mode.el to your ~/.site-lisp/ directory.
; (add-to-list 'load-path "~/.site-lisp/")
; (autoload 'php-lint "php-lint-mode" nil t)
; (autoload 'php-lint-mode "php-lint-mode" nil t)

; Automatically enable php-lint-mode for php-mode
; (eval-after-load "php-mode" '(add-hook 'php-mode-hook 'php-lint-mode))

;;; Copyright 2007 Jesse Mullan
;;; Based on perl-lint-mode, which is
;;; Copyright 2006 Joshua ben Jore

;;; Author: Joshua ben Jore <jjore@cpan.org>
;;; X-URL: http://search.cpan.org/~jjore/php-lint-mode/

;;; This program is free software; you can redistribute it and/or
;;; modify it under the same terms as perl itself.

(require 'cl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                           Lint checking
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar php-lint-bin "/usr/bin/php" "The php binary used to check for lint.")
(defvar php-lint-checks () "...")
(defun php-lint () "Returns a either nil or t depending on whether the current buffer
passes php's lint check. If there's a failure, the failures are
displayed in an adjacent buffer."
  (interactive)
  (save-restriction
    (widen)
    (save-excursion
      (let ((input-buf (current-buffer))
            (lint-buf (get-buffer-create "*Lint check*"))
            (interpreter (progn
                           (goto-char (point-min))
                           (if (looking-at auto-mode-interpreter-regexp)
                               (match-string 2)
                             php-lint-bin))))
; Clear the lint buffer if it needs it.
        (if (zerop (buffer-size lint-buf))
            nil
          (set-buffer lint-buf)
          (erase-buffer))
					; Run B::Lint on the current buffer using whatever checks
					; the user would like.
        (set-buffer input-buf)
        (let ((rc (call-process-region
                   (point-min)          ; start
		   (point-max)          ; end
                   interpreter          ; progam
		   nil                  ; delete
                   (list lint-buf t)    ; destination
                   nil                  ; display
					;args
                   (reduce (lambda (l r) (concat l " " r)) (cons "-l" php-lint-checks))
		   )))

					; Check that the B::Lint succeeded or clean up the error
					; messages it posted.
          (set-buffer lint-buf)
          (goto-char (point-min))
          (if (numberp rc)
              (if (not (zerop rc))
					; A non-zero exit, likely a syntax error. I'll leave
					; anything in the lint-buffer there.
                  t

					; If I get this far, it is at least syntactically
					; valid.

					; I'm frequently switching between different
					; Lints with different abilities so I've set
					; checks that don't always exist. This just
					; removes the warning.
                ;(or php-lint-ignore-bad-checks
                ;    (delete-matching-lines "^No such check: "))
					; Remove all the Lint lines for things that are in
					; files named anything other than "-". When I feed the
					; buffer to Lint, the file is named - because it comes
					; from STDIN.  Also remove the "Syntax ok" message.
                (call-process-region
                 (point-min)            ; start
		 (point-max)            ; end
                 "perl"                 ; program
		 t                      ; delete
                 (list lint-buf t)      ; destination
                 t                      ; display
		 "-0777"                ; arg
		 "-pe"                  ; arg
                 (concat "s/.+ at (?!-).+ line \\d+\\.?\\n//g"
                         ";"
                         "s/^No syntax errors detected in .*\\n//"
			 )))
					; arg
					; Sometimes non-numeric results come back. I'm just
					; bailing and inserting them for the user
					; to deal with.
            (insert rc "\n"))

					; Clean up or call for help.
          (let ((lint-ok (and (numberp rc)
                              (zerop rc)
                              (zerop (buffer-size)))))
            (if lint-ok (kill-buffer lint-buf)
              (display-buffer lint-buf))

					; Oh yeah. Return a boolean too.
            lint-ok))))))





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Lint mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar php-lint-mode nil
  "Check php lint before saving.")
(make-variable-buffer-local 'php-lint-mode)

(defun php-lint-write-hook ()
  "Check php lint during `write-file-hooks' for `php-lint-mode'"
  (if php-lint-mode
      (save-restriction
        (widen)
        (save-excursion
          (mark-whole-buffer)
					;;; Impede the save if php-lint fails
          (not (php-lint))))
					;;; Don't impede the save.
    nil))

(defun php-lint-mode (&optional arg)
  "Php lint checking minor mode."
  (interactive "P")

					; Cargo-culted from the Extending Emacs book.
  (setq php-lint-mode (if (null arg)
					; Toggle it on and off.
			  (not php-lint-mode)
					; Enable if >0.
			(> (prefix-numeric-value arg) 0)))

  (make-local-hook 'write-file-hooks)
  (funcall (if php-lint-mode #'add-hook #'remove-hook)
           'write-file-hooks 'php-lint-write-hook))

					; Add this to the list of minor modes.
(if (not (assq 'php-lint-mode minor-mode-alist))
    (setq minor-mode-alist
          (cons '(php-lint-mode " Lint")
                minor-mode-alist)))


(provide 'php-lint-mode)
