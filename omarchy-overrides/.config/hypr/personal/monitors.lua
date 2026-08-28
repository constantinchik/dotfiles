-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Straight 1x setup for low-resolution displays like 1080p or 1440p.
hl.env("GDK_SCALE", "1")

-- Primary monitor: LG ULTRAGEAR 27" OLED 1440p @ 240Hz (left).
hl.monitor({ output = "DP-1", mode = "2560x1440@240", position = "0x0", scale = 1 })

-- Secondary monitor: LG ULTRAGEAR 27" 1440p @ 144Hz (right, rotated 270°).
hl.monitor({ output = "HDMI-A-1", mode = "2560x1440@144", position = "2560x-220", scale = 1, transform = 3 })

-- Fallback for any other monitor.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- Workspaces 1-7 on the primary monitor (DP-1).
hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true })
for workspace = 2, 7 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "DP-1" })
end

-- Workspaces 8-10 on the secondary monitor (HDMI-A-1).
hl.workspace_rule({ workspace = "8", monitor = "HDMI-A-1", default = true })
for workspace = 9, 10 do
  hl.workspace_rule({ workspace = tostring(workspace), monitor = "HDMI-A-1" })
end
