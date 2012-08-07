(defvar run-script-command nil)
(defvar run-script-switch "")
(defvar run-script-argument "")
(defvar run-script-temporary-buffer-name nil)

(make-variable-buffer-local 'run-script-command)
(make-variable-buffer-local 'run-script-switch)
(make-variable-buffer-local 'run-script-argument)
(make-variable-buffer-local 'run-script-temporary-buffer-name)

(defvar run-script-switch-history nil)
(defvar run-script-argument-history nil)

;;;###autoload
(defun run-script ()
    (interactive)
      (let ((coding-system-for-read buffer-file-coding-system)
	    (coding-system-for-write buffer-file-coding-system))
	(if (or (buffer-modified-p (current-buffer))
		(not (file-exists-p (buffer-file-name))))
	    (run-script-using-tempfile 'run-script-internal)
	  (run-script-internal (buffer-file-name)))))

(defun run-script-internal (script-path)
  (when (null run-script-command)
    (error "No script command specified. Set `run-script-command'."))
  (let ((src-buf (current-buffer))
	(output-buf (run-script-create-output-buffer))
	(command-line (format "%s %s %s %s"
			      run-script-command
			      (run-script-make-switch)
			      script-path
			      (run-script-make-argument))))
    (unwind-protect
	(shell-command command-line output-buf)
      (pop-to-buffer output-buf)
      (pop-to-buffer src-buf))))

(defun run-script-using-tempfile (fn)
  (let ((temp-path (expand-file-name (make-temp-name "runscripttmp")
				     temporary-file-directory)))
    (unwind-protect
	(progn
	  (write-region (point-min) (point-max) temp-path nil 0)
	  (funcall fn temp-path))
      (delete-file temp-path))))

(defun run-script-create-output-buffer ()
  (get-buffer-create (format "*%s*"
			     (or run-script-temporary-buffer-name
				 (concat mode-name " output")))))

(defun run-script-make-string (ask default history-symbol)
  (unless (local-variable-p history-symbol)
    (make-local-variable history-symbol))
  (let ((history (symbol-value history-symbol)))
    (if current-prefix-arg
	(prog1
	    (read-from-minibuffer (concat ask ": ")
				  (or (car history) default)
				  nil nil 'history)
	  (set history-symbol history))
      default)))

(defun run-script-make-switch ()
  (if current-prefix-arg
      (setq run-script-switch
	    (read-from-minibuffer "Switch: "
				  (or (car run-script-switch-history) run-script-switch)
				  nil nil 'run-script-switch-history))
    run-script-switch))

(defun run-script-make-argument ()
  (if current-prefix-arg
      (setq run-script-argument
	    (read-from-minibuffer "Argument: "
				  (or (car run-script-argument-history) run-script-argument)
				  nil nil 'run-script-argument-history))
    run-script-argument))
