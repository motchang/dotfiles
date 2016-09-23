(when (require 'recentf nil t)

  ;; (defmacro with-suppressed-message (&rest body)
  ;;   "Suppress new messages temporarily in the echo area and the `*Messages*' buffer while BODY is evaluated."
  ;;   (declare (indent 0))
  ;;   (let ((message-log-max nil))
  ;;     `(with-temp-message (or (current-message) "") ,@body)))

  (setq recentf-max-saved-items 1000)            ;; recentf に保存するファイルの数
  (setq recentf-exclude '(".recentf"))           ;; .recentf自体は含まない
  ;; (setq recentf-auto-cleanup 10)                 ;; 保存する内容を整理
  ;; (run-with-idle-timer 30 t '(lambda ()          ;; 30秒ごとに .recentf を保存
  ;; 			       (with-suppressed-message (recentf-save-list))))
  )
