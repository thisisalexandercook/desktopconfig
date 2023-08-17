(setq inhibit-startup-message t)
(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 45)        ; Give some breathing room
(menu-bar-mode -1)          ; Disable the menu bar
(global-visual-line-mode 1)
(display-battery-mode 1)
(display-time-mode 1)

(global-set-key (kbd "C-;") 'execute-extended-command)

(start-process-shell-command "xmodmap" nil "xmodmap ~/.emacs.d/exwm/Xmodmap")

(setq backup-directory-alist `(("." . ,(expand-file-name "tmp/backups/" user-emacs-directory))))

(make-directory (expand-file-name "tmp/auto-saves/" user-emacs-directory) t)

(setq auto-save-list-file-prefix (expand-file-name "tmp/auto-saves/sessions/"    user-emacs-directory)
auto-save-file-name-transforms `((".*" ,(expand-file-name "tmp/auto-saves/" user-emacs-directory) t)))
(setq create-lockfiles nil)

(setq auto-save-visited-interval 60)  ;; Auto-save every 60 seconds
(auto-save-visited-mode +1)  ;; Turn on auto-save-visited-mode

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("gnu" . "https://elpa.gnu.org/packages/")
			 ("nongnu" . "https://elpa.nongnu.org/nongnu/")))



(package-initialize)
(unless package-archive-contents
(package-refresh-contents)
(package-install 'org))

(unless (package-installed-p 'use-package)
(package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package command-log-mode)

;; Install straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
(expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
(bootstrap-version 6))
(unless (file-exists-p bootstrap-file)
(with-current-buffer
(url-retrieve-synchronously
"https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
'silent 'inhibit-cookies)
(goto-char (point-max))
(eval-print-last-sexp)))
(load bootstrap-file nil 'nomessage))

(unless (package-installed-p 'quelpa)
(with-temp-buffer
  (url-insert-file-contents "https://raw.githubusercontent.com/quelpa/quelpa/master/quelpa.el")
  (eval-buffer)
  (quelpa-self-upgrade)))

(use-package vterm
:ensure t)

(use-package modus-themes
:ensure t)
(require 'modus-themes)
(setq modus-themes-common-palette-overrides modus-themes-preset-overrides-faint)
(load-theme 'modus-operandi :no-confirm)

; write org-timer-set-timer function

(setq display-buffer-alist
 `(("\\*Occur\\*"
    (display-buffer-in-side-window)
    (window-height . 0.25)
    (side . bottom)
    (slot . 0))
 ("\\*Outline+"
    (display-buffer-in-side-window)
    (window-height . 0.25)
    (side . bottom)
    (slot . 1))))

(use-package doom-modeline
:ensure t
:init (doom-modeline-mode 1)
:custom ((doom-modeline-height 25)))

(use-package nerd-icons
:ensure t
)

(use-package dired
:ensure nil
:commands (dired dired-jump)
:bind (("C-x C-j" . dired-jump))
:custom ((dired-listing-switches "-agho --group-directories-first")))

(use-package dired-single)
(defun my-dired-init ()
"Bunch of stuff to run for dired, either immediately or when it's
 loaded."
;; <add other stuff here>
(define-key dired-mode-map [remap dired-find-file]
  'dired-single-buffer)
(define-key dired-mode-map [remap dired-mouse-find-file-other-window]
  'dired-single-buffer-mouse)
(define-key dired-mode-map [remap dired-up-directory]
  'dired-single-up-directory))

  ;; if dired's already loaded, then the keymap will be bound
  (if (boundp 'dired-mode-map)
  ;; we're good to go; just add our bindings
  (my-dired-init)
  ;; it's not loaded yet, so add our bindings to the load-hook
  (add-hook 'dired-load-hook 'my-dired-init))

(use-package all-the-icons-dired
:hook (dired-mode . all-the-icons-dired-mode))

(use-package vterm
:ensure t)

(use-package vertico
:ensure t
:init
(vertico-mode))

(use-package orderless
:ensure t
:custom
(completion-styles '(orderless basic))
(completion-category-overrides '((file (styles basic partial-completion)))))

(setq isearch-lazy-count t)
(global-set-key "\C-s" 'isearch-forward)

;; (quelpa '(pdf-tools :fetcher git
;; :url "https://github.com/dalanicolai/pdf-tools.git"
;; :branch "pdf-roll"
;; :files ("lisp/*.el"
;; "README"
;; ("build" "Makefile")
;; ("build" "server")
;; (:exclude "lisp/tablist.el" "lisp/tablist-filter.el"))))

;; (quelpa '(image-roll :fetcher git
;; :url "https://github.com/dalanicolai/image-roll.el.git"))

;; (pdf-tools-install)


(use-package openwith
    :ensure t)
(openwith-mode t)
(setq openwith-associations '(("\\.pdf\\'" "sioyek" (file))))

(use-package flycheck
:ensure t
:init
(global-flycheck-mode t))

(use-package org-modern   
    :ensure t)
  (set-face-attribute 'default nil :family "Iosevka")
 (set-face-attribute 'variable-pitch nil :family "Iosevka Aile")
(set-face-attribute 'org-modern-symbol nil :family "Iosevka")
(set-face-attribute 'fixed-pitch nil :family "Iosevka")
(with-eval-after-load 'org (global-org-modern-mode))

(org-babel-do-load-languages
'org-babel-load-languages
'((emacs-lisp . t)
(python . t)))

(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(setq org-confirm-babel-evaluate nil)

;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
(when (string-equal (buffer-file-name)
(expand-file-name "~/.emacs.d/config.org"))
 ;; Dynamic scoping to the rescue
(let ((org-confirm-babel-evaluate nil))
(org-babel-tangle))))
(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(setq org-capture-templates
     '(("n" "Notes" entry
        (file psachin/create-notes-file)
	"* TITLE%?\n %U")
       ("t" "TODO" entry (file+headline "~/Documents/TODO.org" "Tasks")
	"* TODO %?\n%T" :prepend t)
        ("m" "Meetings" entry (file+headline "~/Documents/Meetings.org" "Meetings")
	"* %?\n%T" :prepend t)))
(require 'org-macs)
   (use-package org-roam
   :ensure t
   :custom
   (org-roam-directory "~/Documents/org-roam")
   :config
   (org-roam-db-autosync-mode))

(use-package app-launcher
:straight '(app-launcher :host github :repo "SebastienWae/app-launcher"))

(defun efs/run-in-background (command)
 (let ((command-parts (split-string command "[ ]+")))
 (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))


(defun efs/exwm-init-hook ()
;; Make workspace 1 be the one where we land at startup
(exwm-workspace-switch-create 1))


(defun efs/exwm-update-class ()
(exwm-workspace-rename-buffer exwm-class-name))

(use-package exwm
 :config

 ;set default number of workspaces
 (setq exwm-workspace-number 5)

 ;hook to name buffers after application
 (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

 ;; When EXWM starts up, do some extra confifuration
 (add-hook 'exwm-init-hook #'efs/exwm-init-hook)

 ;keys to pass to emacs
 (setq exwm-input-prefix-keys
 '(?\C-x
 ?\C-u
 ?\C-h
 ?\M-x
 ?\C-s
 ?\C-;))

 (setq exwm-input-simulation-keys
       '(([?\M-w] . [C-c])
	 ([?\C-y] . [C-v])
	 ([?\C-s] . [C-f])))

 (setq exwm-input-global-keys
       `(
	 ([s-left] . windmove-left)
	 ([s-right] . windmove-right)
	 ([s-up] . windmove-up)
	 ([s-down] . windmove-down)


   ,@(mapcar (lambda (i)
 `(,(kbd (format "C-%d" i)) .
 (lambda ()
 (interactive)
 (exwm-workspace-switch-create ,i))))
 (number-sequence 0 9))
))

 (require 'exwm-randr)
 (exwm-randr-enable)
 (start-process-shell-command "xrandr" nil "/home/alex/.screenlayout/screen-detect.sh")

 (setq exwm-randr-workspace-monitor-plist '(4 "DP-1-1" 5 "DP-1-1"))

 (exwm-input-set-key (kbd "C-`") 'app-launcher-run-app)

 (exwm-enable))

(use-package desktop-environment
:after exwm
:config (desktop-environment-mode))
