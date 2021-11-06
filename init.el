(setq straight-use-package-by-default t)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(use-package emacs
  :init
  (setq user-full-name "Patrick D. Elliott")
  (setq user-mail-address "patrick.d.elliott@gmail.com")

  (defalias 'yes-or-no-p 'y-or-n-p)

  ;; stop emacs from littering
  (setq make-backup-files nil)
  (setq auto-save-default nil)
  (setq create-lockfiles nil)

  ;; ignores warnings during native compilation
  ;; (borrowed from Pat Mike's config)
  (setq warning-minimum-level :error)

  ;; saves customizations made via the Customize mode in a different file.
  ;; (borrowed from Pat Mike's config)
  (setq custom-file (concat user-emacs-directory "custom.el"))
  (load custom-file)

  ;; utf-8 everywhere
  ;; (borrowed from Pat Mike's config)
  (set-language-environment "UTF-8")
  (setq locale-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)

  (setq delete-by-moving-to-trash t) ;; use trash-cli rather than rm when deleting files.
  )

(use-package general
  :config
  (general-evil-setup)

  (general-create-definer patrl/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC"
    )

  (general-create-definer patrl/local-leader-keys
    :states '(normal visual)
    :keymaps 'override
    :prefix ","
    :global-prefix "SPC m"
    )

  (patrl/leader-keys
    "SPC" '(execute-extended-command :wk "execute command")
    "." '(find-file :wk "find file")
    "TAB" '(:keymap tab-prefix-map :wk "tab")
    "h" '(:keymap help-map :wk "help")
    "p" '(:keymap project-prefix-map :wk "project")
    )

  (patrl/leader-keys
    "f" '(:ignore t :wk "file")
    "ff" '(find-file :wk "find file")
    )

  (patrl/leader-keys
    "b" '(:ignore t :wk "buffer")
    "bk" '(kill-this-buffer :wk "kill this buffer")
    )
  )

(use-package evil
  :general
  (patrl/leader-keys
   "w" '(:keymap evil-window-map :wk "window")
   )
  :init
  ;; I need this to ensure that 'C-u' gets bound to 'evil-scroll-up'
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode t))

(use-package evil-commentary
  :config
  (evil-commentary-mode))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package which-key
  :after evil
  :init (which-key-mode)
  :config
  (which-key-setup-minibuffer))

(use-package mood-line
  :config (mood-line-mode))

(set-face-attribute 'default nil :font "Operator Mono Book" :height 120)

(use-package solaire-mode
  :config
  (solaire-global-mode +1))

(use-package tron-legacy-theme
  :config
  (setq tron-legacy-theme-vivid-cursor t))

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
	doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package hl-todo
  :init
  (global-hl-todo-mode))

(use-package tab-bar
  :init (tab-bar-mode)
  :straight (:type built-in))

(use-package project
  :straight (:type built-in))

(use-package project-tab-groups
  :after (project tab-bar)
  :config
  (project-tab-groups-mode 1))

(use-package dired
  :straight (:type built-in))

;; FIXME using the latest version of org results in an error
(use-package org
  :straight (:type built-in)
  :general
  (patrl/local-leader-keys
   :keymaps 'org-mode-map
   "l" '(org-insert-link :wk "insert link")
   "b" '(:keymap org-babel-map :wk "babel")
  )
  :hook ((org-mode . visual-line-mode))
  )

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package vertico
  :init (vertico-mode)
  (setq vertico-cycle t) ;; enable cycling for 'vertico-next' and 'vertico-prev'
  :general
  (:keymaps 'vertico-map
	    ;; keybindings to cycle through vertico results.
	    "C-j" 'vertico-next
	    "C-k" 'vertico-previous
	    "C-f" 'vertico-exit)
  (:keymaps 'minibuffer-local-map
	    "M-h" 'backward-kill-word)
  )

(use-package orderless
  :init
  (setq completion-styles '(orderless)
	completion-category-defaults nil
	completion-category-overrides '((file (styles partial-completion)))))

(use-package savehist
  :init
  (savehist-mode))

(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(use-package consult
  :general
  (patrl/leader-keys
    "bb" '(consult-buffer :wk "consult buffer")
    "fs" '(consult-line :wk "consult line")
    "ht" '(consult-theme :wk "consult theme")
    )
  )

(use-package embark
  :general
  (
   "C-." 'embark-act
   "C-;" 'embark-dwim
   )
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  )

(use-package embark-consult
  :after (embark consult)
  :demand t ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package magit)