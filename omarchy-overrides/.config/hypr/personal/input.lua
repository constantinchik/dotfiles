-- Keep only your personal input overrides here. Uncommented settings below
-- replace Omarchy's defaults.

hl.config({
  input = {
    -- US and Ukrainian layouts, toggled with Ctrl + Space. Caps becomes Ctrl.
    kb_layout = "us,ua",
    kb_options = "grp:ctrl_space_toggle:nocaps",

    -- Fast keyboard repeat.
    repeat_rate = 40,
    repeat_delay = 200,

    -- Start with numlock on by default.
    numlock_by_default = true,

    -- Map touchpad scrolling to mouse scroll in X11 apps.
    scroll_method = "2fg",

    touchpad = {
      -- One-click tapping.
      tap_to_click = true,

      -- Control the speed of your scrolling.
      scroll_factor = 0.4,
    },
  },
})

-- Scroll nicely in the terminal.
o.window("(Alacritty|kitty|foot)", { scroll_touchpad = 1.5 })
o.window("com.mitchellh.ghostty", { scroll_touchpad = 0.2 })
