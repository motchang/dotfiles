(when (require 'color-moccur nil t)
  ;; クローハルマッフにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スヘース区切りてAND検索
  (setq moccur-split-word t)
  ;; ティレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (when (require 'moccur-edit nil t)
    ;; (when (and (executable-find "cmigemo")
    ;; 	     (require 'migemo nil t))
    ;;   (setq moccur-use-migemo t))
    ))
