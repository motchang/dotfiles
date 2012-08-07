;;-*-coding: emacs-mule;-*-
(define-abbrev-table 'Buffer-menu-mode-abbrev-table '())

(define-abbrev-table 'awk-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'browse-kill-ring-edit-mode-abbrev-table '())

(define-abbrev-table 'browse-kill-ring-mode-abbrev-table '())

(define-abbrev-table 'c++-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'c-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'change-log-mode-abbrev-table '())

(define-abbrev-table 'comint-mode-abbrev-table '())

(define-abbrev-table 'completion-list-mode-abbrev-table '())

(define-abbrev-table 'cperl-abbrev-table '())

(define-abbrev-table 'diff-mode-abbrev-table '())

(define-abbrev-table 'emacs-lisp-mode-abbrev-table '())

(define-abbrev-table 'fundamental-mode-abbrev-table '())

(define-abbrev-table 'global-abbrev-table '())

(define-abbrev-table 'grep-mode-abbrev-table '())

(define-abbrev-table 'html-mode-abbrev-table '())

(define-abbrev-table 'idl-mode-abbrev-table '())

(define-abbrev-table 'java-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'js-mode-abbrev-table '())

(define-abbrev-table 'lisp-mode-abbrev-table '())

(define-abbrev-table 'log-edit-mode-abbrev-table '())

(define-abbrev-table 'objc-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'php-mode-abbrev-table '())

(define-abbrev-table 'pike-mode-abbrev-table
  '(
   ))

(define-abbrev-table 'ruby-mode-abbrev-table '())

(define-abbrev-table 'select-tags-table-mode-abbrev-table '())

(define-abbrev-table 'sgml-mode-abbrev-table '())

(define-abbrev-table 'sh-mode-abbrev-table '())

(define-abbrev-table 'shell-mode-abbrev-table '())

(define-abbrev-table 'smarty-mode-abbrev-table
  '(
    ("assign" "" smarty-template-assign-hook 0)
    ("bbcodetohtml" "" smarty-template-bbcodetohtml-hook 0)
    ("btosmilies" "" smarty-template-btosmilies-hook 0)
    ("capitalize" "" smarty-template-capitalize-hook 0)
    ("capture" "" smarty-template-capture-hook 0)
    ("cat" "" smarty-template-cat-hook 0)
    ("clipcache" "" smarty-template-clipcache-hook 0)
    ("config_load" "" smarty-template-config-load-hook 0)
    ("count_characters" "" smarty-template-count-characters-hook 0)
    ("count_paragraphs" "" smarty-template-count-paragraphs-hook 0)
    ("count_sentences" "" smarty-template-count-sentences-hook 0)
    ("count_words" "" smarty-template-count-words-hook 0)
    ("counter" "" smarty-template-counter-hook 0)
    ("cycle" "" smarty-template-cycle-hook 0)
    ("date_format" "" smarty-template-date-format-hook 0)
    ("date_formatto" "" smarty-template-date-formatto-hook 0)
    ("debug" "" smarty-template-debug-hook 0)
    ("default" "" smarty-template-default-hook 0)
    ("else" "" smarty-template-else-hook 0)
    ("elseif" "" smarty-template-elseif-hook 0)
    ("escape" "" smarty-template-escape-hook 0)
    ("eval" "" smarty-template-eval-hook 0)
    ("fetch" "" smarty-template-fetch-hook 0)
    ("foreach" "" smarty-template-foreach-hook 0)
    ("foreachelse" "" smarty-template-foreachelse-hook 0)
    ("formtool_checkall" "" smarty-template-formtool-checkall-hook 0)
    ("formtool_copy" "" smarty-template-formtool-copy-hook 0)
    ("formtool_count_chars" "" smarty-template-formtool-count-chars-hook 0)
    ("formtool_init" "" smarty-template-formtool-init-hook 0)
    ("formtool_move" "" smarty-template-formtool-move-hook 0)
    ("formtool_moveall" "" smarty-template-formtool-moveall-hook 0)
    ("formtool_movedown" "" smarty-template-formtool-movedown-hook 0)
    ("formtool_moveup" "" smarty-template-formtool-moveup-hook 0)
    ("formtool_remove" "" smarty-template-formtool-remove-hook 0)
    ("formtool_rename" "" smarty-template-formtool-rename-hook 0)
    ("formtool_save" "" smarty-template-formtool-save-hook 0)
    ("formtool_selectall" "" smarty-template-formtool-selectall-hook 0)
    ("html_checkboxes" "" smarty-template-html-checkboxes-hook 0)
    ("html_image" "" smarty-template-html-image-hook 0)
    ("html_options" "" smarty-template-html-options-hook 0)
    ("html_radios" "" smarty-template-html-radios-hook 0)
    ("html_select_date" "" smarty-template-html-select-date-hook 0)
    ("html_select_time" "" smarty-template-html-select-time-hook 0)
    ("html_table" "" smarty-template-html-table-hook 0)
    ("if" "" smarty-template-if-hook 0)
    ("include" "" smarty-template-include-hook 0)
    ("include_clipcache" "" smarty-template-include-clipcache-hook 0)
    ("include_php" "" smarty-template-include-php-hook 0)
    ("indent" "" smarty-template-indent-hook 0)
    ("insert" "" smarty-template-insert-hook 0)
    ("ldelim" "" smarty-template-ldelim-hook 0)
    ("literal" "" smarty-template-literal-hook 0)
    ("lower" "" smarty-template-lower-hook 0)
    ("mailto" "" smarty-template-mailto-hook 0)
    ("math" "" smarty-template-math-hook 0)
    ("nl2br" "" smarty-template-nl2br-hook 0)
    ("paginate_first" "" smarty-template-paginate-first-hook 0)
    ("paginate_last" "" smarty-template-paginate-last-hook 0)
    ("paginate_middle" "" smarty-template-paginate-middle-hook 0)
    ("paginate_next" "" smarty-template-paginate-next-hook 0)
    ("paginate_prev" "" smarty-template-paginate-prev-hook 0)
    ("php" "" smarty-template-php-hook 0)
    ("popup" "" smarty-template-popup-hook 0)
    ("popup_init" "" smarty-template-popup-init-hook 0)
    ("rdelim" "" smarty-template-rdelim-hook 0)
    ("regex_replace" "" smarty-template-regex-replace-hook 0)
    ("repeat" "" smarty-template-repeat-hook 0)
    ("replace" "" smarty-template-replace-hook 0)
    ("section" "" smarty-template-section-hook 0)
    ("sectionelse" "" smarty-template-sectionelse-hook 0)
    ("spacify" "" smarty-template-spacify-hook 0)
    ("str_repeat" "" smarty-template-str-repeat-hook 0)
    ("string_format" "" smarty-template-string-format-hook 0)
    ("strip" "" smarty-template-vstrip-hook 0)
    ("strip_tags" "" smarty-template-strip-tags-hook 0)
    ("textformat" "" smarty-template-textformat-hook 0)
    ("truncate" "" smarty-template-truncate-hook 0)
    ("upper" "" smarty-template-upper-hook 0)
    ("validate" "" smarty-template-validate-hook 0)
    ("wordwrap" "" smarty-template-wordwrap-hook 0)
   ))

(define-abbrev-table 'special-mode-abbrev-table '())

(define-abbrev-table 'sql-mode-abbrev-table '())

(define-abbrev-table 'svn-log-edit-mode-abbrev-table '())

(define-abbrev-table 'svn-log-view-mode-abbrev-table '())

(define-abbrev-table 'svn-status-diff-mode-abbrev-table '())

(define-abbrev-table 'text-mode-abbrev-table '())

(define-abbrev-table 'vc-annotate-mode-abbrev-table '())

(define-abbrev-table 'vc-dir-mode-abbrev-table '())

(define-abbrev-table 'vc-svn-log-view-mode-abbrev-table '())

(define-abbrev-table 'yaml-mode-abbrev-table '())

