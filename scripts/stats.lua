local mod_gui = require("__core__/lualib/mod-gui")


local Stats = {
    name_overhead_in_search = "server_mod_in_search",
    name_overhead_in_search_details = "server_mod_in_search_details",
    show_stats = "server_mod_show_stats",
}


local function is_entity_type(what_type, entity_name)
    local prototype = game.entity_prototypes[entity_name]
    return prototype and prototype.type == what_type
end

local function is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end

local function is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
end

local function is_worm(entity_name)
    return is_entity_type("turret", entity_name)
end


function Stats.on_init()
    if not global.biter_count then
        global.biter_count = 0
    end

    if not global.old_biter_count then
        global.old_biter_count = 0
    end

    for _, player in pairs(game.players) do
        Stats.update_overhead_stat(player)
    end
end

function Stats.on_runtime_mod_setting_changed(event)
    if event.player_index and event.setting == Stats.show_stats then
        Stats.update_overhead_stat(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
end

function Stats.on_player_created(event)
    Stats.update_overhead_stat(game.get_player(event.player_index)) --[[@as LuaPlayer]]
end

function Stats.on_configuration_changed()
    local button_flow

    for _, player in pairs(game.players) do
        button_flow = mod_gui.get_button_flow(player)

        if button_flow and button_flow.fed1s_flow_text then
            button_flow.fed1s_flow_text.destroy()
        end

        Stats.update_overhead_stat(player)
    end
end

function Stats.on_nth_tick_60(event)
    for _, player in pairs(game.connected_players) do
        Stats.update_overhead_stat(player)
    end
end

function Stats.update_overhead_stat(player)
    local button_flow = mod_gui.get_button_flow(player)

    if not button_flow then
        return
    end

    local search_plate = button_flow[Stats.name_overhead_in_search]

    if not player.mod_settings[Stats.show_stats].value then
        if search_plate then
            search_plate.destroy()
        end

        return
    end

    global.yellow_chest = global.yellow_chest or {}
    global.tick_yellow_index = global.tick_yellow_index or nil

    local current_in_search = nil
    if global.tick_yellow_index and global.yellowChest[global.tick_yellow_index] and global.yellowChest[global.tick_yellow_index].requested then
        local yellow_chest = global.yellowChest[global.tick_yellow_index];
        if yellow_chest and yellow_chest.entity and yellow_chest.entity.valid and yellow_chest.started then
            current_in_search = ""
            for itemName, count in pairs(yellow_chest.requested) do
                current_in_search = current_in_search .. "[item=" .. itemName .. "] x " .. count .. " "
            end

        end
    end

    if not current_in_search then
        if search_plate then
            search_plate.destroy()
        end
    else
        if not search_plate then
            button_flow.add {
                type = "frame",
                direction = "horizontal",
                name = Stats.name_overhead_in_search,
                caption = { "Fed1sServerMod.in_search" }
            }
            search_plate = button_flow[Stats.name_overhead_in_search]
        end

        local search_plateDetails = search_plate[Stats.name_overhead_in_search_details]

        if not search_plateDetails then
            search_plate.add {
                type = "label",
                name = Stats.name_overhead_in_search_details,
                caption = { "Fed1sServerMod.in_search_details", current_in_search }
            }
        else
            search_plateDetails.caption = current_in_search
        end
    end
end


local event_handlers = {}
event_handlers.on_init = Stats.on_init
event_handlers.on_nth_tick = {[60] = Stats.on_nth_tick_60}
event_handlers.on_configuration_changed = Stats.on_configuration_changed
event_handlers.events = {
    [defines.events.on_runtime_mod_setting_changed] = Stats.on_runtime_mod_setting_changed,
    [defines.events.on_player_created] = Stats.on_player_created
}
EventHandler.add_lib(event_handlers)

return Stats
