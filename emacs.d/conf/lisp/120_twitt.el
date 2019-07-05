;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'twittering-mode nil t)
  (require 'epg)
  (require 'epa-file)
  (epa-file-enable)
  (setq twittering-status-format "@%s %S %R\n%T %@ from %f%L%r%R\n")
  (setq epa-pinentry-mode 'loopback)
  (setq twittering-use-master-password t)
  (setq twittering-icon-mode nil)
  (setq twittering-timer-interval 45)
  (setq twittering-initial-timeline-spec-string
	'(":search/#ruby OR #rails OR #rspec lang:ja/"
          ":search/ポテパン -転職 -ドリームプロジェクト -rt/"
	  ":home"
	  "unc3n50r3d/watch"
	  "motchang/follow"
	  )
	)
  (add-hook 'twittering-mode-hook
    '(lambda ()
       (local-set-key "\C-c \C-c" 'twittering-update-status-interactive)))
  )
