-----------------------
--  AwesomeWM theme  --
-- based on Dust GTK --
--   <tdy@gmx.com>   --
-----------------------

require("awful")

-- {{{ Main
theme = {}
theme.wallpaper = awful.util.getdir("config") .. "/themes/dust/Galaxy3.jpg"
theme.font = "Source Han Sans 12"
-- }}}

-- {{{ Colors
theme.fg_normal = "#aaaaaa"
theme.fg_focus = "#111111"
theme.fg_urgent = "#ffffff"
theme.fg_tooltip = "#1a1a1a"
theme.fg_em = "#d6d6d6"

theme.bg_normal = "#1a1a1a"
theme.bg_focus = "#908884"
theme.bg_urgent = "#cd7171"
theme.bg_tooltip = "#d6d6d6"
theme.bg_em = "#5a5a5a"
theme.bg_systray = theme.bg_normal

theme.fg_widget = "#908884"
theme.fg_center_widget = "#636363"
theme.fg_end_widget = "#1a1a1a"
theme.bg_widget = "#2a2a2a"
theme.border_widget = "#3F3F3F"
-- }}}

-- {{{ Borders
theme.border_width = 0
theme.border_normal = "#222222"
theme.border_focus = "#908884"
theme.border_marked = "#91231c"
theme.border_tooltip = "#444444"
-- }}}

-- {{{ Titlebars
theme.titlebar_bg_focus = "#3F3F3F"
theme.titlebar_bg_normal = "#3F3F3F"
-- }}}

-- {{{ Mouse finder
theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]
-- }}}

-- {{{ Menu
theme.menu_height = 24
theme.menu_width = 500
-- }}}

-- {{{ Taglist
theme.taglist_squares_sel = awful.util.getdir("config") .. "/themes/dust/taglist/squaref.png"
theme.taglist_squares_unsel = awful.util.getdir("config") .. "/themes/dust/taglist/square.png"
-- }}}

-- {{{ Misc
theme.awesome_icon = awful.util.getdir("config") .. "/themes/dust/awesome-dust22.png"
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
-- }}}

-- {{{ Layout
theme.layout_tile = awful.util.getdir("config") .. "/themes/dust/layouts/tilew.png"
theme.layout_tileleft = awful.util.getdir("config") .. "/themes/dust/layouts/tileleftw.png"
theme.layout_tilebottom = awful.util.getdir("config") .. "/themes/dust/layouts/tilebottomw.png"
theme.layout_tiletop = awful.util.getdir("config") .. "/themes/dust/layouts/tiletopw.png"
theme.layout_fairv = awful.util.getdir("config") .. "/themes/dust/layouts/fairvw.png"
theme.layout_fairh = awful.util.getdir("config") .. "/themes/dust/layouts/fairhw.png"
theme.layout_spiral = awful.util.getdir("config") .. "/themes/dust/layouts/spiralw.png"
theme.layout_dwindle = awful.util.getdir("config") .. "/themes/dust/layouts/dwindlew.png"
theme.layout_max = awful.util.getdir("config") .. "/themes/dust/layouts/maxw.png"
theme.layout_fullscreen = awful.util.getdir("config") .. "/themes/dust/layouts/fullscreenw.png"
theme.layout_magnifier = awful.util.getdir("config") .. "/themes/dust/layouts/magnifierw.png"
theme.layout_floating = awful.util.getdir("config") .. "/themes/dust/layouts/floatingw.png"
-- }}}

-- {{{ Titlebar
theme.titlebar_close_button_focus = "/usr/share/awesome/themes/default/titlebar/close_focus.png"
theme.titlebar_close_button_normal = "/usr/share/awesome/themes/default/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active = "/usr/share/awesome/themes/default/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = "/usr/share/awesome/themes/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active = "/usr/share/awesome/themes/default/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = "/usr/share/awesome/themes/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active = "/usr/share/awesome/themes/default/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = "/usr/share/awesome/themes/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active = "/usr/share/awesome/themes/default/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = "/usr/share/awesome/themes/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = "/usr/share/awesome/themes/default/titlebar/maximized_normal_inactive.png"
-- }}}

-- {{{ Widgets
theme.widget_disk = awful.util.getdir("config") .. "/themes/dust/widgets/disk.png"
theme.widget_cpu = awful.util.getdir("config") .. "/themes/dust/widgets/cpu.png"
theme.widget_ac = awful.util.getdir("config") .. "/themes/dust/widgets/ac.png"
theme.widget_acblink = awful.util.getdir("config") .. "/themes/dust/widgets/acblink.png"
theme.widget_blank = awful.util.getdir("config") .. "/themes/dust/widgets/blank.png"
theme.widget_batfull = awful.util.getdir("config") .. "/themes/dust/widgets/batfull.png"
theme.widget_batmed = awful.util.getdir("config") .. "/themes/dust/widgets/batmed.png"
theme.widget_batlow = awful.util.getdir("config") .. "/themes/dust/widgets/batlow.png"
theme.widget_batempty = awful.util.getdir("config") .. "/themes/dust/widgets/batempty.png"
theme.widget_vol = awful.util.getdir("config") .. "/themes/dust/widgets/vol.png"
theme.widget_mute = awful.util.getdir("config") .. "/themes/dust/widgets/mute.png"
theme.widget_pac = awful.util.getdir("config") .. "/themes/dust/widgets/pac.png"
theme.widget_pacnew = awful.util.getdir("config") .. "/themes/dust/widgets/pacnew.png"
theme.widget_mail = awful.util.getdir("config") .. "/themes/dust/widgets/mail.png"
theme.widget_mailnew = awful.util.getdir("config") .. "/themes/dust/widgets/mailnew.png"
theme.widget_temp = awful.util.getdir("config") .. "/themes/dust/widgets/temp.png"
theme.widget_tempwarn = awful.util.getdir("config") .. "/themes/dust/widgets/tempwarm.png"
theme.widget_temphot = awful.util.getdir("config") .. "/themes/dust/widgets/temphot.png"
theme.widget_wifi = awful.util.getdir("config") .. "/themes/dust/widgets/wifi.png"
theme.widget_nowifi = awful.util.getdir("config") .. "/themes/dust/widgets/nowifi.png"
theme.widget_mpd = awful.util.getdir("config") .. "/themes/dust/widgets/mpd.png"
theme.widget_play = awful.util.getdir("config") .. "/themes/dust/widgets/play.png"
theme.widget_pause = awful.util.getdir("config") .. "/themes/dust/widgets/pause.png"
theme.widget_ram = awful.util.getdir("config") .. "/themes/dust/widgets/ram.png"

theme.widget_mem = awful.util.getdir("config") .. "/themes/dust/tp/ram.png"
theme.widget_swap = awful.util.getdir("config") .. "/themes/dust/tp/swap.png"
theme.widget_fs = awful.util.getdir("config") .. "/themes/dust/tp/fs_01.png"
theme.widget_fs2 = awful.util.getdir("config") .. "/themes/dust/tp/fs_02.png"
theme.widget_up = awful.util.getdir("config") .. "/themes/dust/tp/up.png"
theme.widget_down = awful.util.getdir("config") .. "/themes/dust/tp/down.png"
-- }}}

return theme
