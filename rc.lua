gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
beautiful = require("beautiful")
naughty = require("naughty")
-- Additional functions.
require("ivko.run")
require("ivko.theme")
require("ivko.functions")

terminal = "konsole"
videoplayer = "smplayer"
browser = "firefox"
filemanager = "dolphin"
editor = "kate"
screenlockercommand = "qdbus-qt4 org.freedesktop.ScreenSaver /ScreenSaver Lock"
suspendcommand = "qdbus-qt4 --system org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Suspend true"
lockandsuspendcommand = screenlockercommand .. '; sleep 2; ' .. suspendcommand


modkey = "Mod4"

-- naughty.config.default_preset.timeout		= 4

setWallpaper(screen)

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
	                       -- Make sure we don't go into an endless error loop
	                       if in_error then return end
	                      in_error = true
	                      
	                      naughty.notify({ preset = naughty.config.presets.critical,
	                                       title = "Oops, an error happened!",
	                                       text = err })
	                      in_error = false
	                      end)
	end
-- }}}

unkillableApps = {
	'Konsole',
	'Thunderbird',
	'Plasma'
}
	
layouts = {
	-- Good tiling layouts
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	-- Fixed layouts
	awful.layout.suit.fair,
-- 	awful.layout.suit.fair.horizontal
}

-- Making tags.
tags = { }
for s = 1, screen.count() do tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f' }, s, layouts[1]) end

my_wibox = {}
my_promptbox = {}
my_layoutbox = {}
my_taglist = {}
my_systray = wibox.widget.systray()

my_taglist.buttons = awful.util.table.join(
	awful.button({ }, 1, awful.tag.viewonly),
	awful.button({ modkey }, 1, awful.client.movetotag),
	awful.button({ }, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, awful.client.toggletag),
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
)

my_tasklist = {}
my_tasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end))

-- batterywidget = wibox.widget.textbox()
-- batterywidget:set_text("[ battery ]")

clockwidget = wibox.widget.textbox()
clockwidget:set_text(" [ clock (20 seconds) ] ")

temperatureWidget = wibox.widget.textbox()
temperatureWidget:set_text(" [ cpu t (5 seconds) ] ")

videoTemperatureWidget = wibox.widget.textbox()
videoTemperatureWidget:set_text(" [ gpu t (5 seconds) ] ")

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    my_promptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    my_layoutbox[s] = awful.widget.layoutbox(s)
    my_layoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    my_taglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, my_taglist.buttons)

    -- Create a tasklist widget
    my_tasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, my_tasklist.buttons)

	-- Create the wiboxes
	my_wibox[s] = awful.wibox({ position = "top", screen = s, align = "left"})
	-- Add widgets to the wibox - order matters
	local left_layout = wibox.layout.fixed.horizontal();
	left_layout:add(my_taglist[s]);
	left_layout:add(my_promptbox[s]);	

	local right_layout = wibox.layout.fixed.horizontal();
	right_layout:add(videoTemperatureWidget);
	right_layout:add(temperatureWidget);
	right_layout:add(clockwidget);
	--right_layout:add(batterywidget);
	if screen.count() == 1 and s == 1 then right_layout:add(my_systray); end
	if screen.count() == 2 and s == 1 then right_layout:add(my_systray); end

	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout);
	layout:set_middle(my_tasklist[s]);
	layout:set_right(right_layout);

	my_wibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart),
--     awful.key({ modkey, "Control", "Shift" }, "q", awesome.quit),  
    awful.key({ modkey,           }, "]",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "[",     function () awful.tag.incmwfact(-0.05)    end),
--     awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
--     awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "]",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "[",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Application bindings.
	awful.key({ modkey,	}, "l", function() awful.util.spawn(screenlockercommand) end),
	awful.key({ 		}, "XF86Sleep", function() awful.util.spawn_with_shell(lockandsuspendcommand); end),
	awful.key({ modkey,	}, "x", function() awful.util.spawn("xrandr --auto") end),
	-- awful.key({ modkey, "Control"}, "h", function() naughty.notify({ title = "Shortcuts", text= "Package.path:\n" .. package.path .. "" , timeout=80});  end),

    -- Prompt
    awful.key({ modkey },            "r",     function () my_promptbox[mouse.screen]:run() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, }, "=",      function (c) c.fullscreen = not c.fullscreen  end),
	    awful.key({ modkey, ""   }, "q",      function (c)  
										if (killable(c.class)) then
										c:kill() 
										else 
											naughty.notify({ text       = 'Warning: App "' .. c.class .. '" cannot be killed'
												, timeout    = 2
												, position   = "top_right"
												, fg         = "#FFDD00"
												, bg         = beautiful.bg_focus
											});
										end;
    end),
--     awful.key({ "Control", ""   }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end)
)

keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

