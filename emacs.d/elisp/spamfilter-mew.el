;;; spamfilter-mew.el --- spam filter for Mew

;; Copyright (C) 2003 Susumu Ota

;; Author: Susumu ota <ccbcc@black.livedoor.com>
;; Keywords: SPAM, filter, Mew

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
	  
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.
	  
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
;; MA 02111-1307 USA


;; Usage:
;;   See README


;;; Code:

(eval-when-compile
  (require 'cl))

(require 'spamfilter)


;;;
;;; constant
;;;
(defconst spamf-mew-cvs-id "$Id: spamfilter-mew.el,v 1.3 2003/10/19 14:38:56 ota Exp $")

;;;
;;; parameter
;;;
(defvar spamf-mew-spam-folder-name "+spam"
  "SPAM folder name.")

(defvar spamf-mew-ignore-register-folder-names nil
  "Ignore folder list.")


;;;
;;; utility
;;;
(defun spamf-mew-get-buffer (&optional folder number)
  (let ((folder (or folder (mew-summary-folder-name)))
	(number (or number (mew-summary-message-number))))
    (mew-current-set folder number nil) ; ???
    (mew-summary-display nil)
    (mew-summary-toggle-disp-msg 'off)
    (get-buffer (or (mew-cache-hit folder number) (mew-buffer-message)))))

(defun spamf-mew-get-number-list (&optional folder)
  "TODO: folder"
  (save-excursion
    (goto-char (point-min))
    (do ((number (mew-summary-message-number) (mew-summary-message-number))
	 (number-list nil (cons number number-list)))
	((or (null number) (eobp)) (nreverse number-list))
      (forward-line 1))))


;;;
;;; interactive
;;;
(defun spamf-mew-spam-p (&optional folder number)
  (interactive)
  (let ((folder (or folder (mew-summary-folder-name)))
	(number (or number (mew-summary-message-number))))
    (let ((filename (concat folder "/" number)))
      (spamf-message "spamf-mew-spam-p: %s Processing..." filename)
      (let ((result (spamf-spam-buffer-p
		     (spamf-mew-get-buffer folder number))))
	(spamf-message "spamf-mew-spam-p: %s Processing...done. %s"
		       filename (if result "SPAM" "GOOD"))
	result))))

(defun spamf-mew-register-good (&optional folder number)
  (interactive)
  (spamf-register-good-buffer (spamf-mew-get-buffer folder number)))

(defun spamf-mew-register-spam (&optional folder number)
  (interactive)
  (spamf-register-spam-buffer (spamf-mew-get-buffer folder number)))

(defun spamf-mew-register-good-folder (&optional folder number-list)
  (interactive)
  (let ((folder (or folder (mew-summary-folder-name))))
    (let ((number-list (or number-list (spamf-mew-get-number-list folder))))
      (let ((end (length number-list)) (n 0))
	(dolist (number number-list)
	  (spamf-mew-register-good folder number)
	  (spamf-message "spamf-mew-register-good-folder: %d/%d"
			 (incf n) end))))))

(defun spamf-mew-register-spam-folder (&optional folder number-list)
  (interactive)
  (let ((folder (or folder (mew-summary-folder-name))))
    (let ((number-list (or number-list (spamf-mew-get-number-list folder))))
      (let ((end (length number-list)) (n 0))
	(dolist (number number-list)
	  (spamf-mew-register-spam folder number)
	  (spamf-message "spamf-mew-register-spam-folder: %d/%d"
			 (incf n) end))))))


;;;
;;; advice
;;;
(defadvice mew-refile-guess-by-alist (after
				      spamf-mew-refile-guess-by-alist
				      activate)
  (unless ad-return-value
    (when (spamf-mew-spam-p (mew-summary-folder-name)
			    (mew-summary-message-number))
      (setq ad-return-value (list spamf-mew-spam-folder-name)))))

(defadvice mew-mark-exec-refile (before
				 spamf-mew-mark-exec-refile
 				 activate)
  (let ((folder (ad-get-arg 0))
	(number-list (ad-get-arg 1)))
    (dolist (item (mapcar #'mew-refile-get number-list))
      (if (equal spamf-mew-spam-folder-name (cadr item))
	  (spamf-mew-register-spam (mew-summary-folder-name) (car item))
	(unless (member (cadr item) spamf-mew-ignore-register-folder-names)
	  (spamf-mew-register-good (mew-summary-folder-name) (car item)))))))


(defun spamf-mew-enable-spamfilter ()
  (interactive)
  (ad-enable-advice 'mew-refile-guess-by-alist
		    'after
		    'spamf-mew-refile-guess-by-alist)
  (ad-activate 'mew-refile-guess-by-alist)
  (ad-enable-advice 'mew-mark-exec-refile
		    'before
		    'spamf-mew-mark-exec-refile)
  (ad-activate 'mew-mark-exec-refile))

(defun spamf-mew-disable-spamfilter ()
  (interactive)
  (ad-disable-advice 'mew-refile-guess-by-alist
		     'after
		     'spamf-mew-refile-guess-by-alist)
  (ad-activate 'mew-refile-guess-by-alist)
  (ad-disable-advice 'mew-mark-exec-refile
		     'before
		     'spamf-mew-mark-exec-refile)
  (ad-activate 'mew-mark-exec-refile))


(provide 'spamfilter-mew)

;;; spamfilter-mew.el ends here
