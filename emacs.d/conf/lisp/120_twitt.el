;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'twittering-mode nil t)
  (require 'epg)
  (require 'epa-file)
  (epa-file-enable)
  (setq twittering-status-format "@%s %S %R\n%T %@ from %f%L%r%R")
  (setq epa-pinentry-mode 'loopback)
  (setq twittering-use-master-password t)
  (setq twittering-icon-mode nil)
  (setq twittering-timer-interval 180)
  (setq twittering-initial-timeline-spec-string
	'(":search/#ruby OR #rails OR #rspec lang:ja/"
	  ":home"
	  "unc3n50r3d/watch"
	  "motchang/follow"
	  )
	)
  )