globalkeys = awful.util.table.join(globalkeys, 
		awful.key({modkey,	}, "a", function()
			local screen = mouse.screen
			if tags[screen][0xA] then
				awful.tag.viewonly(tags[screen][0xA])
			end
		end),
		awful.key({modkey, "Control" }, "a", function ()
			local screen = mouse.screen
			if tags[screen][0xA] then
				awful.tag.viewtoggle(tags[screen][0xA])
			end
		end),
		awful.key({modkey, "Shift" }, "a", function ()
			if client.focus and tags[client.focus.screen][0xA] then
				awful.client.movetotag(tags[client.focus.screen][0xA])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "a", function ()
			if client.focus and tags[client.focus.screen][0xA] then
				awful.client.toggletag(tags[client.focus.screen][0xA])
			end
		end),
		awful.key({modkey,	}, "b", function()
			local screen = mouse.screen
			if tags[screen][0xB] then
				awful.tag.viewonly(tags[screen][0xB])
			end
		end),
		awful.key({modkey, "Control" }, "b", function ()
			local screen = mouse.screen
			if tags[screen][0xB] then
				awful.tag.viewtoggle(tags[screen][0xB])
			end
		end),
		awful.key({modkey, "Shift" }, "b", function ()
			if client.focus and tags[client.focus.screen][0xB] then
				awful.client.movetotag(tags[client.focus.screen][0xB])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "b", function ()
			if client.focus and tags[client.focus.screen][0xB] then
				awful.client.toggletag(tags[client.focus.screen][0xB])
			end
		end),
		awful.key({modkey,	}, "c", function()
			local screen = mouse.screen
			if tags[screen][0xC] then
				awful.tag.viewonly(tags[screen][0xC])
			end
		end),
		awful.key({modkey, "Control" }, "c", function ()
			local screen = mouse.screen
			if tags[screen][0xC] then
				awful.tag.viewtoggle(tags[screen][0xC])
			end
		end),
		awful.key({modkey, "Shift" }, "c", function ()
			if client.focus and tags[client.focus.screen][0xC] then
				awful.client.movetotag(tags[client.focus.screen][0xC])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "c", function ()
			if client.focus and tags[client.focus.screen][0xC] then
				awful.client.toggletag(tags[client.focus.screen][0xC])
			end
		end),
		awful.key({modkey,	}, "d", function()
			local screen = mouse.screen
			if tags[screen][0xD] then
				awful.tag.viewonly(tags[screen][0xD])
			end
		end),
		awful.key({modkey, "Control" }, "d", function ()
			local screen = mouse.screen
			if tags[screen][0xD] then
				awful.tag.viewtoggle(tags[screen][0xD])
			end
		end),
		awful.key({modkey, "Shift" }, "d", function ()
			if client.focus and tags[client.focus.screen][0xD] then
				awful.client.movetotag(tags[client.focus.screen][0xD])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "d", function ()
			if client.focus and tags[client.focus.screen][0xD] then
				awful.client.toggletag(tags[client.focus.screen][0xD])
			end
		end),
		awful.key({modkey,	}, "e", function()
			local screen = mouse.screen
			if tags[screen][0xE] then
				awful.tag.viewonly(tags[screen][0xE])
			end
		end),
		awful.key({modkey, "Control" }, "e", function ()
			local screen = mouse.screen
			if tags[screen][0xE] then
				awful.tag.viewtoggle(tags[screen][0xE])
			end
		end),
		awful.key({modkey, "Shift" }, "e", function ()
			if client.focus and tags[client.focus.screen][0xE] then
				awful.client.movetotag(tags[client.focus.screen][0xE])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "e", function ()
			if client.focus and tags[client.focus.screen][0xE] then
				awful.client.toggletag(tags[client.focus.screen][0xE])
			end
		end),
		awful.key({modkey,	}, "f", function()
			local screen = mouse.screen
			if tags[screen][0xF] then
				awful.tag.viewonly(tags[screen][0xF])
			end
		end),
		awful.key({modkey, "Control" }, "f", function ()
			local screen = mouse.screen
			if tags[screen][0xF] then
				awful.tag.viewtoggle(tags[screen][0xF])
			end
		end),
		awful.key({modkey, "Shift" }, "f", function ()
			if client.focus and tags[client.focus.screen][0xF] then
				awful.client.movetotag(tags[client.focus.screen][0xF])
			end
		end),
		awful.key({modkey, "Control", "Shift" }, "f", function ()
			if client.focus and tags[client.focus.screen][0xF] then
				awful.client.toggletag(tags[client.focus.screen][0xF])
			end
		end)
		)


clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

-- {{{ Rules
-- TODO Move into separated file?
awful.rules.rules = {
	-- All clients will match this rule.
	{ rule = { },
	properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons
	}},
	-- Application rules
	-- ==== Tags ====
	-- NOTE In the xprop output, the class is the second value of the WM_CLASS property. 
	{ rule = { class = "konsole" },  properties = { tag = tags[1][1], opacity = 0.9 }},
	{ rule = { class = "Firefox" },  properties = { tag = tags[1][2] }},
	{ rule = { class = "Dolphin" },  properties = { tag = tags[1][3] }},
	{ rule = { class = "Chromium" }, properties = { tag = tags[1][5], floating = false }},
	{ rule = { class = "Smplayer" },  properties = { tag = tags[1][6] }},
  { rule = { class = "mpv" }, properties = { tag = tags[1][6], ontop = true, floating = true }},
  { rule = { class = "ksshaskpass" }, properties = { tag = tags[1][4], urgent = true } },
  { rule = { class = "VirtualBox" },  properties = { tag = tags[1][7] }},
	{ rule = { class = "Keepassx" },  properties = { tag = tags[1][8] }},
	{ rule = { class = "wpa_Gui" },  properties = { tag = tags[1][0xc] }},
	{ rule = { class = "Thunderbird" }, properties = { tag = tags[1][0xd], floating = false, }},
	{ rule = { class = "Skype" }, properties = { tag = tags[1][0xe] }},
	{ rule = { class = "Plasma" }, properties = { floating = true }},
  { rule = { class = 'Plugin-container' }, properties = { floating = true, fullscreen = true }}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

require("ivko.hooks")

-- }}}
