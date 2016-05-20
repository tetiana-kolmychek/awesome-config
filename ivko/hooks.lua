--- Battery update
--- TODO add setting to rc.lua that allows to disable battery timer
batteryTimer = timer({ timeout = 20 })
batteryTimer:connect_signal("update", batteryInfo);
batteryTimer:connect_signal("timeout", updateBatteryWidget);
batteryTimer:start()
updateBatteryWidget();

--- Clock update
clockTimer = timer({ timeout = 20 })
clockTimer:connect_signal("timeout", updateClock)
clockTimer:start()
updateClock();

memoryTimer = timer({ timeout = 10 })
memoryTimer:connect_signal("timeout", updateMemoryWidget)
memoryTimer:start();
updateMemoryWidget();

temperatureTimer = timer({ timeout = 10 })
temperatureTimer:connect_signal("timeout", updateCpuTemperatureWidget)
temperatureTimer:start();
updateCpuTemperatureWidget();

videoTemperatureTimer = timer({ timeout = 10 })
videoTemperatureTimer:connect_signal("timeout", updateGpuTemperatureWidget)
videoTemperatureTimer:start();
updateGpuTemperatureWidget();
