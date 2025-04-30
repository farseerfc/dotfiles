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
    background = "#7aa6da"
    foreground = "#aaaaaa"
  end

  local edge_foreground = background

  -- ensure that the titles fit in the available space,
  -- and that we have room for the edges.
  local title = tab.active_pane.title .. ' '
  local hostname = wezterm.hostname()
  -- emit current host
  local has_hostname = title:find(hostname)
  if has_hostname ~= nil then
     x, y = has_hostname
     title = wezterm.truncate_left(title, title:len() - x - hostname:len() - 1)
  end
  if string.len(title)+string.len(tab.tab_index) > max_width then
     title = wezterm.truncate_right(title, max_width-5) .. "…"
  end

  return {
    {Background={Color=edge_foreground}},
    {Foreground={Color=edge_background}},
    {Text=SOLID_RIGHT_ARROW..(tab.tab_index+1)},
    {Background={Color=background}},
    {Foreground={Color=foreground}},
    {Text=title},
    {Background={Color=edge_background}},
    {Foreground={Color=edge_foreground}},
    {Text=SOLID_RIGHT_ARROW},
  }
end)

local default_prog = {"/usr/bin/zsh", "-l"}
local default_cwd = "/home/farseerfc"

-- tmux style leader keys
local keys = {
    {key="|", mods="LEADER", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key=":", mods="LEADER", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
    {key="-", mods="LEADER", action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}},
    {key="t", mods="LEADER", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
    {key="c", mods="LEADER", action=wezterm.action{SpawnTab="CurrentPaneDomain"}},
    {key="LeftArrow", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Left"}},
    {key="RightArrow", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Right"}},
    {key="UpArrow", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Up"}},
    {key="DownArrow", mods="LEADER", action=wezterm.action{ActivatePaneDirection="Down"}},
    {key="w", mods="LEADER", action=wezterm.action{CloseCurrentTab={confirm=true}}},
    -- Send "CTRL-B" to the terminal when pressing CTRL-B, CTRL-B
    {key="b", mods="LEADER", action=wezterm.action{SendString="\x02"}},
}

for i = 1,9 do
   tabkey = {key=tostring(i), mods="LEADER", action=wezterm.action{ActivateTab=(i-1)}}
   table.insert(keys,tabkey)
end

local ctrlkeys = {}
for i, key in ipairs(keys) do
   ctrlkey = {key=key.key, mods=key.mods .. "|CTRL", action=key.action}
   table.insert(ctrlkeys, ctrlkey)
   table.insert(ctrlkeys, key)
end

local config = {
  -- tab bar
  tab_bar_at_bottom = true,
  use_fancy_tab_bar = false,
  -- visual
  font = wezterm.font_with_fallback {"Fira Code", "Noto Color Emoji", "Symbols Nerd Font", "Noto Sans Mono", "Noto Sans CJK SC", "HanaMinA", "HanaMinB"} ,
  window_background_opacity = 0.8,
  visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150,
  },
  enable_scroll_bar = true,
  warn_about_missing_glyphs=false,
  -- color
  colors = {
    visual_bell = "#202020",
    tab_bar = {
      background = "#000000",
    },
  },
  -- behavior
  unix_domains = {
    -- https://github.com/wez/wezterm/issues/1299#issuecomment-993770970
    -- start a unix socket domain on wezterm mux
    {name = "unix",}
  },
  default_prog = default_prog,
  default_cwd = default_cwd,
  tab_max_width = 32,
  key_map_preference = "Mapped",
  -- tmux style key binding
  leader = { key="b", mods="CTRL", timeout_milliseconds=1000 },
  keys = ctrlkeys,
  -- cursors
  default_cursor_style = "BlinkingBar",
  cursor_blink_rate = 500,
  enable_wayland = true,
  -- compose_cursor = "orange",
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  distro = "Arch"
  -- Add an entry that will spawn into the distro with the default shell
  config.launch_menu = {}
  table.insert(config.launch_menu, {
    label = distro .. " (WSL default shell)",
    args = {"wsl.exe", "--cd", "/home/farseerfc", "--distribution", distro},
    default_cwd = "/home/farseerfc"
  })
  config.default_prog = {"wsl.exe", "--cd", "/home/farseerfc", "--distribution", "Arch"}
  config.default_cwd = "/home/farseerfc"
end

return config
