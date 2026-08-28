-- Personal window rules.
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- OBS reopens its Qt dialogs wherever they sat last, which after a monitor
-- change can be entirely outside the layout (a "Plugin Load Error" box turned
-- up at x = -806, off the left edge of DP-1). Those dialogs are
-- application-modal, so an off-screen one silently eats every click and
-- keypress meant for the main window: OBS keeps its tile but can no longer be
-- focused or closed. Centering its floating windows keeps them reachable.
--
-- Tagged rather than centered outright so windowed projectors, which are
-- floating too and get parked deliberately, stay where they are put.
-- Hyprland matches with RE2, so the exclusion needs (?i) and a tag; there is
-- no negative lookahead.
o.window({ class = "^com\\.obsproject\\.Studio$", float = true }, { tag = "+obs-centered" })
o.window({ class = "^com\\.obsproject\\.Studio$", title = "(?i).*projector.*" }, { tag = "-obs-centered" })
o.window({ tag = "obs-centered" }, { center = true })
