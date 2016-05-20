function batteryInfo()
  local percent_handle = io.popen('echo -n `acpi | grep -o \'[0-9]\\+%\'`');
  local percent = percent_handle:read('*a');
  percent_handle:close();

  local status_handle = io.popen('echo -n `acpi | grep -o \'Charging\' | sed \'s/Charging/+/g\'`');
  local status = status_handle:read('*a');
  status_handle:close();

  local result = '' .. percent .. ''  .. status .. '';
  return result;
end

function memoryInfo()
  local handle = io.popen('echo -n `free -m  | fgrep \'Mem\' | awk \'{print $3}\' | sed \'s/$/ MB/\'`')
  local result = handle:read('*a');
  return result;
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
	local text = " " .. os.date("%a %Y-%m-%d %H:%M") .. " ";
	clockwidget:set_text(text)
end

function getSensorTemperature(sensor, what) 
	local handle = io.popen('echo -n `sensors ' .. sensor .. ' | fgrep "' .. what .. '"  | awk \'{print $2}\' | head -n 1`')
	local result = handle:read("*a")
	handle:close()
	return result;
end

function updateCpuTemperatureWidget()
	-- TODO make CPU sensor name tuneable in rc.lua
	local temperature = getSensorTemperature('dell_smm-virtual-0', 'CPU')
	temperatureWidget:set_text(" cpu: " .. temperature .. " ")
end

function updateGpuTemperatureWidget() 
	-- TODO make CPU sensor name tuneable in rc.lua
	local temperature = getSensorTemperature('dell_smm-virtual-0', 'GPU')
	videoTemperatureWidget:set_text(" gpu: " .. temperature .. " ") 
end

function updateMemoryWidget()
  local info = memoryInfo();
  memorywidget:set_text(" memory: " .. info .. " ");
end

function updateBatteryWidget() 
	local info = batteryInfo();
	batterywidget:set_text(" battery: " .. info .. " ");
end
