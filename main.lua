Lust = SMODS and SMODS.current_mod or {}

require("lust/loading")

G.C.BUTTPLUG = HEX("ff009d")

local update_ref = Game.update
function Game:update(dt, ...)
    Lust.dt = (Lust.dt or 0) - dt
    return update_ref(self, dt, ...)
end

function Lust.vibrate(intensity)
    Lust.buttplug.send_vibrate_cmd(0, {intensity})
end

if SMODS then
    SMODS.Atlas {
        key = "modicon",
        path = "icon.png",
        px = 34,
        py = 34,
    }:register()

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
end