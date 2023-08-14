local mod_gui = require("__core__/lualib/mod-gui")


local Stats = {
    name_overhead_stats_table = "fed1s_stats_table",

    name_overhead_stats_server_time = "fed1s_stats_server_time",
    name_overhead_stats_evolution = "fed1s_stats_evolution",
    name_overhead_stats_online_count = "fed1s_stats_online_count",
    name_overhead_stats_deaths_count = "fed1s_stats_deaths_count",

    name_overhead_stats_biters_count = "fed1s_stats_biters_count",
    name_overhead_stats_nests_count = "fed1s_stats_nests_count",
    name_overhead_stats_worms_count = "fed1s_stats_worms_count",

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

    local stats_table = button_flow[Stats.name_overhead_stats_table]
    local search_plate = button_flow[Stats.name_overhead_in_search]

    if not player.mod_settings[Stats.show_stats].value then
        if stats_table then
            stats_table.destroy()
        end

        if search_plate then
            search_plate.destroy()
        end

        return
    end


    local server_time = math.floor(game.ticks_played / 60)
    local hours = 0
    local minutes = 0
    local seconds = 0

    hours = math.floor(server_time / 3600)
    server_time = server_time % 3600
    minutes = math.floor(server_time / 60)
    seconds = server_time % 60
    server_time = string.format("%d:%02d:%02d", hours, minutes, seconds)

    local evolution = game.forces.enemy.evolution_factor * 100
    -- this nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local whole_number = math.floor(evolution)
    local evolution = string.format("%d.%04d%%", whole_number, math.floor((evolution - whole_number) * 10000))

    local online_count = #game.connected_players
    local deaths_count = player.force.kill_count_statistics.output_counts["character"] or 0

    local biters_count = 0
    local nests_count = 0
    local worms_count = 0

    for entity_name, kill_count in pairs(player.force.kill_count_statistics.input_counts) do
        if is_biter(entity_name) then
            biters_count = biters_count + kill_count
        elseif is_spawner(entity_name) then
            nests_count = nests_count + kill_count
        elseif is_worm(entity_name) then
            worms_count = worms_count + kill_count
        end
    end

    if not stats_table then
        stats_table = button_flow.add {
            type = "table",
            name = Stats.name_overhead_stats_table,
            column_count = 2
        }
        stats_table.style.right_margin = 20
        stats_table.style.left_margin = 20
    end

    local stats_server_time = stats_table[Stats.name_overhead_stats_server_time]
    local stats_biters_count = stats_table[Stats.name_overhead_stats_biters_count]
    local stats_evolution = stats_table[Stats.name_overhead_stats_evolution]
    local stats_worms_count = stats_table[Stats.name_overhead_stats_worms_count]
    local stats_online_count = stats_table[Stats.name_overhead_stats_online_count]
    local stats_nests_count = stats_table[Stats.name_overhead_stats_nests_count]
    local stats_deaths_count = stats_table[Stats.name_overhead_stats_deaths_count]

    if not stats_server_time then
        stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_server_time,
            caption = {"Fed1sServerMod.server_time", server_time}
        }
    else
        stats_server_time.caption = {"Fed1sServerMod.server_time", server_time}
    end

    if not stats_biters_count then
        stats_biters_count = stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_biters_count,
            caption = {"Fed1sServerMod.biters_count", biters_count}
        }
        stats_biters_count.style.left_margin = 20
    else
        stats_biters_count.caption = {"Fed1sServerMod.biters_count", biters_count}
    end

    if not stats_evolution then
        stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_evolution,
            caption = {"Fed1sServerMod.evolution", evolution}
        }
    else
        stats_evolution.caption = {"Fed1sServerMod.evolution", evolution}
    end

    if not stats_worms_count then
        stats_worms_count = stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_worms_count,
            caption = {"Fed1sServerMod.worms_count", worms_count}
        }
        stats_worms_count.style.left_margin = 20
    else
        stats_worms_count.caption = {"Fed1sServerMod.worms_count", worms_count}
    end

    if not stats_online_count then
        stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_online_count,
            caption = {"Fed1sServerMod.online_count", online_count}
        }
    else
        stats_online_count.caption = {"Fed1sServerMod.online_count", online_count}
    end

    if not stats_nests_count then
        stats_nests_count = stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_nests_count,
            caption = {"Fed1sServerMod.nests_count", nests_count}
        }
        stats_nests_count.style.left_margin = 20
    else
        stats_nests_count.caption = {"Fed1sServerMod.nests_count", nests_count}
    end

    if not stats_deaths_count then
        stats_table.add {type="empty-widget"}
        stats_deaths_count = stats_table.add {
            type = "label",
            name = Stats.name_overhead_stats_deaths_count,
            caption = {"Fed1sServerMod.deaths_count", deaths_count}
        }
        stats_deaths_count.style.left_margin = 20
    else
        stats_deaths_count.caption = {"Fed1sServerMod.deaths_count", deaths_count}
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
