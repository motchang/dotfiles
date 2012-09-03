;load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
 (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))
;; elispとconfディレクトリをサブディレクトリごとload-pathに追加
(add-to-load-path "elisp" "conf")

;; -----------------------------------------------------------------------------
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  ;; インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWiki に登録されている elisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))

;; ここでC-x C-eとタイプして
;; みましょう。Emacsを再起動せずとも設定が即座に
;; 反映されます。C-x C-eはeval-last-sexpにバインド
;; されており、式を評価してその戻り値をミニバッフ
;; ァに返します。

;; -----------------------------------------------------------------------------
;; installed
;;(install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")

;; ・C-h a 文字列 RET
;; 　入力した文字列が含まれているコマンドのリスト
;; を表示する（M-x command-apropos）。例：autoinstall
;; という文字列が含まれるコマンドを調べる
;; ➡C-h a auto-install RET

;; ・C-h b
;; 　現在のキーの割り当て表を表示する（M-x
;; describe-bindings）

;; ・C-h k キーバインド
;; 　キーバインドが実行するコマンド（関数）名とその
;; ドキュメントを表示する（M-x describe-key）。例：
;; C-qで実行されるコマンドを調べる➡C-h k C-q

;; ・C-h w コマンド名 RET
;; 　入力したコマンドを実行するキーを表示する（M-x
;; where-is）。例：コマンドquery-replaceのキーバ
;; インドを調べる➡C-h w query-replace RET

;; ・C-h f 関数名 RET
;; 　入力した関数の説明を表示する（M-x describefunction）
;; 。例：関数lambda について調べる
;; ➡C-h f lambda RET

;; ・C-h v 変数名 RET
;; 　入力した変数の説明を表示する（M-x describevariable）
;; 。例：変数load-path について調べる
;; ➡C-h v load-path RET

;; 入力されるキーシーケンスを入れ換える
;; ?\C-?はDELのキーシケンス
;(keyboard-translate ?\C-h ?\C-?)
;; 別のキーバイドにヘルプを割り当てる
;(global-set-key (kbd "C-x ?") 'help-command)

;; -----------------------------------------------------------------------------
;; Mac の文字コードの設定
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

;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)
;; tool-barを非表示。コンソールでは不要
;(tool-bar-mode 0)
;; scroll-barを非表示。コンソールでは不要
;(scroll-bar-mode 0)
;; menu-barを非表示
;(menu-bar-mode 0)

;; メニューバーにファイルパスを表示する
;; frame-title-format変数にフォーマットを追加します。
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

;; 行番号を表示
;(global-linum-mode t)

;; 各メジャーモードのインデントサイズ
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
;; いい感じの
;; Wheat Billw Midnight dark-laptop

;; paren-mode 対応する括弧を強調して表示する
;; 表示までの秒数。初期値は0.125
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

;; 　Emacsではシンタックスハイライトや警告どの
;; 表示を色分けしてくれますが、この色分けはフェイ
;; スと呼ばれます。フェイスには文字色や背景色、字
;; 体と下線を設定できます。利用できるカラーは、M-x
;; list-colors-display RETで一覧を見ることができ
;; ます。フェイス設定用関数一覧は表1のとおりです。

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
  ;; 背景がdarkならば背景を黒に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を緑に
    (((class color) (background light))
     (:background "NavyBlue" t))
    (t (:bold t)))
  "hl-line's my face")
;; (defface my-hl-line-face
;;   ;; 背景がdarkならば背景を黒に
;;   '((((class color) (background dark))
;;      (:background "NavyBlue" :underline t))
;;     ;; 背景がlightならば背景色を緑に
;;     (((class color) (background light))
;;      (:background "LightGoldenrodYellow" t))
;;     (t (:bold t)))
;;   "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)

;; 現在行をハイライト表示
(global-hl-line-mode t)

;; 　Emacsは23.1から1文字単位でフォントを指定で
;; きるようになりました。ただし、そのためのインタ
;; フェースはなく、設定は難しいと言われています。
;; ですが、ポイントさえつかめば意外と簡単です。
;; 　*scratch* バッファで(prin1 (font-familylist))
;; をC-jすると、Emacsで利用可能なフォント
;; 名一覧が出力されます（図3）。
;; 　フォントを設定する簡単な方法は次のとおりです。

