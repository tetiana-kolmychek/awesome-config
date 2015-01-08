function batteryInfo(adapter)
	spacer = " "
	local fcur = io.open("/sys/class/power_supply/"..adapter.."/energy_now")    
	local fcap = io.open("/sys/class/power_supply/"..adapter.."/energy_full")
	local fsta = io.open("/sys/class/power_supply/"..adapter.."/status")
	
	local cur = fcur:read()
	local cap = fcap:read()
	local sta = fsta:read()
	
	fcur:close()
	fcap:close()
	fsta:close()
	
	local battery = math.floor(cur * 100 / cap)
	
	if sta:match("Charging") then
		return '<span color="#00FF00">' .. battery .. "%+ </span>"
	end
	
	if sta:match("Discharging") then
		if tonumber(battery) < 10 then
			local message = {
				text       = "Battery low!"..spacer..battery.."%"..spacer.."left!"
				, timeout    = 2
				, position   = "top_right"
				, fg         = "#FF0000"
				, bg         = beautiful.bg_focus
			};
			naughty.notify(message);
			return "<span color=\"red\">".. battery .. "%</span>"
		end;
		
		if tonumber(battery) < 25 then
			return "<span color=\"orange\">".. battery .. "%</span>"
		end
		
		return battery .. "%"  
	end
	
	if sta:match("Unknown") then
		return '<span color="yellow">Uknown</span>'
	end;
	
	return "A/C"
end

function inTable(tbl, item)
	for key, value in pairs(tbl) do
		if value == item then return true end
	end
	return false
end

function killable(app)
	return not inTable(unkillableApps, app);
end

function setWallpaper(screen)
	if beautiful.wallpaper then
		for s = 1, screen.count() do
			gears.wallpaper.maximized(beautiful.wallpaper, s, true)
		end
	end
end

function updateClock() 
	text = " " .. os.date("%a %Y-%m-%d %H:%M") .. " ";
	clockwidget:set_text(text)
end

function getSensorTemperature(sensor) 
	local handle = io.popen('echo -n `sensors ' .. sensor .. ' | grep temp1 | grep -o "+[0-9.C°]*" | head -n 1`')
	local result = handle:read("*a")
	handle:close()
	return result;
end

function updateCpuTemperatureWidget()
	-- TODO make CPU sensor name tuneable in rc.lua
	local temperature = getSensorTemperature('k10temp-pci-00c3')
	temperatureWidget:set_text(" cpu: " .. temperature .. " ")
end

function updateGpuTemperatureWidget() 
	-- TODO make CPU sensor name tuneable in rc.lua
	local temperature = getSensorTemperature('radeon-pci-0600')
	videoTemperatureWidget:set_text(" gpu: " .. temperature .. " ") 
end

function updateBatteryWidget() 
	local info = batteryInfo("BAT0")
	batterywidget:set_markup(info)
end
