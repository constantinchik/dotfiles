-- Personal keybinding overrides.
-- See current bindings and descriptions: omarchy menu keybindings --print

-- ── Unbind Omarchy defaults that clash with the bindings below ──────────
hl.unbind("SUPER + RETURN") -- was: Terminal (moved to SUPER + T)
hl.unbind("SUPER + T")      -- was: Toggle window floating/tiling (moved to SUPER + W)
hl.unbind("SUPER + W")      -- was: Close window (moved to SUPER + Q)
hl.unbind("SUPER + J")      -- was: Toggle window split
hl.unbind("SUPER + K")      -- was: Keybindings (moved to SUPER + SLASH)
hl.unbind("SUPER + L")      -- was: Toggle workspace layout
hl.unbind("SUPER + SLASH")  -- was: Monitor scaling up

-- ── Applications (focus-or-launch) ──────────────────────────────────────
o.bind("SUPER + T", "Terminal (Ghostty)", "omarchy-focus-or-launch com.mitchellh.ghostty ghostty")
o.bind("SUPER + B", "Browser (Chromium)", "omarchy-focus-or-launch chromium chromium")

-- ── Window management ───────────────────────────────────────────────────
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())
o.bind("SUPER + W", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
o.bind("SUPER + SLASH", "Show key bindings", "omarchy-menu-keybindings")

-- ── Vim-style focus movement (hjkl) ─────────────────────────────────────
o.bind("SUPER + H", "Move window focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Move window focus down", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Move window focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Move window focus right", hl.dsp.focus({ direction = "r" }))

-- ── Vim-style window swapping (SUPER + SHIFT + hjkl) ────────────────────
o.bind("SUPER + SHIFT + H", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + SHIFT + J", "Swap window down", hl.dsp.window.swap({ direction = "d" }))
o.bind("SUPER + SHIFT + K", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + SHIFT + L", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))

-- ── Move window to prev/next workspace (SUPER + ALT + h/l) ──────────────
o.bind("SUPER + ALT + H", "Move window to prev workspace", hl.dsp.window.move({ workspace = "r-1" }))
o.bind("SUPER + ALT + L", "Move window to next workspace", hl.dsp.window.move({ workspace = "r+1" }))

-- ── Move/snap floating windows (CTRL + ALT + hjkl) ──────────────────────
o.bind("CTRL + ALT + H", "Move/snap window left", hl.dsp.window.move({ direction = "l" }))
o.bind("CTRL + ALT + J", "Move/snap window down", hl.dsp.window.move({ direction = "d" }))
o.bind("CTRL + ALT + K", "Move/snap window up", hl.dsp.window.move({ direction = "u" }))
o.bind("CTRL + ALT + L", "Move/snap window right", hl.dsp.window.move({ direction = "r" }))
