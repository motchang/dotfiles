(when (require 'twittering-mode nil t)
  (setq twittering-use-master-password t)
  (setq twittering-icon-mode nil)
  (setq twittering-timer-interval 500)
  (setq twittering-initial-timeline-spec-string
	'(":search/#ruby OR #rails OR #rspec lang:ja/"
	  ":home"
	  "motchang/met")))
