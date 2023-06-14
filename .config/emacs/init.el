(setq inhibit-startup-message t)

(scroll-bar-mode -1)
(tool-bar-mode -1)
; (tooltip-mode -1)

(menu-bar-mode -1)

(load-theme 'wombat)

;; allow ESC to quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
