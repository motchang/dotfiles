;; (setq debug-on-error t)
(setq debug-on-error nil)
(dolist (dir (list
	      "/usr/local/mysql/bin"
	      "/usr/local/bin"
	      "/sbin"
	      "/usr/sbin"
	      "/bin"
	      "/usr/bin"
	      (expand-file-name "~/bin")
	      (expand-file-name "~/.emacs.d/bin")))
  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

(add-hook 'after-init-hook
          '(lambda ()
             (let* ((el (expand-file-name "init.el" user-emacs-directory))
                    (elc (concat el "c")))
               (when (file-newer-than-file-p el elc)
                 (byte-compile-file el)))))

;; http://d.hatena.ne.jp/tarao/20150221/1424518030
(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

;; スタートアップメッセージを非表示
;;(setq inhibit-startup-screen t)
(setq inhibit-startup-screen nil)

;; tool-barを非表示
(tool-bar-mode 0)
;; scroll-barを非表示
(scroll-bar-mode 0)
;; menu-barを非表示
(menu-bar-mode 0)
;; メニューハーにファイルハスを表示する
;; frame-title-format変数にフォーマットを追加します。
(setq frame-title-format
      (format "%%f - Emacs@%s" (system-name)))

(defvar oldemacs-p (<= emacs-major-version 22)) ; 22 以下
(defvar emacs23-p (<= emacs-major-version 23))  ; 23 以下
(defvar emacs24-p (>= emacs-major-version 24))  ; 24 以上
(defvar darwin-p (eq system-type 'darwin))      ; Mac OS X 用
(defvar nt-p (eq system-type 'windows-nt))      ; Windows 用

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
 (let (path)
    (dolist (path paths paths)
      (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
	(add-to-list 'load-path default-directory)
	(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
	    (normal-top-level-add-subdirs-to-load-path))))))

;; -----------------------------------------------------------------------------
;; ELPA
;; -----------------------------------------------------------------------------
(cond ((eq emacs24-p t)
       (require 'package)
       (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
       (add-to-list 'package-archives '("tromey" . "http://tromey.com/elpa/"))
       (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
       ))

;; elispとconfティレクトリをサブディレクトリごとload-pathに追加
(add-to-load-path "elpa" "elisp" "conf")

(byte-recompile-directory (expand-file-name "~/.emacs.d") 0)

;; http://d.hatena.ne.jp/rubikitch/20100423/bytecomp
(when (require 'auto-async-byte-compile)
  (add-hook 'emacs-lisp-mode-hook 'enable-auto-async-byte-compile-mode))

;; ---------------------------------------------------------
;; 自慢の.emacsを貼り付けるスレ / 本体の根本的な設定
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
;;(iswitchb-mode nil)

;; ハッファを切り替えるのに C-x C-b て electric-buffer-list を使う。
; (global-set-key "\C-x\C-b" 'electric-buffer-list)

;; ステータスラインに時間を表示する
;; (display-time)

;; 時間表示
;; (setq display-time-24hr-format t)
;; (setq display-time-day-and-date t)
;; (setq display-time-string-forms
;;       '(month "/" day "(" dayname ") " 24-hours ":" minutes))
;; (display-time)

;; 行番号・桁番号をモードラインに表示する
(line-number-mode t)
(column-number-mode t)

;; 画面から出たとき一行だけスクロールさせる
(setq scroll-conservatively 1)

;; ハッファの最後の行で next-line しても新しい行を作らない
(setq next-line-add-newlines nil)

;; User Option: make-backup-files
;;   この変数は, バックアップファイルを作成するかどうかを決定する.
(setq make-backup-files nil)

;; Variable: backup-inhibited
;;   この変数がnil以外であると, バックアップを禁止する.
;;   これは恒久的にバッファローカルであり, メジャーモードを変更しても値は
;;   失われない. メジャーモードはこの変数に設定するべきではなく, かわりに,
;;   make-backup-filesに設定するべきである.
(setq backup-inhibited t)

;; #file-name# を作らない
(setq auto-save-default nil)

;; c-mode その他で色が付くようにする
(global-font-lock-mode t)

;; 検索とかリージョンを色付きに。
(setq transient-mark-mode t)
(setq search-highlight t)
(setq query-replace-highlight t)

;; C-xC-oで別のウィンドウに切り替える
(global-set-key (kbd "C-x C-o") 'other-window)

;; vc-* の diff switch
(setq diff-switches "-w")

;; C-h で BS
;; (global-set-key "\C-h" 'delete-backward-char)

;; C-c C-l で折り返し表示をトグル
(defun toggle-truncate-lines ()
  "折り返し表示をトグル"
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  ;; (recenter)
  )
(global-set-key (kbd "C-c l") 'toggle-truncate-lines)
(setq truncate-partial-width-windows nil)


;; http://akisute3.hatenablog.com/entry/20120409/1333899842
;; (setq recentf-max-saved-items 100)
(when (require 'recentf nil t)
  (setq recentf-max-saved-items 2000)
  (setq recentf-exclude '(".recentf"))
  (setq recentf-auto-cleanup 10)
  (setq recentf-auto-save-timer
	(run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1))

(setq install-elisp-repository-directory "~/.emacs.d/elisp")

;; -----------------------------------------------------------------------------
;; (install-elisp "http://www.emacswiki.org/emacs/download/auto-install.el")
(when (require 'auto-install nil t)
  ;; インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWiki に登録されている elisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であれはプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))

;; -----------------------------------------------------------------------------
;; installed
;;(install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")

;; ・C-h a 文字列 RET
;; 入力した文字列か含まれているコマンドのリスト
;; を表示する（M-x command-apropos）。例：autoinstall
;; という文字列が含まれるコマンドを調へる
;; C-h a auto-install RET

;; ・C-h b
;; 現在のキーの割り当て表を表示する（M-x describe-bindings）

;; ・C-h k キーバインド
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
;; デフォルトをUTF8に変更する
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(cond ((eq darwin-p t)
       ;; Mac の文字コートの設定
       (require 'ucs-normalize)
       (set-file-name-coding-system 'utf-8-nfd)
       (require 'ls-lisp)
       (setq ls-lisp-use-insert-directory-program nil)
       (setq dired-use-ls-dired t)
       ;; (setq dired-listing-switches "-FlL --group-directories-first")
       )
      (t
       ;; そのほかのOSの設定(Unicodeの場合)
       (set-file-name-coding-system 'utf-8)))

(cond ((eq emacs24-p t)
       (setq buffer-file-coding-system 'utf-8))
      (setq default-buffer-file-coding-system 'utf-8))
(prefer-coding-system 'utf-8)
(set-language-environment "Japanese")

;; 行番号を表示
(add-hook 'linum-mode-hook
	  '(lambda ()
	     (set-face-foreground 'linum "#00ff00")
	     (set-face-background 'linum nil)))

(cond ((eq emacs24-p t)
       (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
       ;; (load-theme 'wombat t)
       ;; (load-theme 'manoj-dark t)
       (load-theme 'pastels-on-dark t)
       (set-face-background 'default "black")
       (set-face-foreground 'font-lock-comment-face "#00AA00")
       (set-face-foreground 'font-lock-string-face "#AABBEE")
       ;; (set-face-foreground 'font-lock-type-face "color-45")
       (set-face-foreground 'font-lock-type-face "cyan1")
       (setq eww-search-prefix "https://www.google.co.jp/search?q="))
      ((when (require 'color-theme nil t)
         ;; カラーテーマの選択
         ;; M-x color-theme-select
         ;; カラーテーマの例
         ;; http://gnuemacscolorthemetest.googlecode.com/svn/html/index-c.html
         ;; テーマを読み込むための設定
         (color-theme-initialize)
         ;; テーマを変更する
         (color-theme-dark-laptop)
         ;; いい感しの
         ;; Wheat Billw Midnight dark-laptop
        )))

(set-face-foreground 'region "black")
(set-face-background 'region "yellow")

;; paren-mode 対応する括弧を強調して表示する
;; 表示まての秒数。初期値は0.125
(setq show-paren-delay 0.125)
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
;; (set-face-background 'region "darkgreen")
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
   ;; 背景が dark なら
   '((((class color) (background dark))
      ;; (:background "maroon4" :underline nil))
      (:background "dark blue" :underline nil))
     ;; 背景かlightなら
     (((class color) (background light))
      (:background "LightGoldenrodYellow" t))
     ;; (t (:bold t))
     (t :underline t)
     )
   "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)

;; 現在行をハイライト表示
(global-hl-line-mode t)

(when (window-system)
;;; http://d.hatena.ne.jp/setoryohei/20110117/1295336454
;;; フォントセットを作る
  (let* ((fontset-name "myfonts") ; フォントセットの名前
         (size 12) ; ASCIIフォントのサイズ [9/10/12/14/15/17/19/20/...]
          (asciifont "Ricty") ; ASCIIフォント
          ;; (asciifont "Menlo") ; ASCIIフォント
          ;; (jpfont "Hiragino Maru Gothic ProN") ; 日本語フォント
          (jpfont "Ricty") ; 日本語フォント
          (font (format "%s-%d:weight=normal:slant=normal" asciifont size))
          (fontspec (font-spec :family asciifont))
          (jp-fontspec (font-spec :family jpfont))
          (fsn (create-fontset-from-ascii-font font nil fontset-name)))
    (set-fontset-font fsn 'japanese-jisx0213.2004-1 jp-fontspec)
    (set-fontset-font fsn 'japanese-jisx0213-2 jp-fontspec)
    (set-fontset-font fsn 'katakana-jisx0201 jp-fontspec) ; 半角カナ
    (set-fontset-font fsn '(#x0080 . #x024F) fontspec) ; 分音符付きラテン
    (set-fontset-font fsn '(#x0370 . #x03FF) fontspec) ; ギリシャ文字
    )

;;; フォントサイズの比を設定
  (dolist (elt '(("^-apple-hiragino.*" . 1.2)
                 (".*osaka-bold.*" . 1.2)
                 (".*osaka-medium.*" . 1.2)
                 (".*courier-bold-.*-mac-roman" . 1.0)
                 (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
                 (".*monaco-bold-.*-mac-roman" . 0.9)))
    (add-to-list 'face-font-rescale-alist elt))

;;; デフォルトのフレームパラメータでフォントセットを指定
  (add-to-list 'default-frame-alist '(font . "fontset-myfonts"))

;;; デフォルトフェイスにフォントセットを設定
;;; (これは起動時に default-frame-alist に従ったフレームが作成されない現象への対処)
  (set-face-font 'default "fontset-myfonts"))

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
;; (set-face-attribute 'default nil
;; 		    :family "Menlo"
;; 		    :height 120)

;; 日本語フォントを指定する
;; 　set-fontset-fontとfont-specを使って日本語フォン
;; トを指定します。
;; 日本語フォントをヒラキノ明朝ProNに
;; (set-fontset-font
;;  nil 'japanese-jisx0208
;;  (font-spec :family "Hiragino_Mincho_ProN"))

;; 　また、漢字以外の全角文字たけフォントを変える
;; ことかてきます。筆者はひらかなとカタカナをモト
;; ヤシータ注10にしています。設定方法は、日本語を変
;; 更したあとにひらかなたけ別のフォントて上書きす
;; る形てす。指定にはUnicodeの符号を利用します。
;; ひらかなとカタカナをモトヤシータに
;; U+3000-303F CJKの記号およひ句読点
;; U+3040-309F ひらかな
;; U+30A0-30FF カタカナ
;; (set-fontset-font
;;  nil '(#x3040 . #x30ff)
;;  (font-spec :family "NfMotoyaCedar"))

;; フォントの横幅を調節する
;; 　半角と全角を1:2にしたけれは、face-font-rescalealist
;; を調節しましょう。
;; (setq face-font-rescale-alist
;;       '((".*Menlo.*" . 1.0)
;; 	(".*Hiragino_Mincho_ProN.*" . 1.2)
;; 	(".*nfmotoyacedar-bold.*" . 1.2)
;; 	(".*nfmotoyacedar-medium.*" . 1.2)
;; 	("-cdac$" . 1.3)))

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
(when (require 'auto-complete nil t)
  (global-auto-complete-mode t)
  (global-set-key (kbd "M-i") 'auto-complete)

  (set-face-background 'ac-completion-face "#000066")
  (set-face-foreground 'ac-completion-face "#FFFF33")

  (set-face-foreground 'ac-candidate-face "#33bbbb")
  (set-face-background 'ac-candidate-face "#555555")

  (set-face-background 'ac-selection-face "#009988")
  (set-face-foreground 'ac-selection-face "#FF6677"))

(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-i") 'auto-complete)
  (setq ac-auto-start 4)
  (ac-config-default))

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
(when (require 'anything-startup nil t))

;;; anything
;; (auto-install-batch "anything")
(when (require 'anything nil t)
  (define-key global-map (kbd "\C-x b") 'anything)
  (define-key global-map (kbd "\C-x \C-b") 'anything)
  (setq
   ;; 候補を表示するまでの時間。デフォルトは0.5
   anything-idle-delay 0.1
   ;；タイプして再描画するまでの時間。デフォルトは0.1
   anything-input-idle-delay 0.1
   ;; 候補の最大表示数。デフォルトは50
   anything-candidate-number-limit 200
   ;; 候補が多い時に体感速度を早くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   ;; アルファベットで入力できるようにすると大文字で絞込ができない
   ;;  anything-enable-shortcuts 'alphabet
   anything-enable-shortcuts nil)
  (set-face-background 'anything-header "Blue")
  (set-face-foreground 'anything-header "White")
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
    ;; (anything-read-string-mode nil)
    (anything-read-string-mode '(string variable command))
    ;; lispシンボルの補完候補の再検索時間
    (anything-lisp-complete-symbol-set-timer 100))
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
(when (require 'anything nil t)
  (setq anything-for-document-sources
	(list
	 anything-c-source-man-pages
	 anything-c-source-info-cl
	 anything-c-source-info-pages
	 anything-c-source-info-elisp
	 anything-c-source-apropos-emacs-commands
	 anything-c-source-apropos-emacs-functions
	 anything-c-source-apropos-emacs-variables)))

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
  ;; (global-set-key (kbd "C-x C-f") 'anything-project)
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

;;kill-ring の最大値. デフォルトは 30.
(setq kill-ring-max 100)

;;anything で対象とするkill-ring の要素の長さの最小値.
;;デフォルトは 10.
;; (setq anything-kill-ring-threshold 10)
;; (global-set-key (kbd "M-y") 'anything-show-kill-ring)

;; (global-set-key (kbd "<f5> a i") 'anything-imenu)
;; (global-set-key (kbd "C-x C-f") 'find-file)

;; -----------------------------------------------------------------------------
;; helm-mode
;; -----------------------------------------------------------------------------
(when (require 'helm nil t)
  (require 'helm-config)
  (helm-mode t)
  (define-key global-map (kbd "M-x")     'helm-M-x)
  (define-key global-map (kbd "C-x C-f") 'helm-find-files)
  (define-key global-map (kbd "M-y")     'helm-show-kill-ring)
  (define-key global-map (kbd "<f5> a i")'helm-imenu)
  (define-key global-map (kbd "C-x b")   'helm-mini)
  (define-key helm-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)
  (define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
  (define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
  (custom-set-variables
   '(helm-truncate-lines t)
   '(helm-buffer-max-length 35)
   '(helm-delete-minibuffer-contents-from-point t)
   '(helm-ff-skip-boring-files t)
   '(helm-boring-file-regexp-list '("~$" "\\.elc$"))
   '(helm-ls-git-show-abs-or-relative 'relative)
   '(helm-mini-default-sources '(helm-source-buffers-list
                                 helm-source-recentf
                                 helm-source-buffer-not-found)))
  (when (require 'helm-gtags nil t)
    (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-find-tag-from-here)
    (define-key helm-gtags-mode-map (kbd "C-c s") 'helm-gtags-find-symbol)
    (define-key helm-gtags-mode-map (kbd "C-c r") 'helm-gtags-find-rtag)
    (define-key helm-gtags-mode-map (kbd "C-c t") 'helm-gtags-find-tag)
    (define-key helm-gtags-mode-map (kbd "C-c f") 'helm-gtags-parse-file)
    (define-key helm-gtags-mode-map (kbd "M-p") 'helm-gtags-pop-stack)
    (add-hook 'php-mode-hook
	      (lambda ()
		(gtags-mode t)))
    (add-hook 'ruby-mode-hook
	      (lambda ()
		(gtags-mode t))))
  )

;; -----------------------------------------------------------------------------
;; flymake-mode
;; -----------------------------------------------------------------------------
(when (require 'flymake nil t)
  (global-set-key "\C-cd" 'flymake-display-err-menu-for-current-line)
  (set-face-background 'flymake-errline "Red")
  (set-face-foreground 'flymake-errline "Cyan")
  (set-face-underline 'flymake-errline t)
  ;; PHP
  ;; PHPで flymake する時は display_errors = On じゃないとダメだよ
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
           flymake-errline-patterns)))
  (add-hook 'php-mode-hook
            '(lambda () (flymake-mode t))))

(when (require 'flymake-cursor nil t))

;; http://d.hatena.ne.jp/gan2/20080702/1214972962
;; flymake for ruby
(when (require 'flymake nil t)
  ;; Invoke ruby with '-c' to get syntax checking
  (set-face-background 'flymake-errline "deeppink")
  (set-face-foreground 'flymake-errline "#110000")
  (set-face-background 'flymake-warnline "dark slate blue")
  (defun flymake-ruby-init ()
    (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                         'flymake-create-temp-inplace))
           (local-file  (file-relative-name
                         temp-file
                         (file-name-directory buffer-file-name))))
      (list "ruby" (list "-c" local-file))))
  (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
  (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
  (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
  (add-hook
   'ruby-mode-hook
   '(lambda ()
      ;; Don't want flymake mode for ruby regions in rhtml files
      (if (not (null buffer-file-name)) (flymake-mode))
      ;; エラー行で C-c d するとエラーの内容をミニバッファで表示する
      (define-key ruby-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

  (defun credmp/flymake-display-err-minibuf ()
    "Displays the error/warning for the current line in the minibuffer"
    (interactive)
    (let* ((line-no             (flymake-current-line-no))
           (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
           (count               (length line-err-info-list)))
      (while (> count 0)
        (when line-err-info-list
          (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
                 (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
                 (text (flymake-ler-text (nth (1- count) line-err-info-list)))
                 (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
            (message "[%s] %s" line text)))
        (setq count (1- count))))))

(when (require 'flymake-coffee nil t)
  (add-hook 'coffee-mode-hook 'flymake-coffee-load))

;; flymake for jade
(defun flymake-jade-init ()
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
		     'flymake-create-temp-intemp))
	 (local-file (file-relative-name
		      temp-file
		      (file-name-directory buffer-file-name)))
	 (arglist (list local-file)))
    (list "jade" arglist)))

(setq flymake-err-line-patterns
      (cons '("\\(.*\\): \\(.+\\):\\([[:digit:]]+\\)$"
	      2 3 nil 1)
	    flymake-err-line-patterns))

(add-to-list 'flymake-allowed-file-name-masks
	              '("\\.jade\\'" flymake-jade-init))

;; -----------------------------------------------------------------------------
;; flycheck
;; -----------------------------------------------------------------------------
(require 'flycheck)
(require 'flycheck-pos-tip)

(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages)))

(set-face-foreground 'popup-tip-face "#CC0000")
(set-face-background 'popup-tip-face "#33FFFF")

;; 候補のサマリー部分
(set-face-foreground 'popup-summary-face "#666633")

;; ドキュメント部分
(set-face-background 'popup-tip-face "cyan")
(set-face-foreground 'popup-tip-face "black")

(when (require 'ruby-mode nil t)
  (add-hook 'ruby-mode-hook
	    (lambda ()
	      (flycheck-mode)
	      (flycheck-select-checker 'ruby-rubocop)
	      (flycheck-disable-checker 'ruby-rubylint))))

(when (require 'rspec-mode nil t)
  (add-hook 'rspec-mode-hook
	    (lambda ()
	      (flycheck-mode))))

(when (require 'js2-mode nil t)
  (add-hook 'js2-mode-hook
	    (lambda ()
	      (flycheck-mode))))

;; -----------------------------------------------------------------------------
;; auto-highlight-symbol
;; -----------------------------------------------------------------------------
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

;; -----------------------------------------------------------------------------
;; Tramp：Emacsから
;; サーバのファイルを直接編集
;; 　Emacsは標準でSSHやFTPを使って直接サーバの
;; ファイルを編集できます。
;; SSHを使った接続
;; 　C-x C-f（find-file）から/sshx:ユーザ名@ホスト
;; 名:と入力していくと、そのままサーバに接続され、
;; まるてローカルファイルのように扱うことができます


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GNU GLOBAL(gtags)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (require 'gtags)
;; (autoload 'gtags-mode "" t)
;; (setq gtags-mode-hook
;;       '(lambda ()
;; 	 (define-key gtags-mode-map (kbd "M-.") 'gtags-find-tag-from-here)
;;          (define-key gtags-mode-map (kbd "C-c s") 'gtags-find-symbol)
;;          (define-key gtags-mode-map (kbd "C-c r") 'gtags-find-rtag)
;;          (define-key gtags-mode-map (kbd "C-c t") 'gtags-find-tag)
;;          (define-key gtags-mode-map (kbd "C-c f") 'gtags-parse-file)
;;          (define-key gtags-mode-map (kbd "M-p") 'gtags-pop-stack)))

;; (global-set-key (kbd "M-p") 'gtags-pop-stack)
;; (add-hook 'php-mode-hook
;; 	  (lambda ()
;; 	    (gtags-mode t)))

;; (add-hook 'ruby-mode-hook
;; 	  (lambda ()
;; 	    (gtags-mode t)))

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
	  (let ((result (start-process "gtags" "*update GTAGS*" "gtags" args "-w" "--gtagsconf" (expand-file-name "~/gtags.conf") "--gtagslabel=pygments")))))))))
(add-hook 'after-save-hook 'update-gtags)

;; tag jump
(when (require 'anything-gtags) nil t)
;; Test1.ccを開いているときに、M-r (gtags-find-rtag) などで同じディレクトリにある
;; Test2.ccに飛びたいのに、src/src/Test2.ccという空のファイルが開く。どうもパス
;; 表示がgtagsを実行したディレクトリからになっているみたい。
;; "gtags-path-style"のデフォルト値"root"から、"relative"もしくは"absolute"にす
;; ればよい。relativeの方が見やすいと思う。
(setq gtags-path-style 'relative)

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

;; geben
(autoload 'geben "geben" "PHP Debugger on Emacs" t)
(autoload 'geben-set-breakpoint-line "geben" "Set a breakpoint at the current line." t)
(setq geben-dbgp-default-port 9005)

;; -----------------------------------------------------------------------------
;; javascript-mode
;; -----------------------------------------------------------------------------
(add-hook 'js-mode-hook
         (lambda ()
             (when (require 'auto-complete nil t)
	       (make-variable-buffer-local 'ac-sources)
	       (auto-complete-mode t))
	     (setq tab-width 2)
	     (setq indent-tabs-mode nil)
	     (c-toggle-hungry-state t)
	     (setq c-basic-offset 2)
	     (c-set-offset 'case-label' 2)
	     (c-set-offset 'arglist-intro' 2)
	     (c-set-offset 'arglist-close' 0)
	     (setq tab-width 2
		   c-basic-offset 2
		   c-hanging-comment-ender-p nil
		   indent-tabs-mode nil)
	     ))

;; -----------------------------------------------------------------------------
;; js2 mode (javascript)
;; -----------------------------------------------------------------------------
(require 'js2-mode)
(add-hook 'js2-mode-hook
	  (lambda ()
	    (when (require 'auto-complete nil t)
	      (make-variable-buffer-local 'ac-sources)
	      (auto-complete-mode t))
	    (setq indent-tabs-mode nil)
	    (setq tab-width 2)
	    (setq c-basic-offset 2)
	    (setq js2-basic-offset 2)
	    (setq c-hanging-comment-ender-p nil)
	    (c-toggle-hungry-state t)
	    (c-set-offset 'case-label' 2)
	    (c-set-offset 'arglist-intro' 2)
	    (c-set-offset 'arglist-close' 0)
	    (when (require 'auto-highlight-symbol nil t)
	      (auto-highlight-symbol-mode t))
	    ;; (set-face-background 'js2-error "orange")
	    ;; (set-face-foreground 'js2-error "#0000F1")
	    ;; (set-face-background 'js2-external-variable nil)
	    ;; (set-face-foreground 'js2-external-variable "#0000F1")))
	    ;; Disable auto newline insertion after input semi colon (;) at javascript-mode
	    ;; http://insnvlovn.blogspot.jp/2010/04/emacs-php-mode.html
	    (setq-local electric-layout-rules '((?\{ . after) (?\} . before)))))

;; -----------------------------------------------------------------------------
;; json-mode
;; -----------------------------------------------------------------------------
(require 'json-mode)
(add-hook 'json-mode-hook
	  (lambda ()
	    (make-local-variable 'js-indent-level)
	                (setq js-indent-level 2)))

;; -----------------------------------------------------------------------------
;; jade-mode
;; -----------------------------------------------------------------------------
(require 'sws-mode)
(require 'jade-mode)

;; -----------------------------------------------------------------------------
;; ruby-mode
;; -----------------------------------------------------------------------------
(autoload 'ruby-mode "ruby-mode" "Mode for editing ruby source files" t)
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))

(require 'inf-ruby)
(setq inf-ruby-default-implementation "pry")
(setq inf-ruby-eval-binding "Pry.toplevel_binding")

(autoload 'inf-ruby "inf-ruby" "Run an inferior Ruby process" t)
(add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)
(add-hook 'inf-ruby-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'ruby-mode-hook
          '(lambda ()
             (when (require 'ruby-end nil t)
               (ruby-end-mode t)
               (setq ruby-end-insert-newline nil)
               (setq ruby-end-check-statement-modifiers nil))
             ;; http://stackoverflow.com/questions/7961533/emacs-ruby-method-parameter-indentation
             (defadvice ruby-indent-line (after unindent-closing-paren activate)
               (let ((column (current-column))
                     indent offset)
                 (save-excursion
                   (back-to-indentation)
                   (let ((state (syntax-ppss)))
                     (setq offset (- column (current-column)))
                     (when (and (eq (char-after) ?\))
                                (not (zerop (car state))))
                       (goto-char (cadr state))
                       (setq indent (current-indentation)))))
                 (when indent
                   (indent-line-to indent)
                         (when (> offset 0) (forward-char offset)))))
             ;; rinari
             (when (require 'rinari nil t)
               (rinari-minor-mode 1))
	     (when (require 'ruby-compilation nil t)
	       (define-key ruby-mode-map (kbd "\M-r") 'run-rails-test-or-ruby-buffer))
             (when (require 'smartparens-ruby)
               (set-face-attribute 'sp-show-pair-match-face nil
                                   :background "gray20" :foreground "green"))
             (set-default-coding-systems 'utf-8)
             (setq c-toggle-hungry-state t)
             (setq ruby-insert-encoding-magic-comment nil)
	     ;; http://qiita.com/tadsan/items/ab3c3b594b5bf6203f02
	     (make-local-variable 'ac-ignore-case)
	     (setq ac-ignore-case nil)
             (abbrev-mode 1)
	     ;; (define-key ruby-mode-map (kbd "M-.") 'find-tag)
	     ;; (define-key ruby-mode-map (kbd "M-p") 'pop-tag-mark)
	     (define-key ruby-mode-map (kbd "<backspace>") 'c-hungry-delete)
	     (define-key ruby-mode-map (kbd "<delete>") 'c-hungry-delete)
             (electric-indent-mode t)
             (electric-layout-mode t)
             (setq ruby-deep-indent-paren-style nil)
	     (setq truncate-lines t)
             (electric-pair-mode 0)
	     (set-face-foreground 'font-lock-type-face "cyan")))

;; set ruby-mode indent
(setq ruby-indent-level 2)
(setq ruby-indent-tabs-mode nil)

;; http://d.hatena.ne.jp/khiker/20071130/emacs_ruby_block
(when (require 'ruby-block nil t)
  (ruby-block-mode t)
  ;; ミニバッファに表示し, かつ, オーバレイする.
  (setq ruby-block-highlight-toggle t))

;; rbenv の ruby を参照するようにする
(setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
(setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))

;; rspec-mode
(when (require 'rspec-mode nil t)
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(custom-safe-themes
     (quote
      ("e80932ca56b0f109f8545576531d3fc79487ca35a9a9693b62bf30d6d08c9aaf" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "211bb9b24001d066a646809727efb9c9a2665c270c753aa125bace5e899cb523" default)))
   '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
   '(rspec-use-rake-flag nil)
   '(rspec-use-rake-when-possible nil))

  (add-hook 'rspec-mode-hook
	    (lambda ()
	      ()
	      (linum-mode))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-lock-type-face ((t (:foreground "brightcyan" :weight bold))))
 '(my-hl-line-face ((t (:background "dark blue" :underline nil)))))

;; web-mode でも rinari する
(when (require 'web-mode nil t)
  (defun my/web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-html-offset                  2)
    (setq web-mode-markup-indent-offset         2)
    (setq web-mode-css-offset                   2)
    (setq web-mode-script-offset                2)
    (setq web-mode-php-offset                   2)
    (setq web-mode-java-offset                  2)
    (setq web-mode-asp-offset                   2)
    (setq indent-tabs-mode                      nil)
    (setq tab-width                             2)
    (setq web-mode-enable-auto-pairing          t)
    (setq web-mode-enable-auto-closing          t)
    (setq web-mode-enable-auto-quoting          t)
    (setq web-mode-enable-auto-indentation      t)
    (when (require 'rinari nil t)
      (setq rinari-minor-mode t)))
  (add-hook 'web-mode-hook 'my/web-mode-hook))

;; -----------------------------------------------------------------------------
;; scssmode
;; -----------------------------------------------------------------------------
(autoload 'scss-mode "scss-mode")

;; インデント幅を2にする
;; SASSの自動コンパイルをオフ
(defun scss-custom ()
  "scss-mode-hook"
  (and
   (setq tab-width 4)
   (set (make-local-variable 'css-indent-offset) 2)
   (set (make-local-variable 'scss-compile-at-save) nil)))
(add-hook 'scss-mode-hook
  '(lambda() (scss-custom)))

;; -----------------------------------------------------------------------------
;; Sassmode
;; -----------------------------------------------------------------------------
(when (require 'sass-mode nil t)
  (defun sass-custom ()
    "sass-mode-hook"
    (and
     ;; インデントはタブ。
     (setq tab-width 4)
     (setq indent-tabs-mode t)
     (setq sass-indent-offset 4)))
  (add-hook 'sass-mode-hook
	    '(lambda() (sass-custom))))

;; -----------------------------------------------------------------------------
;; yaml-mode
;; -----------------------------------------------------------------------------
(when (require 'yaml-mode nil t))

;; -----------------------------------------------------------------------------
;; smarty-mode
;; -----------------------------------------------------------------------------
(autoload 'smarty-mode "smarty-mode" "Smarty Mode" t)
(setq smarty-left-delimiter "({")
(setq smarty-right-delimiter "})")

;; -----------------------------------------------------------------------------
;; coffee mode
;; -----------------------------------------------------------------------------
(when (require 'coffee-mode nil t)
  (setq whitespace-action '(auto-cleanup))
  ;; only show bad whitespace
  (setq whitespace-style '(trailing space-before-tab indentation empty space-after-tab))
  (defun coffee-custom ()
    "coffee-mode-hook"
    ;; CoffeeScript uses two spaces.
    (custom-set-variables '(tab-width 2)))
    (custom-set-variables '(coffee-tab-width 2))
  (add-hook 'coffee-mode-hook 'coffee-custom))

(when (require 'flymake-coffee nil t)
  (add-hook 'coffee-mode-hook 'flymake-coffee-load)
  (setq flymake-coffee-coffeelint-configuration-file "~/src/dotfiles/coffeelint.json"))

;; -----------------------------------------------------------------------------
;; CEDET
;; -----------------------------------------------------------------------------
; (load-library "cedet")
; (global-ede-mode 1)
; (semantic-mode 1)

;; -----------------------------------------------------------------------------
;; ispell
;; -----------------------------------------------------------------------------
(setq ispell-program-name "aspell")

;; -----------------------------------------------------------------------------
;; markdown-mode
;; -----------------------------------------------------------------------------
(autoload 'markdown-mode "markdown-mode" "Major mode for editing Markdown files" t)

;; -----------------------------------------------------------------------------
;; magit
;; -----------------------------------------------------------------------------
(when (require 'magit nil t))

;; -----------------------------------------------------------------------------
;; http://noqisofon.hatenablog.com/entry/20101102/1288647885
;; テンポラリバッファを作成し、それをウィンドウに表示します。
;; -----------------------------------------------------------------------------
(defun create-temporary-buffer ()
  "テンポラリバッファを作成し、それをウィンドウに表示します。"
  (interactive)
  ;; *temp* なバッファを作成し、それをウィンドウに表示します。
  (switch-to-buffer (generate-new-buffer "*temp*"))
  ;; セーブが必要ないことを示します？
  (setq buffer-offer-save nil))
;; C-c t でテンポラリバッファを作成します。
(global-set-key "\C-ct" 'create-temporary-buffer)

;; -----------------------------------------------------------------------------
;; 鬼軍曹
;; -----------------------------------------------------------------------------
(when (require 'drill-instructor nil t))

;; -----------------------------------------------------------------------------
;; twittering-mode
;; -----------------------------------------------------------------------------
(when (require 'twittering-mode nil t)
  (setq twittering-use-master-password t)
  (setq twittering-icon-mode nil)
  (setq twittering-timer-interval 500)
  (setq twittering-initial-timeline-spec-string
	'(":home"
	  ":mentions"
	  ":search/#ruby OR #rails OR #rspec lang:ja/"
	  "motchang_/met")))

;; -----------------------------------------------------------------------------
;; docker
;; -----------------------------------------------------------------------------
(when (require 'dockerfile-mode nil t))

;; -----------------------------------------------------------------------------
;; nodejs-repl
;; -----------------------------------------------------------------------------
(when (require 'nodejs-repl nil t))

;; -----------------------------------------------------------------------------
;;
;; -----------------------------------------------------------------------------
(when (require 'rainbow-mode nil t)
  (add-hook 'css-mode-hook 'rainbow-mode)
  (add-hook 'scss-mode-hook 'rainbow-mode)
  (add-hook 'php-mode-hook 'rainbow-mode)
  (add-hook 'html-mode-hook 'rainbow-mode)
  (add-hook 'lisp-mode-hook 'rainbow-mode)
  (add-hook 'web-mode-hook 'rainbow-mode))

;; -----------------------------------------------------------------------------
;; popup.el
;; -----------------------------------------------------------------------------
;(auto-install-from-url "https://raw.github.com/m2ym/popwin-el/master/popwin.el")
(when (require 'popwin nil t)
  ;; anything
  (setq anything-samewindow nil)
  (push '("*anything imenu*" :height 20) popwin:special-display-config)
  (push '("*anything gtags*" :height 20) popwin:special-display-config)
  (setq display-buffer-function 'popwin:display-buffer)
  (setq popwin:popup-window-height 0.5))

;; -----------------------------------------------------------------------------
;; nyan-mode
;; -----------------------------------------------------------------------------
(when (window-system)
  (when (require 'nyan-mode nil t)
    (nyan-mode 1)))

;; -----------------------------------------------------------------------------
;; string-inflection
;; -----------------------------------------------------------------------------
(when (require 'string-inflection nil t)
  (global-set-key (kbd "C-c i") 'string-inflection-cycle)
  (global-set-key (kbd "C-c C") 'string-inflection-camelcase)		;; Force to CamelCase
  (global-set-key (kbd "C-c L") 'string-inflection-lower-camelcase)	;; Force to lowerCamelCase
  (global-set-key (kbd "C-c J") 'string-inflection-java-style-cycle))	;; Cycle through Java styles

;; -----------------------------------------------------------------------------
;; nginx-mode
;; -----------------------------------------------------------------------------
(when (require 'nginx-mode nil t))

;; -----------------------------------------------------------------------------
;; ess (R)
;; https://gist.github.com/abicky/5da654e3a7858ec60aed
;; -----------------------------------------------------------------------------
;; 拡張子が .r, .R の場合に R-mode を起動
;; (add-to-list 'auto-mode-alist '("\\.[rR]\\'" . R-mode))
;; R-mode は ess-r-d.el に定義されているが全機能をロードするために ess-site をロード
(autoload 'R-mode "ess-site" "Major mode for editing R source.  See `ess-mode' for more help." t)

(defun R-mode-init ()
  ;; インデントの調整（詳細は各変数のヘルプ参照）
  (setq ess-indent-level 2  ; 組み込み関数は 4 スペースだけど最近は 2 スペースが主流？
	ess-arg-function-offset-new-line (list ess-indent-level)
	ess-close-paren-offset '(0))
  ;; comment-region のコメントアウトに # を使う（デフォルト##）
  (set (make-local-variable 'comment-add) 0)
  ;; *.R と R のプロセスを結びつける
  ;; プロセスを結びつけることでプロセスに定義されている変数などの補完ができるようになる
  (let ((window-conf (current-window-configuration)))
    (ess-force-buffer-current)
    ;; 勝手に *R* バッファを開くので元に戻す
    (set-window-configuration window-conf))
  ;; ウィンドウが1つの状態で *.R を開いた場合はウィンドウを縦に分割して R を表示する
  (when (one-window-p)
    (split-window-horizontally)
    (set-window-buffer (next-window) (process-buffer (get-process ess-local-process-name))))
  )

(defun ess-pre-run-init ()
  ;; R のプロセスが他になくて 1 window ならウィンドウを分割する
  (when (and (> (length ess-process-name-list) 0)
	     (one-window-p))
    (split-window-horizontally)
    (other-window 1))
  )

(defun ess-site-after-load ()
  ;; 起動時にワーキングディレクトリを尋ねられないようにする
  (setq ess-ask-for-ess-directory nil)
  ;; アンダースコアの入力が " <- " にならないようにする
  (ess-toggle-underscore nil)
  ;; # の数によってコメントのインデントの挙動が変わるのを無効にする
  (setq ess-fancy-comments nil)
  ;; キャレットがシンボル上にある場合にもエコーエリアにヘルプを表示する
  (setq ess-eldoc-show-on-symbol t)
  ;; anything/helm を使いたいので IDO は無効化
  (setq ess-use-ido nil)
  )

(eval-after-load "ess-site" '(ess-site-after-load))

(add-hook 'R-mode-hook 'R-mode-init)
;; R 起動直前の処理
(add-hook 'ess-pre-run-hook 'ess-pre-run-init)

;; -----------------------------------------------------------------------------
;; csv-mode
;; -----------------------------------------------------------------------------
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)

;; -----------------------------------------------------------------------------
;; sql-mode
;; -----------------------------------------------------------------------------
;; C-c C-c : 'sql-send-paragraph
;; C-c C-r : 'sql-send-region
;; C-c C-s : 'sql-send-string
;; C-c C-b : 'sql-send-buffer
(when (require 'sql nil t)
  (add-hook 'sql-interactive-mode-hook
	    #'(lambda ()
		(interactive)
		(set-buffer-process-coding-system 'utf-8 'utf-8 )
		              (setq show-trailing-whitespace nil)))
  ;; starting SQL mode loading sql-indent / sql-complete
  (eval-after-load "sql"
    '(progn
       (load-library "sql-indent")
       (load-library "sql-complete")
       (load-library "sql-transform"))))

;; -----------------------------------------------------------------------------
;; 関連付けとか
;; -----------------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.org\\'" .   org-mode))
(add-to-list 'auto-mode-alist '("\\.php$".	php-mode))
(add-to-list 'auto-mode-alist '("\\.sql$".	sql-mode))
(add-to-list 'auto-mode-alist '("\\.tpl$".	smarty-mode))
(add-to-list 'auto-mode-alist '("\\.el$".	lisp-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:yml\\|yaml\\)$".	yaml-mode))
(add-to-list 'auto-mode-alist '("\\.js$".	js2-mode))
;;(add-to-list 'auto-mode-alist '("\\.js$".	js-mode))
(add-to-list 'auto-mode-alist '("\\.json$".	json-mode))
(add-to-list 'auto-mode-alist '("\\.styl$'".    sws-mode))
(add-to-list 'auto-mode-alist '("\\.jade$'".    jade-mode))
(add-to-list 'auto-mode-alist '("\\.coffee$".	coffee-mode))
(add-to-list 'auto-mode-alist '("\\.md$".	markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$".	markdown-mode))
(add-to-list 'auto-mode-alist '("\\.text$".	markdown-mode))
(add-to-list 'auto-mode-alist '("\\.html\\.erb$".	web-mode))
(add-to-list 'auto-mode-alist '("\\.html$".	web-mode))
(add-to-list 'auto-mode-alist '("\\.scss$".	scss-mode))
(add-to-list 'auto-mode-alist '("\\.sass$". sass-mode))
(add-to-list 'auto-mode-alist
             '("\\.\\(?:gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist
             '("\\(Capfile\\|Gemfile\\(?:\\.[a-zA-Z0-9._-]+\\)?\\|[rR]akefile\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.[rR]\\'" . R-mode))
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
(add-to-list 'auto-mode-alist '("\\.slim\\'" . slim-mode))

;; -----------------------------------------------------------------------------
;; http://qiita.com/alpha22jp/items/01e614474e7dbfd78305
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(custom-safe-themes
   (quote
    ("e80932ca56b0f109f8545576531d3fc79487ca35a9a9693b62bf30d6d08c9aaf" "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" "211bb9b24001d066a646809727efb9c9a2665c270c753aa125bace5e899cb523" default)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(rspec-use-rake-when-possible nil)
 '(safe-local-variable-values
   (quote
    ((engine . scss)
     (encoding . utf-8)
     (ruby-compilation-executable . "ruby")
     (ruby-compilation-executable . "ruby1.8")
     (ruby-compilation-executable . "ruby1.9")
     (ruby-compilation-executable . "rbx")
     (ruby-compilation-executable . "jruby")))))
