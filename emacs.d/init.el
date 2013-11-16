;load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
 (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))
;; elispとconfティレクトリをサフティレクトリことload-pathに追加
(add-to-load-path "elisp" "conf")

;; -----------------------------------------------------------------------------
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  ;; インストールティレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWiki に登録されている elisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要てあれはフロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))

;; ここてC-x C-eとタイフして
;; みましょう。Emacsを再起動せすとも設定か即座に
;; 反映されます。C-x C-eはeval-last-sexpにハイント
;; されており、式を評価してその戻り値をミニハッフ
;; ァに返します。

;; -----------------------------------------------------------------------------
;; installed
;;(install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")

;; ・C-h a 文字列 RET
;; 入力した文字列か含まれているコマントのリスト
;; を表示する（M-x command-apropos）。例：autoinstall
;; という文字列か含まれるコマントを調へる
;; C-h a auto-install RET

;; ・C-h b
;; 現在のキーの割り当て表を表示する（M-x
;; describe-bindings）

;; ・C-h k キーハイント
;; キーハイントか実行するコマント（関数）名とその
;; トキュメントを表示する（M-x describe-key）。例：
;; C-qて実行されるコマントを調へるC-h k C-q

;; ・C-h w コマント名 RET
;; 入力したコマントを実行するキーを表示する（M-x
;; where-is）。例：コマントquery-replaceのキーハ
;; イントを調へるC-h w query-replace RET

;; ・C-h f 関数名 RET
;; 入力した関数の説明を表示する（M-x describefunction）
;; 例：関数lambda について調へる
;; C-h f lambda RET

;; ・C-h v 変数名 RET
;; 入力した変数の説明を表示する（M-x describevariable）
;; 例：変数load-path について調へる
;; C-h v load-path RET

;; 入力されるキーシーケンスを入れ換える
;; ?\C-?はDELのキーシケンス
;(keyboard-translate ?\C-h ?\C-?)
;; 別のキーハイトにヘルフを割り当てる
;(global-set-key (kbd "C-x ?") 'help-command)

;; -----------------------------------------------------------------------------
;; Mac の文字コートの設定
;; (set-language-environment "Japanese")
;; (require 'ucs-normalize)
;; (prefer-coding-system 'utf-8-hfs)
;; (setq file-name-coding-system 'utf-8-hfs)
;; (setq locale-coding-system 'utf-8-hfs)

;; そのほかのOSの設定(Unicodeの場合)
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)
(setq file-name-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)

;; スタートアッフメッセーシを非表示
(setq inhibit-startup-screen t)
;; tool-barを非表示。コンソールては不要
;(tool-bar-mode 0)
;; scroll-barを非表示。コンソールては不要
;(scroll-bar-mode 0)
;; menu-barを非表示
;(menu-bar-mode 0)

;; メニューハーにファイルハスを表示する
;; frame-title-format変数にフォーマットを追加します。
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

;; 行番号を表示
;(global-linum-mode t)

;; 各メシャーモートのインテントサイス
;(setq js-indent-level 4)
;(setq cperl-indent-level 4)

;; (when (require 'color-theme nil t)
;;   ;; テーマを読み込むための設定
;;   (color-theme-initialize))

;; カラーテーマの選択
; M-x color-theme-select
;; カラーテーマの例
; http://gnuemacscolorthemetest.googlecode.com/svn/html/index-c.html
(when (require 'color-theme nil t)
  ;; テーマを読み込むための設定
  (color-theme-initialize)
  ;; テーマを変更する
  (color-theme-dark-laptop)
  ;;(color-theme-wheat)
;;  (color-theme-arjen)
;;  (color-theme-billw)
;;  (color-theme-arjen)
  )
;; いい感しの
;; Wheat Billw Midnight dark-laptop

;; paren-mode 対応する括弧を強調して表示する
;; 表示まての秒数。初期値は0.125
(setq show-paren-delay 0.125)
;; 有効化
(show-paren-mode t)
;; parenのスタイル: expression は括弧内も強調表示
;;(setq show-paren-style 'expression)
;; mixed だと画面内に収まらない時にカッコ内も表示する
(setq show-paren-style 'mixed)

;; フェイス（後述）を変更する
(set-face-background 'show-paren-match-face "DeepPink")
;;(set-face-background 'show-paren-match-face nil)
;;(set-face-underline-p 'show-paren-match-face "yellow")
;;(set-face-underline-p 'show-paren-match-face t)
;;(setq show-paren-match-face 'underline)

;; 　Emacsてはシンタックスハイライトや警告どの
;; 表示を色分けしてくれますか、この色分けはフェイ
;; スと呼はれます。フェイスには文字色や背景色、字
;; 体と下線を設定てきます。利用てきるカラーは、M-x
;; list-colors-display RETて一覧を見ることかてき
;; ます。フェイス設定用関数一覧は表1のとおりてす。

;; リージョンの色を変更
;(set-face-background 'region "darkgreen")

;; (set-face-foreground FACE COLOR) 文字色を変更
;; (set-face-background FACE COLOR) 背景色を変更
;; (set-face-background FACE nil) 背景色なし
;; (set-face-bold-p FACE t) 太字にする
;; (set-face-bold-p FACE nil) 太字をやめる
;; (set-face-italic-p FACE t) 斜体にする
;; (set-face-italic-p FACE nil) 斜体をやめる
;; (set-face-underline-p FACE t) 下線を表示
;; (set-face-underline-p FACE nil) 下線を消す

(defface my-hl-line-face
  ;; 背景かdarkならは背景を黒に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景かlightならは背景色を緑に
    (((class color) (background light))
     (:background "NavyBlue" t))
    (t (:bold t)))
  "hl-line's my face")
;; (defface my-hl-line-face
;;   ;; 背景かdarkならは背景を黒に
;;   '((((class color) (background dark))
;;      (:background "NavyBlue" :underline t))
;;     ;; 背景かlightならは背景色を緑に
;;     (((class color) (background light))
;;      (:background "LightGoldenrodYellow" t))
;;     (t (:bold t)))
;;   "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)

;; 現在行をハイライト表示
(global-hl-line-mode t)

;; 　Emacsは23.1から1文字単位てフォントを指定て
;; きるようになりました。たたし、そのためのインタ
;; フェースはなく、設定は難しいと言われています。
;; てすか、ホイントさえつかめは意外と簡単てす。
;; 　*scratch* ハッファて(prin1 (font-familylist))
;; をC-jすると、Emacsて利用可能なフォント
;; 名一覧か出力されます（図3）。
;; 　フォントを設定する簡単な方法は次のとおりてす。

;; 英語フォントを指定
;; 　set-face-attributeを使って、利用可能なフォントか
;; ら指定します。:heightはフォントサイスてす。
;; acii フォントをMenloに
;(set-face-attribute 'default nil
;		    :family "Menlo"
;		    :height 120)

;; 日本語フォントを指定する
;; 　set-fontset-fontとfont-specを使って日本語フォン
;; トを指定します。
;; 日本語フォントをヒラキノ明朝ProNに
;(set-fontset-font
; nil 'japanese-jisx0208
; (font-spec :family "Hiragino_Mincho_ProN"))

;; 　また、漢字以外の全角文字たけフォントを変える
;; ことかてきます。筆者はひらかなとカタカナをモト
;; ヤシータ注10にしています。設定方法は、日本語を変
;; 更したあとにひらかなたけ別のフォントて上書きす
;; る形てす。指定にはUnicodeの符号を利用します。
;; ひらかなとカタカナをモトヤシータに
;; U+3000-303F CJKの記号およひ句読点
;; U+3040-309F ひらかな
;; U+30A0-30FF カタカナ
; (set-fontset-font
;  nil '(#x3040 . #x30ff)
;  (font-spec :family "NfMotoyaCedar"))

;; フォントの横幅を調節する
;; 　半角と全角を1:2にしたけれは、face-font-rescalealist
;; を調節しましょう。
; (setq face-font-rescale-alist
;       '((".*Menlo.*" . 1.0)
; 	(".*Hiragino_Mincho_ProN.*" . 1.2)
; 	(".*nfmotoyacedar-bold.*" . 1.2)
; 	(".*nfmotoyacedar-medium.*" . 1.2)
; 	("-cdac$" . 1.3)))

;; 　Emacsの設定はinit.elファイルにElispを書くとい
;; う方式てあり、一見すれは敷居か高いかもしれませ
;; ん。てすか、Emacsには変数や関数を調へる機能か
;; あるため、それらを使いこなすことて何をとうすれ
;; は設定てきるのかを知ることかてきます。本特集て
;; 紹介したものは一部にすきませんのて、気になるこ
;; とかあれは「ますはaproposコマントて調へてみる」
;; という癖を身につけましょう。

;; -----------------------------------------------------------------------------
;; 　Emacsには標準てoccurという検索にマッチした
;; 行を一覧表示してくれるコマントかあります。その
;; occurをマルチハッファ対応、操作性や可読性の向上
;; なとあらゆる面て使いやすくなるよう開発されたの
;; かcolor-moccurてす。検索結果を直接編集可能にす
;; るmoccur-editも同時に利用することをお勧めします。
;(install-elisp
; "http://www.emacswiki.org/emacs/download/color-moccur.el")
;(install-elisp
; "http://www.emacswiki.org/emacs/download/moccur-edit.el")
(when (require 'color-moccur nil t)
  ;; クローハルマッフにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スヘース区切りてAND検索
  (setq moccur-split-word t)
  ;; ティレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (require 'moccur-edit nil t)
  ;; Migemoを利用てきる環境てあれはMigemoを使う
  (when (and (executable-find "cmigemo")
	     (require 'migemo nil t))
    (setq moccur-use-migemo t)))

;; 　M-x moccur RETを実行すると、ミニハッファて
;; List lines matching regexp: と聞かれますのて、
;; 検索したい文字列を入力して確定します。すると
;; *Moccur*ハッファか開かれ、検索文字列にマッチ
;; した行か一覧表示されます（図1）。
;; 　*Moccur*上て行移動すると、分割されたハッフ
;; ァに対応する行の周辺か表示されます。もちろん、
;; RETてその行へシャンフてきます。
;; 　併せてmoccur-editを利用するとrを押すことて、
;; 検索結果を直接編集てきるようになります。C-c C-c
;; かC-x C-s（moccur-edit-finish-edit）を押すと、編
;; 集内容かハッファへと反映されます。てすか、また
;; 保存はされていないのて、あとてちゃんと保存しま
;; しょう。なお、編集はC-c C-uて破棄てきます。
;; 　いちいち保存するのか面倒な場合は、次の設定を
;; init.elに記述することによって編集の終了と同時に
;; ファイルへ保存します。

;(defadvice moccur-edit-change-file
;  (after save-after-moccur-edit-buffer activate)
;  (save-buffer))

;; 主なmoccurコマント
; occur-by-moccur カレントハッファてmoccur
; moccur すへてのハッファへmoccur
; dmoccur 指定ティレクトリに対してmoccur
; moccur-grep moccurを使ったgrep検索

;; -----------------------------------------------------------------------------
;(install-elisp "http://www.emacswiki.org/emacs/download/grep-edit.el")
(require 'grep-edit)
;; 　M-x grep、M-x lgrep、M-x rgrep から検
;; 索を実行します。moccur-editと違い、すて
;; に直接編集てきるようになっています。M-%
;; （query-replace）なとの置換コマントを利用
;; するとさらに便利てしょう。

;; -----------------------------------------------------------------------------

;; successfully installed!
;; Add the following code to your .emacs:
(require 'auto-complete-config)
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories
	       "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-i") 'auto-complete)
  (setq ac-auto-start 5)
  (ac-config-default))
(global-set-key (kbd "M-i") 'auto-complete)

;; 補完候補について
;; 　auto-complete-modeの補完候補は、ソースと呼ば
;; れる情報源（辞書のようなもの）によって管理されて
;; います。ソースを無造作に増やし過きると動が重く
;; くなってしまうのですが、auto-complete-configでは
;; 各メジャーモードにによってソースを限ることで
;; PerlにはPerlの、CSSにはCSSに適した補完候補を
;; 表示してくれます。
;; 　なお、テフォルトはac-source-words-in-samemode-
;; buffersという編集中のバッファと
;; ーモードのバッファ内の単語を補完候補にするソー
;; スがセットされています。

;; -----------------------------------------------------------------------------
;(install-elisp
;  "http://github.com/imakado/emacs-smartchr/raw/master/smartchr.el")
;(when (require 'smartchr nil t)
;  (define-key global-map
;    (kbd "=") (smartchr '("=" " = " " == " " === "))))

;; 代表的な使い方
;; 　smartchrの基本的な利用法は、キーバインドに入
;; 力したい文字をリストて登録するたけてす。ホイン
;; トとしては、上記の例は=キーを繰り返しタイプす
;; ることて"="と" = "と"  =  "と"  ==  "かサイクル
;; します。この拡張の一番良いところは標準の入力を
;; 汚さすに特殊な入力も実現てきるという点てしょう。

;; -----------------------------------------------------------------------------
;; 　M-x auto-install-batch RETしExtension name:
;; anything RETてanything関連のElisp群かタウンロ
;; ートされます。タウンロートか完了すると、インス
;; トールするかとうかを聞かれますのてC-c C-cてイ
;; ンストールしてきましょう。

(require 'anything-startup)

;; リスト１
;;; anything
;; (auto-install-batch "anything")
(when (require 'anything nil t)
  (define-key global-map (kbd "\C-x b") 'anything)
  (define-key global-map (kbd "\C-x \C-b") 'anything)
  (setq
   ;; 候補を表示するまでの時間。デフォルトは0.5
   anything-idle-delay 0.3
   ;；タイプして再描画するまでの時間。デフォルトは0.1
   anything-input-idle-delay 0.2
   ;; 候補の最大表示数。デフォルトは50
   anything-candidate-number-limit 100
   ;; 候補が多い時に体感速度を早くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   anything-enable-shortcuts 'alphabet)
  (when (require 'anything-config nil t)
    ;; root権限でアクションを実行するときのコマンド
    ;; デフォルトは"su"
    (setq anything-su-or-sudo "sudo"))
  (require 'anything-match-plugin nil t)
  (and (equal current-language-environment "Japanese")
       (executable-find "cmigemo")
       (require 'anything-migemo nil t))
  (when (require 'anything-complete nil t)
    ;; M-xによる補完をAnythingて行う
    ;; (anything-read-string-mode 1) ←
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 150))
  (require 'anything-show-completion nil t)
  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))
  (when (require 'descbinds-anything nil t)
    ;; describe-bindingsをAnythingに置き換える
    (descbinds-anything-install))
  (require 'anything-grep nil t))

;; 　manやinfoなとトキュメントを検索するための
;; Anythingコマントを作成してみましょう。ますは、
;; トキュメント検索に関連するソースのリストを作成
;; します。
(setq anything-for-document-sources
      (list
       anything-c-source-man-pages
       anything-c-source-info-cl
       anything-c-source-info-pages
       anything-c-source-info-elisp
       anything-c-source-apropos-emacs-commands
       anything-c-source-apropos-emacs-functions
       anything-c-source-apropos-emacs-variables))
;; 　コマントを起動したときにカーソル位置に単語か
;; あれは、その単語をすてに絞り込んた状態て表示て
;; きれは便利てす。そういったニースも、anything関
;; 数の第2引数に(thing-at-point 'symbol)を与える
;; ことて簡単に実現てきます。
(defun anything-for-document ()
  "Preconfigured `anything' for anything-for-document."
  (interactive)
  (anything anything-for-document-sources
	    (thing-at-point 'symbol) nil nil nil
	    "*anything for document*"))
;; 　これて、M-x anything-for-documentて、カーソ
;; ルかある単語を即座にトキュメント検索てきるコマ
;; ントか作成てきました。頻繁に利用するのてあれは
;; これをキーハイントに割り当てることて、さらに便
;; 利に使えるようになります。筆者はs-dに割り当て
;; て利用しています（図4）。
;; 　このコマントの便利なところは、manやEmacs
;; のinfoトキュメント、aproposコマントによるElisp
;; 関数や変数のすへてのトキュメントを串刺し検索て
;; きるところてす（図5）。

;; anything-show-kill-ring：キルリンクをヒシュ
;; アライス
;; 　Emacsは過去にC-kやC-wて消去した文字をキル
;; リンクと呼はれる場所に保存しています。M-x
;; anything-show-kill-ringを利用すると、キルリン
;; クを一覧表示てきるため（図6）、標準のC-y M-yよ
;; りも格段に使い勝手に優れます。

;; anything-resume：Anythingの結果を
;; リシューム
;; 　Anythingを利用して絞り込みをかけた結果
;; を再度利用したい場合、anything-resumeか
;; 役に立ちます。M-x anything-resumeすると、
;; 直前に利用したAnythingコマントの結果を再
;; 現してくれます。

;; anything-query-replace-regexp：
;; 絞り込み表示してから置換
;; 　正規表現を利用して対話的に置換てきるqueryreplace-
;; regexpコマントは便利てすか、置換か始ま
;; るまてとの文字に置換されるかわかりません。
;; anything-query-replace-regexpは置換対象を先に絞
;; り込んて確認てきるため、正規表現のミスをなくす
;; ことかてきます。

;; describe-bindings C-h b
;; 　descbinds-anything.elをインストールしたうえて、
;; リスト1 の設定(descbinds-anything-install) を
;; 有効にしていると、C-h bによるキーハイント一覧
;; 表示かAnythingインタフェースに置き換わります。
;; 　関数名やキーハイントから絞り込みかてきるため、
;; describe-bindingsを起動して、たとえはmarkを入
;; 力すると、コマント名にmarkを含むキーハイント
;; たけを見ることかてきます。なお、そのまま選択す
;; るとコマントか実行されます。


;; anything-project：フロシェクトからファイル
;; を絞り込み
;; 　開発中はフロシェクトの中からファイルを開くこ
;; とか頻繁にあります。anything-projectはGitなとて
;; 管理されているフロシェクトからファイル一覧を取
;; 得してくれます。リスト2のように設定して利用し
;; ます。
;(install-elisp "http://github.com/imakado/anything-project/raw/master/anything-project.el")
(when (require 'anything-project nil t)
  (global-set-key (kbd "C-c C-f") 'anything-project)
  ;; 検索対象から除外するフィルタ
  (setq ap:project-files-filters
	(list
	 (lambda (files)
	   (remove-if 'file-directory-p files)
	   (remove-if '(lambda (file) (string-match-p "~$" file)) files)))))

;; anything-c-moccur：Moccurの
;; Anythingインタフェース
;; 　検索、絞り込みはAnythingとたいへん相性の良い
;; 操作てす。ハッファから文字列を検索するMoccur
;; はAnythingによってさらに便利になります。リスト
;; 3のように設定して利用します。
;(install-elisp "http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el")
(when (require 'anything-c-moccur nil t)
  (setq
   ;; anything-c-moccur用 `anything-idle-delay'
   anything-c-moccur-anything-idle-delay 0.1
   ;; ハッファの情報をハイライトする
   lanything-c-moccur-higligt-info-line-flag t
   ;; 現在選択中の候補の位置をほかのwindowに表示する
   anything-c-moccur-enable-auto-look-flag t
   ;; 起動時にホイントの位置の単語を初期ハターンにする
   anything-c-moccur-enable-initial-pattern t)
  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))

;; -----------------------------------------------------------------------------
;; flymake-mode
;; -----------------------------------------------------------------------------
(when (require 'flymake nil t)
  (global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)
  (set-face-background 'flymake-errline "Red")
  ;(set-face-underline-p 'flymake-errline t)
  (set-face-underline-p 'flymake-errline nil)
  ;; PHP
  (when (not (fboundp 'flymake-php-init))
    (defun flymake-php-init ()
      (let* ((temp-file (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
             (local-file (file-relative-name
                          temp-file
                          (file-name-directory buffer-file-name))))
        (list "php" (list "-f" local-file "-l"))))
    (setq flymake-allowed-file-name-masks
          (append
           flymake-allowed-file-name-masks
           '(("\.php[345]?$" flymake-php-init))))
    (setq flymake-err-line-patterns
          (cons
           '("\(\(?:Parse error\|Fatal error\|Warning\): .*\) in \(.*\) on line \([0-9]+\)" 2 3 nil 1)
           flymake-err-line-patterns)))
;;   ;; JavaScript
;;   (when (not (fboundp 'flymake-javascript-init))
;;     (defun flymake-javascript-init ()
;;       (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                          'flymake-create-temp-inplace))
;;              (local-file (file-relative-name
;;                           temp-file
;;                           (file-name-directory buffer-file-name))))
;;         (list "/usr/local/bin/jsl" (list "-process" local-file))))
;;     (setq flymake-allowed-file-name-masks
;;           (append
;;            flymake-allowed-file-name-masks
;;            '(("\.json$" flymake-javascript-init)
;;              ("\.js$" flymake-javascript-init))))
;;     (setq flymake-err-line-patterns
;;           (cons
;;            '("\(.+\)(\([0-9]+\)): \(?:lint \)?\(\(?:Warning\|SyntaxError\):.+\)" 1 2 nil 3)
;;            flymake-err-line-patterns)))
;;   ;; Ruby
;;   (when (not (fboundp 'flymake-ruby-init))
;;     (defun flymake-ruby-init ()
;;       (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                          'flymake-create-temp-inplace))
;;              (local-file (file-relative-name
;;                           temp-file
;;                           (file-name-directory buffer-file-name))))
;;         '("ruby" '("-c" local-file)))))
  ) ; END OF when require 'flymake nil t

(add-hook 'php-mode-hook
	  '(lambda () (flymake-mode t)))
;;   (add-hook 'js-mode-hook
;;             '(lambda () (flymake-mode t)))
;;   (add-hook 'ruby-mode-hook
;;             '(lambda () (flymake-mode t))))

;; -----------------------------------------------------------------------------
;; cd ~/.emacs.d/elisp/
;; git clone https://github.com/mitsuo-saito/auto-highlight-symbol-mode.git
(require 'auto-highlight-symbol)
(global-auto-highlight-symbol-mode t)

;; -----------------------------------------------------------------------------
;; Emacsから本格的にシェルを使う
;; 　Emacsて本格的にシェルを利用している人の多く
;; は、Emacs標準搭載のターミナルエミュレータansiterm
;; を使用しています。てすか、ansi-termはEmacs
;; 標準のキーハイントを奪ってしまうため、ansi-term
;; に機能を加えたmulti-termの導入をお勧めします。
;(install-elisp
; "http://www.emacswiki.org/emacs/download/multi-term.el")
;; 設定例
;; 　multi-termを読み込んた後、お好みのシェルを設
;; 定するたけてす。
(when (require 'multi-term nil t)
  (setq multi-term-program "/bin/bash"))
;; 代表的な使い方
;; 　M-x multi-term RETを実行するとEmacsのハッ
;; ファにターミナルか開きます。まるて本当のターミ
;; ナルにいるかのようにシェルを使うことかてきます。
;; 　multi-termは、実行のたひに新たなシェルを開く
;; ことかてき、GNU Screenの代わりとしても利用て
;; きます。

;; -----------------------------------------------------------------------------
;; Tramp：Emacsから
;; サーハのファイルを直接編集
;; 　Emacsは標準てSSHやFTPを使って直接サーハの
;; ファイルを編集てきます。
;; SSHを使った接続
;; 　C-x C-f（find-file）から/sshx:ユーサ名@ホスト
;; 名:と入力していくと、そのままサーハに接続され、
;; まるてローカルファイルのように扱うことかてきま

;; ---------------------------------------------------------
;; 自慢の.emacsを貼り付けるスレ
;; ---------------------------------------------------------
;;
;; スタートアッフメッセーシを表示しない
;(setq inhibit-startup-message t)

;; emacs 終了時に確認する。
(if (eq emacs-major-version 21)
    (setq confirm-kill-emacs 'yes-or-no-p)
  (defun my-save-buffers-kill-emacs ()
    (interactive)
    (if (yes-or-no-p "quit emacs? ")
	(save-buffers-kill-emacs)))
  (global-set-key "\C-x\C-c" 'my-save-buffers-kill-emacs))

;; 保存時に余計な空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;C-x bてbuffersを選ふ時便利
;;older than Emacs 21
;; (iswitchb-default-keybindings)
;;Emacs 21 or newer
(iswitchb-mode 1)

;; ハッファを切り替えるのに C-x C-b て electric-buffer-list を使う。
; (global-set-key "\C-x\C-b" 'electric-buffer-list)

;; ステータスラインに時間を表示する
(display-time)

;; 時間表示
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq display-time-string-forms
      '(month "/" day "(" dayname ") " 24-hours ":" minutes))
(display-time)

;; 行番号・桁番号をモートラインに表示する
(line-number-mode t)
(column-number-mode t)

;; 画面から出たとき一行たけスクロールさせる
(setq scroll-conservatively 1)

;; ハッファの最後の行て next-line しても新しい行を作らない
(setq next-line-add-newlines nil)

;; ハッファの最初の行て previous-line しても、
;; "beginning-of-buffer" と注意されないようにする。
(defun previous-line (arg)
  (interactive "p")
  (if (interactive-p)
      (condition-case nil
	  (line-move (- arg))
	((beginning-of-buffer end-of-buffer)))
    (line-move (- arg)))
  nil)

;; hoge.txt~ みたいなハックアッフファイルを作らないようにする
; (setq backup-inhibited t)

;; c-mode その他て色か付くようにする
(global-font-lock-mode t)

;; 検索とかリーションを色付きに。
(setq transient-mark-mode t)
(setq search-highlight t)
(setq query-replace-highlight t)

(set-face-foreground 'region "black")
(set-face-background 'region "pink")

;; C-tて別のウィントウに切り替える
(global-set-key (kbd "C-x C-o") 'other-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GNU GLOBAL(gtags)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'gtags)
(autoload 'gtags-mode "" t)
(setq gtags-mode-hook
      '(lambda ()
         (define-key gtags-mode-map "\C-cs" 'gtags-find-symbol)
         (define-key gtags-mode-map "\C-cr" 'gtags-find-rtag)
         (define-key gtags-mode-map "\C-ct" 'gtags-find-tag)
         (define-key gtags-mode-map "\C-cf" 'gtags-parse-file)))

(global-set-key (kbd "M-p") 'gtags-pop-stack)

(add-hook 'php-mode-hook
	  (lambda ()
	    (gtags-mode t)
	    ))


; gtags auto update
(defun update-gtags (&optional prefix)
  (interactive "P")
  (let ((rootdir (gtags-get-rootpath))
        (args (if prefix "-v" "-iv")))
    (when rootdir
      (let* ((default-directory rootdir)
             (buffer (get-buffer-create "*update GTAGS*")))
        (save-excursion
          (set-buffer buffer)
          (erase-buffer)
          (let ((result (process-file "gtags" nil buffer nil args)))
            (if (= 0 result)
                (message "GTAGS successfully updated.")
              (message "update GTAGS error with exit status %d" result))))))))
(add-hook 'after-save-hook 'update-gtags)

;; tag jump
(require 'anything-gtags)
;; Test1.ccを開いているときに、M-r (gtags-find-rtag) などで同じディレクトリにある
;; Test2.ccに飛びたいのに、src/src/Test2.ccという空のファイルが開く。どうもパス
;; 表示がgtagsを実行したディレクトリからになっているみたい。
;; "gtags-path-style"のデフォルト値"root"から、"relative"もしくは"absolute"にす
;; ればよい。relativeの方が見やすいと思う。
(setq gtags-path-style 'relative)

;; (define-key global-map (kbd "C-x t")
;;   (lambda ()
;;     "Tag jump using etags, gtags and `anything'."
;;     (interactive)
;;     (let* ((initial-pattern (regexp-quote (or (thing-at-point 'symbol) ""))))
;;       (anything (list anything-c-source-gtags-select
;;  		      anything-c-source-etags-select))
;;       "Find Tag: " nil)))

;; (defmacro my-let-env (environments &rest body)
;;   `(let ((process-environment process-environment))
;;      ,@(mapcar (lambda (env) `(setenv ,@env)) environments)
;;      (progn ,@body)))

;; (defun anything-c-source-gtags-select-with-root (name gtagsroot)
;;   (lexical-let ((gtagsroot (expand-file-name gtagsroot)))
;;     `((name . ,name)
;;       (init
;;        . ,(lambda ()
;; 	    (my-let-env
;; 	     (("GTAGSROOT" gtagsroot))
;; 	     (call-process-shell-command
;; 	      "global -c" nil (anything-candidate-buffer 'global)))))
;;       (candidates-in-buffer)
;;       (action
;;        ("Goto the location"
;; 	. ,(lambda (candidate)
;; 	     (my-let-env
;; 	      (("GTAGSROOT" gtagsroot))
;; 	      (gtags-push-context)
;; 	      (gtags-goto-tag candidate ""))))
;; 	 ("Goto the location (other-window)"
;; 	  . ,(lambda (candidate)
;; 	       (my-let-env
;; 		(("GTAGSROOT" gtagsroot))
;; 		(gtags-push-context)
;; 		(gtags-goto-tag candidate "" t))))
;; 	 ("Move to the referenced point"
;; 	  . ,(lambda (candidate)
;; 	       (my-let-env
;; 		(("GTAGSROOT" gtagsroot))
;; 		(gtags-push-context)
;; 		(gtags-goto-tag candidate "r"))))))))

;; -----------------------------------------------------------------------------
;; php-mode
;; -----------------------------------------------------------------------------
(require 'php-mode)
(add-hook 'php-mode-hook
         (lambda ()
             (require 'php-completion)
             (php-completion-mode t)
             (define-key php-mode-map "\C-o" 'phpcmp-complete)
	     (define-key php-mode-map "\C-cb" 'geben-set-breakpoint-line)
             (when (require 'auto-complete nil t)
	       (make-variable-buffer-local 'ac-sources)
	       (add-to-list 'ac-sources 'ac-source-php-completion)
	       (auto-complete-mode t))
	     (setq tab-width 4)
	     (setq indent-tabs-mode nil)
	     (c-toggle-hungry-state t)
	     (c-set-offset 'case-label' 4)
	     (c-set-offset 'arglist-intro' 4)
	     (c-set-offset 'arglist-close' 0)
	     ;; pear style
	     (setq tab-width 4
		   c-basic-offset 4
		   c-hanging-comment-ender-p nil
		   indent-tabs-mode nil)
	     ))

(add-hook 'php-mode-user-hook
	  '(lambda ()
	     (setq php-manual-path "~/share/doc/php/xhtml/")
	     (setq php-search-url "http://www.php.net/ja/")
	     (setq php-manual-url "http://www.php.net/manual/ja/")
	     ))

(autoload 'geben "geben" "PHP Debugger on Emacs" t)
(autoload 'geben-set-breakpoint-line "geben" "Set a breakpoint at the current line." t)
(setq geben-dbgp-default-port 9005)

(add-hook 'javascript-mode-hook
         (lambda ()
             (when (require 'auto-complete nil t)
	       (make-variable-buffer-local 'ac-sources)
	       (auto-complete-mode t))
	     (setq tab-width 4)
	     (setq indent-tabs-mode nil)
	     (c-toggle-hungry-state t)
	     (c-set-offset 'case-label' 2)
	     (c-set-offset 'arglist-intro' 2)
	     (c-set-offset 'arglist-close' 0)
	     (setq tab-width 2
		   c-basic-offset 2
		   c-hanging-comment-ender-p nil
		   indent-tabs-mode nil)
	     ))

;; -----------------------------------------------------------------------------
;; javascript mode
;; -----------------------------------------------------------------------------
(require 'js2-mode)
(add-hook 'js2-mode-hook
	  (lambda ()
	    (when (require 'auto-complete nil t)
	      (make-variable-buffer-local 'ac-sources)
	      (auto-complete-mode t))
	    (setq tab-width 2)
	    (setq indent-tabs-mode nil)
	    (c-toggle-hungry-state t)
	    (c-set-offset 'case-label' 2)
	    (c-set-offset 'arglist-intro' 2)
	    (c-set-offset 'arglist-close' 0)
	    (setq tab-width 2
		  c-basic-offset 2
		  c-hanging-comment-ender-p nil
		  indent-tabs-mode nil)
	    ))

;; -----------------------------------------------------------------------------
;; run-script.el
;; -----------------------------------------------------------------------------
;;(autoload 'run-script "run-script")
;;(require 'run-script)
;;(add-hook 'cperl-mode-hook
;;	  (lambda ()
;;	    (setq run-script-command "perl")
;;	    (setq run-script-switch "-w")
;;	    (define-key cperl-mode-map "\M-p" 'run-script))

;; -----------------------------------------------------------------------------
;; dsvn.el
;; -----------------------------------------------------------------------------
;(autoload 'svn-status "dsvn" "Run `svn status'." t)
;(autoload 'svn-update "dsvn" "Run `svn update'." t)

;; -----------------------------------------------------------------------------
;; psvn.el
;; -----------------------------------------------------------------------------
;(require 'psvn)
;(setq svn-status-verbose nil)
;(setq svn-status-hide-unmodified t)
;; ログにファイル名を出さない
;(setq svn-status-default-log-arguments nil)
;; プレフィクスをC-x sにする
;(global-set-key (kbd "C-x s") svn-global-keymap)

;; -----------------------------------------------------------------------------
;; yaml-mode
;; -----------------------------------------------------------------------------
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;; -----------------------------------------------------------------------------
;; smarty-mode
;; -----------------------------------------------------------------------------
(autoload 'smarty-mode "smarty-mode" "Smarty Mode" t)
(setq smarty-left-delimiter "({")
(setq smarty-right-delimiter "})")

;; -----------------------------------------------------------------------------
;; coffee mode
;; -----------------------------------------------------------------------------
(require 'coffee-mode)
(setq whitespace-action '(auto-cleanup)) ;; automatically clean up bad whitespace
(setq whitespace-style '(trailing space-before-tab indentation empty space-after-tab)) ;; only show bad whitespace

(defun coffee-custom ()
  "coffee-mode-hook"

  ;; CoffeeScript uses two spaces.
  ;(make-local-variable 'tab-width)
  ;(set 'tab-width 2)

  ;; code style
  (setq tab-width 2)
  (setq indent-tabs-mode nil)
  (c-toggle-hungry-state t)
  (c-set-offset 'case-label' 2)
  (c-set-offset 'arglist-intro' 2)
  (c-set-offset 'arglist-close' 0)
  (setq tab-width 2
	c-basic-offset 2
	c-hanging-comment-ender-p nil
	indent-tabs-mode nil)


  ;; If you don't want your compiled files to be wrapped
  (setq coffee-args-compile '("-c" "--bare"))

  ;; Emacs key binding
  (define-key coffee-mode-map [(meta r)] 'coffee-compile-buffer)

  ;; Riding edge.
  ;;(setq coffee-command "~/dev/coffee")

  ;; Compile '.coffee' files on every save
  (and (file-exists-p (buffer-file-name))
       (file-exists-p (coffee-compiled-file-name))
       (coffee-cos-mode t))

  )

(add-hook 'coffee-mode-hook 'coffee-custom)

;; -----------------------------------------------------------------------------
;; 関連付けとか
;; -----------------------------------------------------------------------------
(setq auto-mode-alist
      (append (list
	       '("\\.php$"	.	php-mode)
	       '("\\.sql$"	.	sql-mode)
	       '("\\.tpl$"	.	smarty-mode)
	       '("\\.el$"	.	lisp-mode)
	       '("\\.yaml$"	.	yaml-mode)
	       '("\\.js$"	.	js2-mode)
	       '("\\.coffee$"	.	coffee-mode)
	       auto-mode-alist)))

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; vc
(setq diff-switches "-w")

;; C-h で BS
(global-set-key "\C-h" 'delete-backward-char)

;; 折り返し表示をトグル
(defun toggle-truncate-lines ()
  "折り返し表示をトグル"
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  (recenter))

(setq truncate-partial-width-windows t)
(global-set-key "\C-c \C-l" 'toggle-truncate-lines)

;; -----------------------------------------------------------------------------
;; CEDET
;; -----------------------------------------------------------------------------
; (load-library "cedet")
; (global-ede-mode 1)
; (semantic-mode 1)

;; -----------------------------------------------------------------------------
;; window manager
;; -----------------------------------------------------------------------------
;(require 'e2wm)
;(global-set-key (kbd "M-+") 'e2wm:start-management)

;; -----------------------------------------------------------------------------
;; popup.el
;; -----------------------------------------------------------------------------
;(auto-install-from-url "https://raw.github.com/m2ym/popwin-el/master/popwin.el")
(require 'popwin)
(setq display-buffer-function 'popwin:display-buffer)

;; anything
(setq anything-samewindow nil)
(push '("*anything*" :height 30) popwin:special-display-config)

;; ispell
(setq ispell-program-name "aspell")