;; 英語フォントを指定
;; 　set-face-attributeを使って、利用可能なフォントか
;; ら指定します。:heightはフォントサイズです。
;; acii フォントをMenloに
;(set-face-attribute 'default nil
;		    :family "Menlo"
;		    :height 120)

;; 日本語フォントを指定する
;; 　set-fontset-fontとfont-specを使って日本語フォン
;; トを指定します。
;; 日本語フォントをヒラギノ明朝ProNに
;(set-fontset-font
; nil 'japanese-jisx0208
; (font-spec :family "Hiragino_Mincho_ProN"))

;; 　また、漢字以外の全角文字だけフォントを変える
;; ことができます。筆者はひらがなとカタカナをモト
;; ヤシーダ注10にしています。設定方法は、日本語を変
;; 更したあとにひらがなだけ別のフォントで上書きす
;; る形です。指定にはUnicodeの符号を利用します。
;; ひらがなとカタカナをモトヤシーダに
;; U+3000-303F CJKの記号および句読点
;; U+3040-309F ひらがな
;; U+30A0-30FF カタカナ
; (set-fontset-font
;  nil '(#x3040 . #x30ff)
;  (font-spec :family "NfMotoyaCedar"))

;; フォントの横幅を調節する
;; 　半角と全角を1:2にしたければ、face-font-rescalealist
;; を調節しましょう。
; (setq face-font-rescale-alist
;       '((".*Menlo.*" . 1.0)
; 	(".*Hiragino_Mincho_ProN.*" . 1.2)
; 	(".*nfmotoyacedar-bold.*" . 1.2)
; 	(".*nfmotoyacedar-medium.*" . 1.2)
; 	("-cdac$" . 1.3)))

;; 　Emacsの設定はinit.elファイルにElispを書くとい
;; う方式であり、一見すれば敷居が高いかもしれませ
;; ん。ですが、Emacsには変数や関数を調べる機能が
;; あるため、それらを使いこなすことで何をどうすれ
;; ば設定できるのかを知ることができます。本特集で
;; 紹介したものは一部にすぎませんので、気になるこ
;; とがあれば「まずはaproposコマンドで調べてみる」
;; という癖を身につけましょう。

