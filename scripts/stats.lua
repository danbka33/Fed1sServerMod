local mod_gui = require("__core__/lualib/mod-gui")
local Stats = {
    name_overhead_stats_factor = "fed1s_factor",
    name_overhead_stats_flow = "fed1s_flow_text",
    name_overhead_stats_online_count = "fed1s_online_count",
    name_overhead_stats_count = "fed1s_count",
    name_overhead_in_search = "server_mod_in_search",
    name_overhead_in_search_details = "server_mod_in_search_details",
    show_stats = "server_mod_show_stats",
}

local entity_types = {
    ["unit"] = {
        ["small-biter"] = true,
        ["medium-biter"] = true,
        ["big-biter"] = true,
        ["behemoth-biter"] = true,
        ["small-spitter"] = true,
        ["medium-spitter"] = true,
        ["big-spitter"] = true,
        ["behemoth-spitter"] = true,
    },
    ["unit-spawner"] = {
        ["biter-spawner"] = true,
        ["spitter-spawner"] = true,
    },
}

local function is_entity_type(what_type, entity_name)
    if not entity_types[what_type] then
        entity_types[what_type] = {}
    end
    local type_cache = entity_types[what_type]

    if type_cache[entity_name] ~= nil then
        return type_cache[entity_name]
    end

    local prototype = game.entity_prototypes[entity_name]
    if prototype and prototype.type == what_type then
        type_cache[entity_name] = true
    else
        type_cache[entity_name] = false
    end

    return type_cache[entity_name]
end

local function is_biter(entity_name)
    return is_entity_type("unit", entity_name)
end

local function is_spawner(entity_name)
    return is_entity_type("unit-spawner", entity_name)
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
    for _, player in pairs(game.players) do
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

    local statFlow = button_flow[Stats.name_overhead_stats_flow]
    local searchPlate = button_flow[Stats.name_overhead_in_search]

    if not player.mod_settings[Stats.show_stats].value then
        if searchPlate then
            searchPlate.destroy()
        end
        if statFlow then
            statFlow.destroy()
        end
        return
    end

    local biter_count = 0
    local biter_count_hi = 0
    local biter_count_speed = 0.0
    local spawner_count = 0
    local other_count = 0
    for entity_name, kill_count in pairs(player.force.kill_count_statistics.input_counts) do
        if is_biter(entity_name) then
            biter_count_hi = biter_count_hi + kill_count
        elseif is_spawner(entity_name) then
            spawner_count = spawner_count + kill_count
        else
            other_count = other_count + kill_count
        end
    end

    biter_count = math.floor(biter_count_hi + spawner_count)
    local percent_evo_factor = game.forces.enemy.evolution_factor * 100
    -- this nonsense is because string.format(%.4f) is not safe in MP across platforms, but integer math is
    local whole_number = math.floor(percent_evo_factor)

    local eveFactor = string.format("%d.%04d%%", whole_number, math.floor((percent_evo_factor - whole_number) * 10000))

    global.yellowChest = global.yellowChest or {}

    global.tick_yellow_index = global.tick_yellow_index or nil

    local currentInSearch = nil
    if global.tick_yellow_index and global.yellowChest[global.tick_yellow_index] and global.yellowChest[global.tick_yellow_index].requested then
        local yellowChest = global.yellowChest[global.tick_yellow_index];

        if yellowChest and yellowChest.entity and yellowChest.entity.valid and yellowChest.started then
            currentInSearch = ""
            for itemName, count in pairs(yellowChest.requested) do
                currentInSearch = currentInSearch .. "[item=" .. itemName .. "] x " .. count .. " "
            end

        end
    end

    if not currentInSearch then
        if searchPlate then
            searchPlate.destroy()
        end
    else
        if not searchPlate then
            button_flow.add {
                type = "frame",
                direction = "horizontal",
                name = Stats.name_overhead_in_search,
                caption = { "Fed1sServerMod.in_search" }
            }
            searchPlate = button_flow[Stats.name_overhead_in_search]
        end

        local searchPlateDetails = searchPlate[Stats.name_overhead_in_search_details]

        if not searchPlateDetails then
            searchPlate.add {
                type = "label",
                name = Stats.name_overhead_in_search_details,
                caption = { "Fed1sServerMod.in_search_details", currentInSearch }
            }
        else
            searchPlateDetails.caption = currentInSearch
        end
    end

    if not statFlow then
        button_flow.add {
            type = "flow",
            direction = "vertical",
            name = Stats.name_overhead_stats_flow
        }
        statFlow = button_flow[Stats.name_overhead_stats_flow]
        statFlow.style.right_margin = 20
        statFlow.style.left_margin = 20
    end

    local statFactor = statFlow[Stats.name_overhead_stats_count]
    local statCount = statFlow[Stats.name_overhead_stats_factor]
    local onlineCount = statFlow[Stats.name_overhead_stats_online_count]

    if not statCount then
        statFlow.add {
            type = "label",
            name = Stats.name_overhead_stats_count,
            caption = { "Fed1sServerMod.kill_count", eveFactor }
        }
        statCount = statFlow[Stats.name_overhead_stats_factor]
    else
        statCount.caption = { "Fed1sServerMod.kill_count", biter_count }
    end

    if not statFactor then
        statFlow.add {
            type = "label",
            name = Stats.name_overhead_stats_factor,
            caption = { "Fed1sServerMod.evo_factor", biter_count }
        }
        statFactor = statFlow[Stats.name_overhead_stats_count]
    else
        statFactor.caption = { "Fed1sServerMod.evo_factor", eveFactor }
    end

    local playerCount = 0;

    for _, player in pairs(game.connected_players) do
        playerCount = playerCount + 1;
    end

    if not onlineCount then
        statFlow.add {
            type = "label",
            name = Stats.name_overhead_stats_online_count,
            caption = { "Fed1sServerMod.top_player_connected", playerCount }
        }
        onlineCount = statFlow[Stats.name_overhead_stats_count]
    else
        onlineCount.caption = { "Fed1sServerMod.top_player_connected", playerCount }
    end

end

return Stats
