Lust = SMODS and SMODS.current_mod or {}

Lust._DEBUG_MODE = false

require("lust/loading")

G.C.BUTTPLUG = HEX("ff009d")

local update_ref = Game.update
function Game:update(dt, ...)
    Lust.dt = (Lust.dt or 0) - dt
    if Lust.dt <= -0.35 and not Lust.reset then
        Lust.buttplug.send_vibrate_cmd(Lust.config.device_index, { 0 })
        Lust.reset = true
    end
    return update_ref(self, dt, ...)
end

function Lust.vibrate(intensity)
    local plug_amt = G.SETTINGS.buttplug_intensity/100
    if plug_amt < 0.05 then shake_amt = 0 end
    if plug_amt > 0 then
        Lust.buttplug.send_vibrate_cmd(Lust.config.device_index, {intensity * plug_amt})
    end
    Lust.last_speed = G.CURR_BP_VIBRATION * plug_amt
    Lust.reset = false
end

if SMODS then
    SMODS.Atlas {
        key = "modicon",
        path = "icon.png",
        px = 34,
        py = 34,
    }:register()
    local config_tab = function()
        G.SETTINGS.buttplug_intensity = G.SETTINGS.buttplug_intensity or 100
        _nodes = {
            {
                n = G.UIT.R,
                config = { align = "cm" },
                nodes = {
                },
            },
        }
        left_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
        right_settings = { n = G.UIT.C, config = { align = "tl", padding = 0.05 }, nodes = {} }
        config = { n = G.UIT.R, config = { align = "tm", padding = 0 }, nodes = { left_settings, right_settings } }
        _nodes[#_nodes + 1] = config
        _nodes[#_nodes + 1] = create_slider({label = localize('b_set_vibration_intensity'),w = 4, h = 0.4, ref_table = G.SETTINGS, ref_value = 'buttplug_intensity', min = 0, max = 100, colour = G.C.BUTTPLUG})
        _nodes[#_nodes + 1] = create_slider({label = localize('b_device_index'),w = 4, h = 0.4, ref_table = Lust.config, ref_value = 'device_index', min = 0, max = 10, colour = G.C.BUTTPLUG})

        return {
            n = G.UIT.ROOT,
            config = {
                emboss = 0.05,
                minh = 6,
                r = 0.1,
                minw = 10,
                align = "cm",
                padding = 0.2,
                colour = G.C.BLACK
            },
            nodes = _nodes,
        }
    end
    Lust.config_tab = config_tab
else
    function _table_merge(target, source, ...)
        assert(type(target) == "table", "Target is not a table")
        local tables_to_merge = { source, ... }
        if #tables_to_merge == 0 then
            return target
        end

        for k, t in ipairs(tables_to_merge) do
            assert(type(t) == "table", string.format("Expected a table as parameter %d", k))
        end

        for i = 1, #tables_to_merge do
            local from = tables_to_merge[i]
            for k, v in pairs(from) do
                if type(v) == "table" then
                    target[k] = target[k] or {}
                    target[k] = _table_merge(target[k], v)
                else
                    target[k] = v
                end
            end
        end

        return target
    end

    local init_localization_ref = init_localization
    function init_localization(...)
        if not G.localization.__lust_injected then
            local en_loc = require("lust/localization/en-us")
            _table_merge(G.localization, en_loc)
            if G.SETTINGS.language ~= "en-us" then
                local success, current_loc = pcall(function()
                    return require("lust/localization/" .. G.SETTINGS.language)
                end)
                if success and current_loc then
                    _table_merge(G.localization, current_loc)
                end
            end
            G.localization.__lust_injected = true
        end
        return init_localization_ref(...)
    end

    if love.filesystem.exists("config/Lust.jkr") then
    local str = ""
    for line in love.filesystem.lines("config/Lust.jkr") do
        str = str..line
    end
        return loadstring(str)()
    else    
        return {
            device_index = 0
        }
    end
end
