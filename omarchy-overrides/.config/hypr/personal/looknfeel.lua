-- Change the default Omarchy look'n'feel.
-- Transparency and blur adopted from elifouts-Dotfiles.

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 10,
    border_size = 0,
    resize_on_border = true,
    allow_tearing = false,
    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    active_opacity = 0.78,
    inactive_opacity = 0.7,
    fullscreen_opacity = 1,

    blur = {
      enabled = true,
      size = 3,
      passes = 5,
      new_optimizations = true,
      ignore_opacity = true,
      xray = false,
      popups = true,
    },

    shadow = {
      enabled = true,
      range = 15,
      render_power = 5,
      color = "rgba(0,0,0,.5)",
    },
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = true,
    focus_on_activate = true,
  },

  gestures = {
    workspace_swipe_distance = 300,
    workspace_swipe_cancel_ratio = 0.05,
    workspace_swipe_min_speed_to_force = 0,
  },
})

-- Custom animation curves (snappy and fluid).
hl.curve("fluid", { type = "bezier", points = { { 0.15, 0.85 }, { 0.25, 1 } } })
hl.curve("snappy", { type = "bezier", points = { { 0.3, 1 }, { 0.4, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "fluid", style = "popin 5%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.5, bezier = "snappy" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.7, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "fluid", style = "slidefadevert -35%" })
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "snappy", style = "popin 70%" })
