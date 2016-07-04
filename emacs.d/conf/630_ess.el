;; 拡張子が .r, .R の場合に R-mode を起動
;; (add-to-list 'auto-mode-alist '("\\.[rR]\\'" . R-mode))
;; R-mode は ess-r-d.el に定義されているが全機能をロードするために ess-site をロード

;; (autoload 'R-mode "ess-site" "Major mode for editing R source.  See `ess-mode' for more help." t)

;; (defun R-mode-init ()
;;   ;; インデントの調整（詳細は各変数のヘルプ参照）
;;   (setq ess-indent-level 2  ; 組み込み関数は 4 スペースだけど最近は 2 スペースが主流？
;; 	ess-arg-function-offset-new-line (list ess-indent-level)
;; 	ess-close-paren-offset '(0))
;;   ;; comment-region のコメントアウトに # を使う（デフォルト##）
;;   (set (make-local-variable 'comment-add) 0)
;;   ;; *.R と R のプロセスを結びつける
;;   ;; プロセスを結びつけることでプロセスに定義されている変数などの補完ができるようになる
;;   (let ((window-conf (current-window-configuration)))
;;     (ess-force-buffer-current)
;;     ;; 勝手に *R* バッファを開くので元に戻す
;;     (set-window-configuration window-conf))
;;   ;; ウィンドウが1つの状態で *.R を開いた場合はウィンドウを縦に分割して R を表示する
;;   (when (one-window-p)
;;     (split-window-horizontally)
;;     (set-window-buffer (next-window) (process-buffer (get-process ess-local-process-name))))
;;   )

;; (defun ess-pre-run-init ()
;;   ;; R のプロセスが他になくて 1 window ならウィンドウを分割する
;;   (when (and (> (length ess-process-name-list) 0)
;; 	     (one-window-p))
;;     (split-window-horizontally)
;;     (other-window 1))
;;   )

;; (defun ess-site-after-load ()
;;   ;; 起動時にワーキングディレクトリを尋ねられないようにする
;;   (setq ess-ask-for-ess-directory nil)
;;   ;; アンダースコアの入力が " <- " にならないようにする
;;   (ess-toggle-underscore nil)
;;   ;; # の数によってコメントのインデントの挙動が変わるのを無効にする
;;   (setq ess-fancy-comments nil)
;;   ;; キャレットがシンボル上にある場合にもエコーエリアにヘルプを表示する
;;   (setq ess-eldoc-show-on-symbol t)
;;   ;; anything/helm を使いたいので IDO は無効化
;;   (setq ess-use-ido nil)
;;   )

;; (eval-after-load "ess-site" '(ess-site-after-load))

;; (add-hook 'R-mode-hook 'R-mode-init)
;; ;; R 起動直前の処理
;; (add-hook 'ess-pre-run-hook 'ess-pre-run-init)
