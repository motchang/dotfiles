;;; package --- Summary
;;; Commentary:
;;; Code:
(when (require 'string-inflection nil t)
  (global-set-key (kbd "C-c i") 'string-inflection-cycle)
  (global-set-key (kbd "C-c C") 'string-inflection-camelcase)		;; Force to CamelCase
  (global-set-key (kbd "C-c L") 'string-inflection-lower-camelcase)	;; Force to lowerCamelCase
  (global-set-key (kbd "C-c J") 'string-inflection-java-style-cycle))	;; Cycle through Java styles
