(setq debug-on-error nil)

(require 'package)
;; MELPAを追加
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; MELPA-stableを追加
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; Marmaladeを追加
(add-to-list 'package-archives  '("marmalade" . "http://marmalade-repo.org/packages/") t)
;; Orgを追加
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
;; 初期化
(package-initialize)

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(column-number-mode)

(show-paren-mode)
(electric-pair-mode)

(global-hl-line-mode)

(dolist (dir (list
	      "/usr/local/bin"
	      "/sbin"
	      "/usr/sbin"
	      "/bin"
	      "/usr/bin"
	      (expand-file-name "~/bin")
	      (expand-file-name "~/.emacs.d/bin")
	      (expand-file-name "~/.rbenv/shims")))
  (when (and (file-exists-p dir) (not (member dir exec-path)))
    (setenv "PATH" (concat dir ":" (getenv "PATH")))
    (setq exec-path (append (list dir) exec-path))))

(when load-file-name
  (setq user-emacs-directory (file-name-directory load-file-name)))

(defvar oldemacs-p (<= emacs-major-version 22)) ; 22 以下
(defvar emacs23-p (<= emacs-major-version 23))  ; 23 以下
(defvar emacs24-p (>= emacs-major-version 24))  ; 24 以上
(defvar darwin-p (eq system-type 'darwin))      ; Mac OS X 用
(defvar nt-p (eq system-type 'windows-nt))      ; Windows 用

(if (eq emacs-major-version 21)
    (setq confirm-kill-emacs 'yes-or-no-p)
  (defun my-save-buffers-kill-emacs ()
    (interactive)
    (if (yes-or-no-p "quit emacs? ")
	(save-buffers-kill-emacs)))
  (global-set-key "\C-x\C-c" 'my-save-buffers-kill-emacs))

(winner-mode t)

(windmove-default-keybindings)

(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq scroll-conservatively 1)
(setq next-line-add-newlines nil)
(setq make-backup-files nil)

(line-number-mode t)
(column-number-mode t)
(global-font-lock-mode t)
(setq ring-bell-function 'ignore)

(setq transient-mark-mode t)
(setq search-highlight t)
(setq query-replace-highlight t)

(global-set-key (kbd "C-x C-o") 'other-window)
(setq diff-switches "-w")

;; 165が¥（円マーク） , 92が\（バックスラッシュ）を表す
(define-key global-map [165] [92])

(global-unset-key (kbd "C-z"))

;; C-c C-l で折り返し表示をトグル
(defun toggle-truncate-lines ()
  "折り返し表示をトグル"
  (interactive)
  (if truncate-lines
      (setq truncate-lines nil)
    (setq truncate-lines t))
  )
(global-set-key (kbd "C-c l") 'toggle-truncate-lines)
(setq truncate-partial-width-windows nil)

(add-hook 'linum-mode-hook
	  '(lambda ()
	     (set-face-foreground 'linum "#00ff00")
	     (set-face-background 'linum nil)))

;;kill-ring の最大値. デフォルトは 30.
(setq kill-ring-max 100)

(defun create-temporary-buffer ()
  "テンポラリバッファを作成し、それをウィンドウに表示します。"
  (interactive)
  ;; *temp* なバッファを作成し、それをウィンドウに表示します。
  (switch-to-buffer (generate-new-buffer "*temp*"))
  ;; セーブが必要ないことを示します？
  (setq buffer-offer-save nil))
;; C-c t でテンポラリバッファを作成します。
(global-set-key "\C-ct" 'create-temporary-buffer)
;; (exec-path-from-shell-initialize)

(set-locale-environment "utf-8")
(setenv "LANG" "en_US.UTF-8")
(set-default-coding-systems 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(cond ((eq darwin-p t)
       ;; Mac の文字コード
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

(when (window-system)
  ;; 1. M-x menu-set-font
  ;; 2. M-x describe-font
  ;; 3. copy and paste "name"
  (set-frame-font "-*-Source Code Pro-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1"))
  ;; (set-frame-font "-*-Fira Code-normal-normal-normal-*-14-*-*-*-m-0-iso10646-1"))

(use-package doom-themes
  :custom
  (doom-themes-enable-italic t)
  (doom-themes-enable-bold t)
  :custom-face
  (doom-modeline-bar ((t (:background "#6272a4"))))
  :config
  (load-theme 'doom-dracula t))

(use-package doom-modeline
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-minor-modes nil)
  :hook
  (after-init . doom-modeline-mode)
  :config
  (line-number-mode 1)
  (column-number-mode 1)
  ;; (doom-modeline-def-modeline 'main
  ;; 			      '(bar workspace-number window-number evil-state god-state ryo-modal xah-fly-keys matches buffer-info remote-host buffer-position parrot selection-info)
  ;; 			      '(misc-info persp-name lsp github debug minor-modes input-method major-mode process vcs checker))
  (doom-modeline-def-modeline 'main
  			      '(bar buffer-position parrot selection-info buffer-info buffer-position parrot selection-info)
  			      '(misc-info persp-name lsp github debug minor-modes input-method major-mode process vcs checker))
   )

;; (use-package which-key
;;   :diminish which-key-mode
;;   :hook (after-init . which-key-mode))

(use-package amx)

(use-package posframe)
(use-package flymake-posframe
  :load-path "<path to 'flymake-posframe'>"
  :hook (flymake-mode . flymake-posframe-mode))

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode))

(when (require 'recentf nil t)
  ;; (defmacro with-suppressed-message (&rest body)
  ;;   "Suppress new messages temporarily in the echo area and the `*Messages*' buffer while BODY is evaluated."
  ;;   (declare (indent 0))
  ;;   (let ((message-log-max nil))
  ;;     `(with-temp-message (or (current-message) "") ,@body)))

  (setq recentf-max-saved-items 1000)            ;; recentf に保存するファイルの数
  (setq recentf-exclude '(".recentf"))           ;; .recentf自体は含まない
  ;; (setq recentf-auto-cleanup 10)                 ;; 保存する内容を整理
  ;; (run-with-idle-timer 30 t '(lambda ()          ;; 30秒ごとに .recentf を保存
  ;; 			       (with-suppressed-message (recentf-save-list))))
  )

;; (when (require 'helm-config nil t)
;;   (ido-mode 0)
;;   (ido-everywhere 0)

;;   (helm-mode 1)
;;   (global-set-key (kbd "M-x") #'helm-M-x)
;;   (global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
;;   (global-set-key (kbd "C-x C-f") #'helm-find-files)
;;   (global-set-key (kbd "C-x b") #'helm-mini)
;;   (global-set-key (kbd "C-x C-b") #'helm-buffers-list)
;;   (global-set-key (kbd "M-y") #'helm-show-kill-ring)

;;   (helm-autoresize-mode t)
;;   (setq helm-autoresize-max-height 0)
;;   (setq helm-autoresize-min-height 40)

;;   (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
;;   (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
;;   (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

;;   (setq helm-split-window-inside-p            nil	; open helm buffer inside current window, not occupy whole other window
;; 	helm-move-to-line-cycle-in-source     nil	; move to end or beginning of source when reaching top or bottom of source.
;; 	helm-ff-search-library-in-sexp        t		; search for library in `require' and `declare-function' sexp.
;; 	helm-scroll-amount                    8		; scroll 8 lines other window using M-<next>/M-<prior>
;; 	helm-ff-file-name-history-use-recentf t
;; 	helm-echo-input-in-header-line t)

;;   (when (executable-find "curl")
;;     (setq helm-net-prefer-curl t))
;;  )

;; (when (require 'helm-gtags nil t)
;;   (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-find-tag)
;;   (define-key helm-gtags-mode-map (kbd "C-c s") 'helm-gtags-find-symbol)
;;   (define-key helm-gtags-mode-map (kbd "C-c r") 'helm-gtags-find-rtag)
;;   (define-key helm-gtags-mode-map (kbd "C-c t") 'helm-gtags-find-tag)
;;   (define-key helm-gtags-mode-map (kbd "C-c f") 'helm-gtags-parse-file)
;;   (define-key helm-gtags-mode-map (kbd "M-p") 'helm-gtags-pop-stack)
;;   (add-hook 'php-mode-hook
;; 	    (lambda ()
;; 	      (helm-gtags-mode t)))
;;   (add-hook 'ruby-mode-hook
;; 	    (lambda ()
;; 	      (helm-gtags-mode t))))

;; (when (require 'helm-swoop nil t))

;; (when (require 'helm-ghq nil t)
;;   (define-key global-map (kbd "C-]") 'helm-ghq))

;; (when (require 'helm-descbinds nil t)
;;   (helm-descbinds-mode)
;;   (define-key global-map (kbd "C-h C-b")  'helm-descbinds)
;;   '(defun describe-bindings ()
;;      (helm-descbindings)))

;; (when (require 'helm-open-github nil t))

(use-package counsel
  :config
  (define-key global-map (kbd "M-x") 'counsel-M-x)
  (define-key global-map (kbd "M-y") 'counsel-yank-pop)
  (define-key global-map (kbd "C-x b") 'counsel-buffer-or-recentf)
  (define-key global-map (kbd "C-x C-b") 'counsel-switch-buffer))

(use-package ivy
  :custom
  (ivy-use-virtual-buffers t)
  (enable-recursive-minibuffers t)
  (ivy-height 30)
  (ivy-count-format "(%d/%d)")
  (ivy-use-virtual-buffers t)
  :config
  (ivy-mode 1))

(when (require 'ivy-ghq nil t)
  (setq ivy-ghq-short-list t)
  (define-key global-map (kbd "C-]") 'helm-ghq))

(use-package ace-window
  ;; :functions
  ;; hydra-frame-window/body
  :bind
  ;; ("C-M-o" . hydra-frame-window/body)
  :custom
  (aw-keys '(?j ?k ?l ?i ?o ?h ?y ?u ?p))
  :config
  (define-key global-map (kbd "C-M-o") 'ace-window)
  :custom-face
  (aw-leading-char-face ((t (:height 4.0 :foreground "#f1fa8c")))))

(use-package lsp-mode
  :custom ((lsp-inhibit-message t)
         (lsp-message-project-root-warning t)
         (create-lockfiles nil))
  :hook   (prog-major-mode . lsp-prog-major-mode-enable))

(use-package lsp-ui
  :after lsp-mode
  :custom (scroll-margin 0)
  :hook   (lsp-mode . lsp-ui-mode))

(use-package company-lsp
  :after (lsp-mode company yasnippet)
  :defines company-backends
  :functions company-backend-with-yas
  :init (cl-pushnew 'company-lsp company-backends))

(when (require 'flycheck nil t)
  (when (require 'ruby-mode nil t)
    (when (require 'rubocop nil t))
    (add-hook 'ruby-mode-hook
              (lambda ()
                (flycheck-mode)
                (flycheck-select-checker 'ruby-rubocop)
                (flycheck-disable-checker 'ruby-rubylint)
                (flycheck-disable-checker 'ruby-reek))))
  (when (require 'rspec-mode nil t)
    (add-hook 'rspec-mode-hook
              (lambda ()
                (flycheck-mode))))
  (when (require 'js2-mode nil t)
    (add-hook 'js2-mode-hook
              (lambda ()
                (flycheck-mode)))))

(when (require 'typescript-mode) nil t
      (add-to-list 'auto-mode-alist '("\\.ts[x]\\'" . typescript-mode)))

(when (require 'tide) nil t
      (add-hook 'typescript-mode-hook
		(lambda ()
		  (setq indent-tabs-mode nil)
		  (setq tab-width 2)
		  (setq typescript-indent-level 2)
		  (tide-setup)
		  (flycheck-mode t)
		  (setq flycheck-check-syntax-automatically '(save mode-enabled))
		  (eldoc-mode t)
		  (company-mode-on)))
      )

(when (require 'prettier-js nil t)
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  (add-hook 'typescript-mode-hook 'prettier-js-mode))

(when (require 'company nil t)
  ;; C-n, C-pで補完候補を選べるように
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  ;; C-hがデフォルトでドキュメント表示にmapされているので、文字を消せるようにmapを外す
  (define-key company-active-map (kbd "C-h") nil)
  ;; 1つしか候補がなかったらtabで補完、複数候補があればtabで次の候補へ行くように
  (define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
  ;; ドキュメント表示
  (define-key company-active-map (kbd "M-d") 'company-show-doc-buffer)
  (define-key company-search-map (kbd "C-n") 'company-select-next)
  (define-key company-search-map (kbd "C-p") 'company-select-previous)

  ;; n文字入力で補完されるように
  (setq company-minimum-prefix-length 4)
  ;; デフォルトは0.5
  (setq company-idle-delay 3)
  (setq company-tooltip-idle-delay 3)
  ;; 候補の一番上でselect-previousしたら一番下に、一番下でselect-nextしたら一番上に行くように
  (setq company-selection-wrap-around t))

;;; 色の設定。出来るだけ奇抜にならないように
;; (set-face-attribute 'company-tooltip nil
;;                     :foreground "black"
;;                     :background "lightgray")
;; (set-face-attribute 'company-preview-common nil
;;                     :foreground "dark gray"
;;                     :background "black"
;;                     :underline t)
;; (set-face-attribute 'company-tooltip-selection nil
;;                     :background "steelblue"
;;                     :foreground "white")
;; (set-face-attribute 'company-tooltip-common nil
;;                     :foreground "black"
;;                     :underline t)
;; (set-face-attribute 'company-tooltip-common-selection nil
;;                     :foreground "white"
;;                     :background "steelblue"
;;                     :underline t)
;; (set-face-attribute 'company-tooltip-annotation t
;;                     :foreground "red")

(when (require 'flycheck-pos-tip nil t)
  (eval-after-load 'flycheck
    '(custom-set-variables
      '(flycheck-display-errors-function #'flycheck-pos-tip-error-messages))))
(eval-after-load 'flycheck
  '(custom-set-variables
    '(flycheck-disabled-checkers '(javascript-jshint javascript-jscs))
    ))

(when (require 'flyspell nil t)
  (flyspell-mode 1)
  (flyspell-prog-mode)
  )

(when (require 'auto-highlight-symbol nil t)
  (global-auto-highlight-symbol-mode t))

(when (require 'gtags nil t)
  (setq gtags-mode-hook
	'(lambda ()
	   ;; (define-key gtags-mode-map (kbd "M-.") 'gtags-find-tag-from-here)
	   ;; (define-key gtags-mode-map (kbd "C-c s") 'gtags-find-symbol)
	   ;; (define-key gtags-mode-map (kbd "C-c r") 'gtags-find-rtag)
	   ;; (define-key gtags-mode-map (kbd "C-c t") 'gtags-find-tag)
	   ;; (define-key gtags-mode-map (kbd "C-c f") 'gtags-parse-file)
	   ;; (define-key gtags-mode-map (kbd "M-p") 'gtags-pop-stack)))
	   ))
  ;; gtags auto update
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
	    (let ((result (start-process "gtags" "*update GTAGS*" "gtags" args "-w" "--gtagsconf" (expand-file-name "~/gtags.conf") "--gtagslabel=pygments")))	))))))
  (add-hook 'after-save-hook 'update-gtags))

(when (require 'company nil t)
  (global-company-mode t)
  (setq company-idle-delay 0) ; デフォルトは0.5
  (setq company-minimum-prefix-length 4) ; デフォルトは4
;; (setq company-selection-wrap-around t) ; 候補の一番下でさらに下に行こうとすると一番上に戻る
  (global-set-key (kbd "M-i") 'company-complete)
  (define-key company-active-map (kbd "M-n") nil)
  (define-key company-active-map (kbd "M-p") nil)
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "C-h") nil)
  (eval-after-load 'company
    '(progn
       (push 'company-robe company-backends)))
  (when (require 'company-box nil t)
    (add-hook 'company-mode-hook 'company-box-mode))
  )

;;  (when (require 'git-complete nil t))

(when (require 'magit nil t)
  (add-hook 'magit-mode-hook
	    '(lambda ()
	       (add-to-list 'process-coding-system-alist '("git" utf-8 . utf-8))
	       (set-default-coding-systems 'utf-8)
	       (prefer-coding-system 'utf-8))))

(use-package git-gutter
  :custom
  (git-gutter-mode 1))

;; -----------------------------------------------------------------------------
;; http://qiita.com/alpha22jp/items/01e614474e7dbfd78305
(set-default-coding-systems 'utf-8)
(prefer-coding-system 'utf-8)

;; -----------------------------------------------------------------------------
;; git-link
(when (require 'git-link nil t)
  (setq git-link-open-in-browser t))

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
	  "unc3n50r3d/oshi"
	  )
	)
  )

(when (require 'string-inflection nil t)
  (global-set-key (kbd "C-c i") 'string-inflection-cycle)
  (global-set-key (kbd "C-c C") 'string-inflection-camelcase)		;; Force to CamelCase
  (global-set-key (kbd "C-c L") 'string-inflection-lower-camelcase)	;; Force to lowerCamelCase
  (global-set-key (kbd "C-c J") 'string-inflection-java-style-cycle))	;; Cycle through Java styles

(when (require 'migemo nil t)
  (setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-user-dictionary nil)
  (setq migemo-coding-system 'utf-8)
  (setq migemo-regex-dictionary nil)
  (load-library "migemo")
  (migemo-init))

(when (require 'yasnippet nil t)
  (yas-global-mode t))
(when (require 'yasnippet-snippets nil t))

(require 'php-mode)
(add-hook 'php-mode-hook
         (lambda ()
             (require 'php-completion)
             (php-completion-mode t)
             (define-key php-mode-map "\C-o" 'phpcmp-complete)
	     (define-key php-mode-map "\C-cb" 'geben-set-breakpoint-line)
             ;; (when (require 'auto-complete nil t)
	     ;;   (make-variable-buffer-local 'ac-sources)
	     ;;   (add-to-list 'ac-sources 'ac-source-php-completion)
	     ;;   (auto-complete-mode t))
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
(when (require 'geben nil t)
  (autoload 'geben-set-breakpoint-line "geben" "Set a breakpoint at the current line." t)
  (setq geben-dbgp-default-port 9005))

(when (require 'smarty-mode nil t)
  (setq smarty-left-delimiter "({")
  (setq smarty-right-delimiter "})"))

(add-hook 'js-mode-hook
         (lambda ()
             ;; (when (require 'auto-complete nil t)
	     ;;   (make-variable-buffer-local 'ac-sources)
	     ;;   (auto-complete-mode t))
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

(when (require 'js2-mode nil t)
  (add-hook 'js2-mode-hook
	    (lambda ()
	      ;; (when (require 'auto-complete nil t)
	      ;;   (make-variable-buffer-local 'ac-sources)
	      ;;   (auto-complete-mode t))
	      (setq indent-tabs-mode nil)
	      (setq tab-width 2)
	      (setq c-basic-offset 2)
	      (setq js2-basic-offset 2)
	      (setq c-hanging-comment-ender-p nil)
	      (setq js-switch-indent-offset 2)
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

  (flycheck-add-mode 'javascript-eslint 'js2-jsx-mode)
  (add-hook 'js2-jsx-mode-hook 'flycheck-mode)
  )
(when (require 'flycheck nil t)
  (add-hook 'js2-mode-hook
	    (lambda ()
	      (flycheck-mode))))

(when (require 'json-mode nil t)
  (add-hook 'json-mode-hook
	    (lambda ()
	      (make-local-variable 'js-indent-level)
	      (setq js-indent-level 2))))

(when (require 'sws-mode nil t))
(when (require 'jade-mode nil t))

(when (require 'ruby-mode nil t)
  (when (require 'robe nil t)
    (add-hook 'robe-mode-hook
	      '(lambda ()
		 (define-key ruby-mode-map (kbd "M-j") 'robe-jump)))
    (add-hook 'ruby-mode-hook 'robe-mode))
  (setq interpreter-mode-alist (append '(("ruby" . ruby-mode)) interpreter-mode-alist))
  (add-hook 'ruby-mode-hook
	    '(lambda ()
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
	       ;;
	       (set-default-coding-systems 'utf-8)
	       (setq c-toggle-hungry-state t)
	       (setq ruby-insert-encoding-magic-comment nil)
	       ;; (define-key ruby-mode-map (kbd "M-.") 'find-tag)
	       ;; (define-key ruby-mode-map (kbd "M-p") 'pop-tag-mark)
	       (define-key ruby-mode-map (kbd "<backspace>") 'c-hungry-delete)
	       (define-key ruby-mode-map (kbd "<delete>") 'c-hungry-delete)
	       (electric-indent-mode t)
	       (electric-layout-mode t)
	       (setq ruby-deep-indent-paren-style nil)
	       (setq truncate-lines t)
	       (electric-pair-mode 0)
	       (when (require 'ruby-block nil t)
		 (ruby-block-mode t)
		 ;; ミニバッファに表示し, かつ, オーバレイする.
		 (setq ruby-block-highlight-toggle t))
	       (when (require 'ruby-end nil t)
		 (ruby-end-mode t)
		 (setq ruby-end-insert-newline nil)
		 (setq ruby-end-check-statement-modifiers nil))
	       (when (require 'rinari nil t)
		 (rinari-minor-mode 1))
	       (when (require 'ruby-compilation nil t)
		 (setq company-minimum-prefix-length 4)
		 (define-key ruby-mode-map (kbd "\M-r") 'run-rails-test-or-ruby-buffer))
	       (hs-minor-mode)))
  ;; https://coderwall.com/p/u-l0ra/ruby-code-folding-in-emacs
  (eval-after-load "hideshow"
    '(add-to-list 'hs-special-modes-alist
		  `(ruby-mode
		    ,(rx (or "def" "class" "module" "do" "{" "[")) ; Block start
		    ,(rx (or "}" "]" "end"))                       ; Block end
		    ,(rx (or "#" "=begin"))                        ; Comment start
		    ruby-forward-sexp nil)))
  (global-set-key (kbd "C-c h") 'hs-hide-block)
  (global-set-key (kbd "C-c s") 'hs-show-block)
  ;; set ruby-mode indent
  (setq ruby-indent-level 2)
  (setq ruby-indent-tabs-mode nil)
  ;; http://d.hatena.ne.jp/khiker/20071130/emacs_ruby_block
  ;; rbenv の ruby を参照するようにする
  (setenv "PATH" (concat (getenv "HOME") "/.rbenv/shims:" (getenv "HOME") "/.rbenv/bin:" (getenv "PATH")))
  (setq exec-path (cons (concat (getenv "HOME") "/.rbenv/shims") (cons (concat (getenv "HOME") "/.rbenv/bin") exec-path)))
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   (if (window-system)
       '(font-lock-type-face ((t (:foreground "#66ccff" :weight bold))))
     '(font-lock-type-face ((t (:foreground "#66ccff" :weight bold))))
     )
   ;; '(my-hl-line-face ((t (:background "dark blue" :underline nil))))
   ))

(when (require 'inf-ruby nil t)
  (setq inf-ruby-default-implementation "pry")
  (setq inf-ruby-eval-binding "Pry.toplevel_binding")
  (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode)
  (add-hook 'inf-ruby-mode-hook 'ansi-color-for-comint-mode-on))

;; rspec-mode
(when (require 'rspec-mode nil t)
  (when (require 'flycheck nil t)
    (add-hook 'rspec-mode-hook
	      (lambda ()
		(flycheck-mode))))
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   )
  (add-hook 'rspec-mode-hook
	    (lambda ()
	      (define-key ruby-mode-map (kbd "C-c r") 'execute-rspec)
	      (linum-mode))))

;; rubocop
(when (require 'rubocop nil t)
  (add-hook 'ruby-mode-hook
	    (lambda ()
	      (rubocop-mode)))
  (add-hook 'rspec-mode-hook
	    (lambda ()
	      (rubocop-mode)))
  )

;; rubocopfmt
;; (when (require 'rubocopfmt)
;;   (add-hook 'ruby-mode-hook #'rubocopfmt-mode))

;; https://github.com/endofunky/bundler.el
(when (require 'bundler nil t))
;;;

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
    (if (window-system)
	'(web-mode-type-face ((t (:foreground "#66ccfff" :weight bold))))
      ))
  (add-hook 'web-mode-hook 'my/web-mode-hook))

(when (require 'rinari nil t)
  (setq rinari-minor-mode t))

(when (require 'scss-mode nil t)
  ;; インデント幅を2にする
  ;; SASSの自動コンパイルをオフ
  (defun scss-custom ()
    "scss-mode-hook"
    (and
     (setq tab-width 2)
     (setq indent-tabs-mode nil)
     (set (make-local-variable 'css-indent-offset) 2)
     (set (make-local-variable 'scss-compile-at-save) nil)))
  (add-hook 'scss-mode-hook
	    '(lambda() (scss-custom))))

(when (require 'sass-mode nil t)
  (defun sass-custom ()
    "sass-mode-hook"
    (and
     (setq tab-width 2)
     (setq indent-tabs-mode nil)
     (setq sass-indent-offset 2)))
  (add-hook 'sass-mode-hook
	    '(lambda() (sass-custom))))

(when (require 'yaml-mode nil t))

(when (require 'nodejs-repl nil t))

(when (require 'nginx-mode nil t))

(when (require 'csv-mode nil t))

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
  (setq sql-mysql-login-params (append sql-mysql-login-params '(port)))
  (setq sql-port 3306)
  ;; starting SQL mode loading sql-indent / sql-complete
  (eval-after-load "sql"
    '(progn
       (load-library "sql-indent")
       ;; (load-library "sql-complete")
       ;; (load-library "sql-transform")
       )))

(when (require 'go-mode nil t)
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-env "GOPATH")
  (add-hook 'go-mode-hook
            '(lambda ()
               (setq tab-width 2)
               (setq indent-tabs-mode nil)))
  (defadvice flymake-post-syntax-check (before flymake-force-check-was-interrupted)
    (setq flymake-check-was-interrupted t))
  (ad-activate 'flymake-post-syntax-check)
  (eval-after-load "go-mode"
    '(require 'flymake-go)))
(when (require 'go-complete nil t)
  (add-hook 'completion-at-point-functions 'go-complete-at-point))

(add-hook 'after-save-hook
	  (function (lambda ()
		      (if (eq major-mode 'emacs-lisp-mode)
			  (save-excursion
			    (byte-compile-file buffer-file-name))))))

(when (require 'slim-mode nil t))

(when (require 'terraform-mode nil t))

;; (when (require 'csharp-mode)
;;   (add-hook 'csharp-mode-hook '(lambda () (omnisharp-mode) (flycheck-mode))))

;; (when (require 'omnisharp) nil t
;;       (setq omnisharp-server-executable-path "/usr/local/omnisharp-server/OmniSharp/bin/Debug/OmniSharp.exe")
;;       (define-key omnisharp-mode-map (kbd "<C-tab>") 'omnisharp-auto-complete)
;;       (define-key omnisharp-mode-map "." 'omnisharp-add-dot-and-auto-complete)
;;       (add-hook 'after-init-hook #'global-flycheck-mode))

;; (when (require 'ctags-update) nil t)

;; (when (require 'shader-mode) nil t)

(when (require 'markdown-mode nil t))

(when (require 'apache-mode nil t))

;; Ocaml
(when (require 'caml nil t))
(when (require 'tuareg nil t)
  (add-hook 'tuareg-mode-hook #'(lambda() (setq mode-name "🐫")))
  (when (require 'rainbow-delimiters nil t)
    (add-hook 'tuareg-mode-hook 'rainbow-delimiters-mode))
  )

;; Rust
;; https://medium.com/@mopemope/emacs-%E3%81%A7-rust%E3%81%AE%E9%96%8B%E7%99%BA%E7%92%B0%E5%A2%83%E3%82%92%E6%A7%8B%E7%AF%89%E3%81%99%E3%82%8B%E8%A9%B1-1278803f24b2
(use-package rustic
  :ensure t
  :defer t
  :init
  (add-hook 'rustic-mode-hook
	     '(lambda ()
		(auto-highlight-symbol-mode t)
		(smartparens-mode t)
		(remove-hook 'rustic-mode-hook 'flycheck-mode))
	       (push 'rustic-clippy flycheck-checkers))
  :mode ("\\.rs$" . rustic-mode)
  :config
  (use-package quickrun
    :defer t
    :ensure t)
  (use-package lsp-mode
    :ensure t)
  (setq lsp-rust-server 'rust-analyzer)
  (setq rustic-lsp-server 'rust-analyzer)
  (setq lsp-rust-analyzer-server-command '("~/.cargo/bin/rust-analyzer")))

(add-to-list 'auto-mode-alist '("\\.org\\'". org-mode))
(add-to-list 'auto-mode-alist '("\\.php$". php-mode))
(add-to-list 'auto-mode-alist '("\\.sql$". sql-mode))
(add-to-list 'auto-mode-alist '("\\.tpl$". smarty-mode))
(add-to-list 'auto-mode-alist '("\\.el$". emacs-lisp-mode))
(add-to-list 'auto-mode-alist '("\\.\\(?:yml\\|yaml\\)$". yaml-mode))
(add-to-list 'auto-mode-alist '("\\.js$". js2-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . js2-jsx-mode))
(add-to-list 'auto-mode-alist '("\\.json$". json-mode))
(add-to-list 'auto-mode-alist '("\\.styl$'". sws-mode))
(add-to-list 'auto-mode-alist '("\\.jade$'". jade-mode))
(add-to-list 'auto-mode-alist '("\\.coffee$". coffee-mode))
(add-to-list 'auto-mode-alist '("\\.md$". markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$".	markdown-mode))
(add-to-list 'auto-mode-alist '("\\.text$". markdown-mode))
(add-to-list 'auto-mode-alist '("\\.html\\.erb$". web-mode))
(add-to-list 'auto-mode-alist '("\\.html$". web-mode))
(add-to-list 'auto-mode-alist '("\\.scss$". scss-mode))
(add-to-list 'auto-mode-alist '("\\.sass$". sass-mode))
(add-to-list 'auto-mode-alist '("\\.[rR]\\'". R-mode))
(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'". csv-mode))
(add-to-list 'auto-mode-alist '("\\.slim\\'". slim-mode))
(add-to-list 'auto-mode-alist
	     '("\\.\\(?:gemspec\\|irbrc\\|gemrc\\|rake\\|rb\\|ru\\|thor\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist
	     '("\\(Capfile\\|Gemfile\\|[rR]akefile\\)\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.cs\\'". csharp-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'". rustic-mode))

(add-hook 'after-init-hook 'global-color-identifiers-mode)

(server-start)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-idle-delay 0.8)
 '(doom-themes-enable-bold t)
 '(doom-themes-enable-italic t)
 '(flycheck-disabled-checkers (quote (javascript-jshint javascript-jscs)))
 '(flycheck-display-errors-function (function flycheck-pos-tip-error-messages))
 '(package-selected-packages
   (quote
    (yasnippet web-mode use-package smex smartparens projectile prodigy popwin ansi package-build shut-up epl git commander s pallet nyan-mode multiple-cursors git-gutter magit idle-highlight-mode htmlize flycheck f expand-region exec-path-from-shell drag-stuff dash bind-key)))
 '(safe-local-variable-values (quote ((Coding . utf-8)))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(aw-leading-char-face ((t (:height 4.0 :foreground "#f1fa8c"))))
 '(doom-modeline-bar ((t (:background "#6272a4"))))
 '(font-lock-type-face ((t (:foreground "#66ccff" :weight bold)))))
