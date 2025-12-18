-- local pollnet = require("pollnet")
-- local json = require("json")
local buttplug = SMODS.load_file("buttplug.lua")()

-- get system Sleep function
local ffi = require("ffi")

ffi.cdef[[
void Sleep(int ms);
]]

local sleep
if ffi.os == "Windows" then
    function sleep(s)
        ffi.C.Sleep(s)
    end
else
    function sleep(s)
        ffi.C.poll(nil, 0, s)
    end
end

-- Ask for the device list after we connect
table.insert(buttplug.cb.ServerInfo, function()
    buttplug.request_device_list()
end)

-- Start scanning if the device list was empty
table.insert(buttplug.cb.DeviceList, function()
    if buttplug.count_devices() == 0 then
        buttplug.start_scanning()
    end
end)

-- Stop scanning after the first device is found
table.insert(buttplug.cb.DeviceAdded, function()
    buttplug.stop_scanning()
end)

-- Start scanning if we lose a device
table.insert(buttplug.cb.DeviceRemoved, function()
    buttplug.start_scanning()
end)

-- "Simulated" game loop
function _init()
    buttplug.connect("lust-balatro-mod", "ws://localhost:12345")
    Lust.buttplug = buttplug
end

_init()
