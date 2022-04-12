local wezterm = require 'wezterm';

-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local edge_background = "#333333"
  local background = "#666666"
  local foreground = "#eaeaea"

  if tab.is_active then
    background = "#7aa6da"
    foreground = "#ffffff"
  elseif hover then
    background = "#000000"
    foreground = "#000000"
  end

  local edge_foreground = background

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  local title = tab.active_pane.title
  local hostname = wezterm.hostname()
  -- emit current host
  local has_hostname = title:find(hostname)
  if has_hostname ~= nil then
     x, y = has_hostname
     title = wezterm.truncate_left(title, title:len() - x - hostname:len() - 1)
  end
  if string.len(title) > max_width then
     title = wezterm.truncate_right(title, max_width-4) .. "…"
  end

  return {
    {Background={Color=edge_foreground}},
    {Foreground={Color=edge_background}},
    {Text=SOLID_RIGHT_ARROW},
    {Background={Color=background}},
    {Foreground={Color=foreground}},
    {Text=title},
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_RIGHT_ARROW},
  }
end)

local launch_menu = {}
local default_prog = {"/usr/bin/zsh", "-l"}
local default_cwd = "/home/farseerfc"

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  distro = "Arch"
  -- Add an entry that will spawn into the distro with the default shell
  table.insert(launch_menu, {
    label = distro .. " (WSL default shell)",
    args = {"wsl.exe", "--distribution", distro},
  })
  default_prog = {"wsl.exe", "--distribution", "Arch"}
  -- default_prog = {"/usr/bin/zsh", "-l"}
end

return {
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  window_background_opacity = 0.8,
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  },
  enable_scroll_bar = true,
  colors = {
    visual_bell = "#202020",
    tab_bar = {
      background = "#000000",
    },
  },
  launch_menu = launch_menu,
  default_prog = default_prog,
  default_cwd = default_cwd,
  tab_max_width = 32,
}