;; -----------------------------------------------------------------------------
;; 　Emacsには標準でoccurという検索にマッチした
;; 行を一覧表示してくれるコマンドがあります。その
;; occurをマルチバッファ対応、操作性や可読性の向上
;; などあらゆる面で使いやすくなるよう開発されたの
;; がcolor-moccurです。検索結果を直接編集可能にす
;; るmoccur-editも同時に利用することをお勧めします。
;(install-elisp
; "http://www.emacswiki.org/emacs/download/color-moccur.el")
;(install-elisp
; "http://www.emacswiki.org/emacs/download/moccur-edit.el")
(when (require 'color-moccur nil t)
  ;; グローバルマップにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  (require 'moccur-edit nil t)
  ;; Migemoを利用できる環境であればMigemoを使う
  (when (and (executable-find "cmigemo")
	     (require 'migemo nil t))
    (setq moccur-use-migemo t)))

;; 　M-x moccur RETを実行すると、ミニバッファで
;; List lines matching regexp: と聞かれますので、
;; 検索したい文字列を入力して確定します。すると
;; *Moccur*バッファが開かれ、検索文字列にマッチ
;; した行が一覧表示されます（図1）。
;; 　*Moccur*上で行移動すると、分割されたバッフ
;; ァに対応する行の周辺が表示されます。もちろん、
;; RETでその行へジャンプできます。
;; 　併せてmoccur-editを利用するとrを押すことで、
;; 検索結果を直接編集できるようになります。C-c C-c
;; かC-x C-s（moccur-edit-finish-edit）を押すと、編
;; 集内容がバッファへと反映されます。ですが、まだ
;; 保存はされていないので、あとでちゃんと保存しま
;; しょう。なお、編集はC-c C-uで破棄できます。
;; 　いちいち保存するのが面倒な場合は、次の設定を
;; init.elに記述することによって編集の終了と同時に
;; ファイルへ保存します。

;(defadvice moccur-edit-change-file
;  (after save-after-moccur-edit-buffer activate)
;  (save-buffer))

;; 主なmoccurコマンド
; occur-by-moccur カレントバッファでmoccur
; moccur すべてのバッファへmoccur
; dmoccur 指定ディレクトリに対してmoccur
; moccur-grep moccurを使ったgrep検索

;; -----------------------------------------------------------------------------
;(install-elisp "http://www.emacswiki.org/emacs/download/grep-edit.el")
(require 'grep-edit)
;; 　M-x grep、M-x lgrep、M-x rgrep から検
;; 索を実行します。moccur-editと違い、すで
;; に直接編集できるようになっています。M-%
;; （query-replace）などの置換コマンドを利用
;; するとさらに便利でしょう。

;; -----------------------------------------------------------------------------

;; successfully installed!
;; Add the following code to your .emacs:
(require 'auto-complete-config)
(when (require 'auto-complete-config nil t)
  (add-to-list 'ac-dictionary-directories
	       "~/.emacs.d/elisp/ac-dict")
  (define-key ac-mode-map (kbd "M-i") 'auto-complete)
  (setq ac-auto-start 3)
  (ac-config-default))
;;(global-set-key (kbd "M-i") 'auto-complete)

;; 補完候補について
;; 　auto-complete-modeの補完候補は、ソースと呼ば
;; れる情報源（辞書のようなもの）によって管理されて
;; います。ソースを無造作に増やし過ぎると動が重く
;; くなってしまうのですが、auto-complete-configでは
;; 各メジャーモードにによってソースを限ることで
;; PerlにはPerlの、CSSにはCSSに適した補完候補を
;; 表示してくれます。
;; 　なお、デフォルトはac-source-words-in-samemode-
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
;; 力したい文字をリストで登録するだけです。ポイン
;; トとしては、上記の例は=キーを繰り返しタイプす
;; ることで"="と" = "と"  =  "と"  ==  "がサイクル
;; します。この拡張の一番良いところは標準の入力を
;; 汚さずに特殊な入力も実現できるという点でしょう。

;; -----------------------------------------------------------------------------
;; 　M-x auto-install-batch RETしExtension name:
;; anything RETでanything関連のElisp群がダウンロ
;; ードされます。ダウンロードが完了すると、インス
;; トールするかどうかを聞かれますのでC-c C-cでイ
;; ンストールしてきましょう。

;; リスト１
;;; anything
;; (auto-install-batch "anything")
(when (require 'anything nil t)
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
    ;; M-xによる補完をAnythingで行う
    ;; (anything-read-string-mode 1) ←❶
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 150))
  (require 'anything-show-completion nil t)
  (when (require 'auto-install nil t)
    (require 'anything-auto-install nil t))
  (when (require 'descbinds-anything nil t)
    ;; describe-bindingsをAnythingに置き換える
    (descbinds-anything-install))
  (require 'anything-grep nil t))

;; 　manやinfoなどドキュメントを検索するための
;; Anythingコマンドを作成してみましょう。まずは、
;; ドキュメント検索に関連するソースのリストを作成
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
;; 　コマンドを起動したときにカーソル位置に単語が
;; あれば、その単語をすでに絞り込んだ状態で表示で
;; きれば便利です。そういったニーズも、anything関
;; 数の第2引数に(thing-at-point 'symbol)を与える
;; ことで簡単に実現できます。
(defun anything-for-document ()
  "Preconfigured `anything' for anything-for-document."
  (interactive)
  (anything anything-for-document-sources
	    (thing-at-point 'symbol) nil nil nil
	    "*anything for document*"))
;; 　これで、M-x anything-for-documentで、カーソ
;; ルがある単語を即座にドキュメント検索できるコマ
;; ンドが作成できました。頻繁に利用するのであれば
;; これをキーバインドに割り当てることで、さらに便
;; 利に使えるようになります。筆者はs-dに割り当て
;; て利用しています（図4）。
;; 　このコマンドの便利なところは、manやEmacs
;; のinfoドキュメント、aproposコマンドによるElisp
;; 関数や変数のすべてのドキュメントを串刺し検索で
;; きるところです（図5）。

;; anything-show-kill-ring：キルリングをビジュ
;; アライズ
;; 　Emacsは過去にC-kやC-wで消去した文字をキル
;; リングと呼ばれる場所に保存しています。M-x
;; anything-show-kill-ringを利用すると、キルリン
;; グを一覧表示できるため（図6）、標準のC-y M-yよ
;; りも格段に使い勝手に優れます。

;; anything-resume：Anythingの結果を
;; リジューム
;; 　Anythingを利用して絞り込みをかけた結果
;; を再度利用したい場合、anything-resumeが
;; 役に立ちます。M-x anything-resumeすると、
;; 直前に利用したAnythingコマンドの結果を再
;; 現してくれます。

;; anything-query-replace-regexp：
;; 絞り込み表示してから置換
;; 　正規表現を利用して対話的に置換できるqueryreplace-
;; regexpコマンドは便利ですが、置換が始ま
;; るまでどの文字に置換されるかわかりません。
;; anything-query-replace-regexpは置換対象を先に絞
;; り込んで確認できるため、正規表現のミスをなくす
;; ことができます。

;; describe-bindings C-h b
;; 　descbinds-anything.elをインストールしたうえで、
;; リスト1 の設定(descbinds-anything-install) を
;; 有効にしていると、C-h bによるキーバインド一覧
;; 表示がAnythingインタフェースに置き換わります。
;; 　関数名やキーバインドから絞り込みができるため、
;; describe-bindingsを起動して、たとえばmarkを入
;; 力すると、コマンド名にmarkを含むキーバインド
;; だけを見ることができます。なお、そのまま選択す
;; るとコマンドが実行されます。


;; anything-project：プロジェクトからファイル
;; を絞り込み
;; 　開発中はプロジェクトの中からファイルを開くこ
;; とが頻繁にあります。anything-projectはGitなどで
;; 管理されているプロジェクトからファイル一覧を取
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
;; 操作です。バッファから文字列を検索するMoccur
;; はAnythingによってさらに便利になります。リスト
;; 3のように設定して利用します。
;(install-elisp "http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el")
(when (require 'anything-c-moccur nil t)
  (setq
   ;; anything-c-moccur用 `anything-idle-delay'
   anything-c-moccur-anything-idle-delay 0.1
   ;; バッファの情報をハイライトする
   lanything-c-moccur-higligt-info-line-flag t
   ;; 現在選択中の候補の位置をほかのwindowに表示する
   anything-c-moccur-enable-auto-look-flag t
   ;; 起動時にポイントの位置の単語を初期パターンにする
   anything-c-moccur-enable-initial-pattern t)
  (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))

;; -----------------------------------------------------------------------------
(when (require 'flymake nil t)
  (global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)
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

;;   (add-hook 'php-mode-hook
;;             '(lambda () (flymake-mode t)))
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
;; 　Emacsで本格的にシェルを利用している人の多く
;; は、Emacs標準搭載のターミナルエミュレータansiterm
;; を使用しています。ですが、ansi-termはEmacs
;; 標準のキーバインドを奪ってしまうため、ansi-term
;; に機能を加えたmulti-termの導入をお勧めします。
;(install-elisp
; "http://www.emacswiki.org/emacs/download/multi-term.el")
;; 設定例
;; 　multi-termを読み込んだ後、お好みのシェルを設
;; 定するだけです。
(when (require 'multi-term nil t)
  (setq multi-term-program "/bin/bash"))
;; 代表的な使い方
;; 　M-x multi-term RETを実行するとEmacsのバッ
;; ファにターミナルが開きます。まるで本当のターミ
;; ナルにいるかのようにシェルを使うことができます。
;; 　multi-termは、実行のたびに新たなシェルを開く
;; ことができ、GNU Screenの代わりとしても利用で
;; きます。

;; -----------------------------------------------------------------------------
;; Tramp：Emacsから
;; サーバのファイルを直接編集
;; 　Emacsは標準でSSHやFTPを使って直接サーバの
;; ファイルを編集できます。
;; SSHを使った接続
;; 　C-x C-f（find-file）から/sshx:ユーザ名@ホスト
;; 名:と入力していくと、そのままサーバに接続され、
;; まるでローカルファイルのように扱うことができま

;; ---------------------------------------------------------
;; 自慢の.emacsを貼り付けるスレ
;; ---------------------------------------------------------
;;
;; スタートアップメッセージを表示しない
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

;;C-x bでbuffersを選ぶ時便利
;;older than Emacs 21
;; (iswitchb-default-keybindings)
;;Emacs 21 or newer
(iswitchb-mode 1)

;; バッファを切り替えるのに C-x C-b で electric-buffer-list を使う。
(global-set-key "\C-x\C-b" 'electric-buffer-list)

;; ステータスラインに時間を表示する
(display-time)

;; 時間表示
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq display-time-string-forms
      '(month "/" day "(" dayname ") " 24-hours ":" minutes))
(display-time)

;; 行番号・桁番号をモードラインに表示する
(line-number-mode t)
(column-number-mode t)

;; 画面から出たとき一行だけスクロールさせる
(setq scroll-conservatively 1)

;; バッファの最後の行で next-line しても新しい行を作らない
(setq next-line-add-newlines nil)

;; バッファの最初の行で previous-line しても、
;; "beginning-of-buffer" と注意されないようにする。
(defun previous-line (arg)
  (interactive "p")
  (if (interactive-p)
      (condition-case nil
	  (line-move (- arg))
	((beginning-of-buffer end-of-buffer)))
    (line-move (- arg)))
  nil)

;; hoge.txt~ みたいなバックアップファイルを作らないようにする
; (setq backup-inhibited t)

;; c-mode その他で色が付くようにする
(global-font-lock-mode t)

;; 検索とかリージョンを色付きに。
(setq transient-mark-mode t)
(setq search-highlight t)
(setq query-replace-highlight t)

(set-face-foreground 'region "black")
(set-face-background 'region "pink")

;; C-tで別のウィンドウに切り替える
(global-set-key (kbd "C-x C-o") 'other-window)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GNU GLOBAL(gtags)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'gtags)
(autoload 'gtags-mode "" t)
(global-set-key (kbd "M-p") 'gtags-pop-stack)

(add-hook 'php-mode-hook
	  (lambda ()
	    (gtags-mode t)
	    ;; (gtags-make-complete-list) ; Deprecated.
	    ))

;; (require 'anything-gtags)

(defmacro my-let-env (environments &rest body)
  `(let ((process-environment process-environment))
     ,@(mapcar (lambda (env) `(setenv ,@env)) environments)
     (progn ,@body)))

(defun anything-c-source-gtags-select-with-root (name gtagsroot)
  (lexical-let ((gtagsroot (expand-file-name gtagsroot)))
    `((name . ,name)
      (init
       . ,(lambda ()
	    (my-let-env
	     (("GTAGSROOT" gtagsroot))
	     (call-process-shell-command
	      "global -c" nil (anything-candidate-buffer 'global)))))
      (candidates-in-buffer)
      (action
       ("Goto the location"
	. ,(lambda (candidate)
	     (my-let-env
	      (("GTAGSROOT" gtagsroot))
	      (gtags-push-context)
	      (gtags-goto-tag candidate ""))))
	 ("Goto the location (other-window)"
	  . ,(lambda (candidate)
	       (my-let-env
		(("GTAGSROOT" gtagsroot))
		(gtags-push-context)
		(gtags-goto-tag candidate "" t))))
	 ("Move to the referenced point"
	  . ,(lambda (candidate)
	       (my-let-env
		(("GTAGSROOT" gtagsroot))
		(gtags-push-context)
		(gtags-goto-tag candidate "r"))))))))

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


;; -----------------------------------------------------------------------------
;; tag jump
;; -----------------------------------------------------------------------------
;(require 'anything-etags)
;; (require 'anything-gtagsA )
;; (define-key global-map (kbd "C-x t")
;;   (lambda ()
;;     "Tag jump using etags, gtags and `anything'."
;;     (interactive)
;;     (let* ((initial-pattern (regexp-quote (or (thing-at-point 'symbol) ""))))
;;       (anything (list anything-c-source-gtags-select
;; 		      anything-c-source-etags-select))
;;       "Find Tag: " nil)))

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
(require 'psvn)
(setq svn-status-verbose nil)
(setq svn-status-hide-unmodified t)
;; ログにファイル名を出さない
(setq svn-status-default-log-arguments nil)
;; プレフィクスをC-x sにする
(global-set-key (kbd "C-x s") svn-global-keymap)

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
;; 関連付けとか
;; -----------------------------------------------------------------------------
(setq auto-mode-alist
      (append (list
	       '("\\.php$"	.	php-mode)
	       '("\\.tpl$"	.	smarty-mode)
	       '("\\.el$"	.	lisp-mode)
	       '("\\.yaml$"	.	yaml-mode)
	       '("\\.js$"	.	javascript-mode)
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
(global-set-key "\C-c\C-l" 'toggle-truncate-lines)
