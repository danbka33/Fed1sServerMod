-- Copyright (c) 2023 Ajick


local mod_gui = require("__core__/lualib/mod-gui")


---@class Event
---@field player_index uint
---@field element? LuaGuiElement
---@field text? string

local ConfirmWindow = require("scripts.players_inventory.confirm_window")

-- Main class setup --

local PlayersInventory = {
    main_window = require("scripts.players_inventory.main_window"),
    roles = {}
}

PlayersInventory.inventories = {
    main = defines.inventory.character_main,
    armor = defines.inventory.character_armor,
    guns = defines.inventory.character_guns,
    ammo = defines.inventory.character_ammo,
    trash = defines.inventory.character_trash
}

for _, role in pairs(ServerMod.roles) do
    table.insert(PlayersInventory.roles, role)
end

-- Top left toggle button --

-- Creates/recreates toggle button
---@param player LuaPlayer
function PlayersInventory.create_toggle_button(player)
    local button_flow = mod_gui.get_button_flow(player)

    if not button_flow or not button_flow.valid then
        return
    end

    local toggle_button = button_flow.players_inventory_toggle_window_button

    if toggle_button and toggle_button.valid then
        toggle_button.destroy()
    end

    button_flow.add{
        type = "sprite-button",
        name = "players_inventory_toggle_window_button",
        sprite = "utility/slot_icon_armor",
        hovered_sprite = "utility/slot_icon_armor_black",
        clicked_sprite = "utility/slot_icon_armor_black",
        tooltip = {"players-inventory.caption"}
    }
end


-- Common methods --

-- Returns warnings of player if there were any
---@param player_index uint
---@return string[]
function PlayersInventory.get_warnings(player_index)
    return global.players_inventory.warnings[player_index] or {}
end

-- Returns mute status of player
---@param player_index uint
---@return boolean
function PlayersInventory.is_muted(player_index)
    return global.players_inventory.mutes[player_index] or false
end

-- Returns ban message of player if he is banned
---@param player_index uint
---@return boolean
function PlayersInventory.is_banned(player_index)
    return ((global.players_inventory.bans[player_index] or "") ~= "")
end

-- Add warnig to a player
---@param player LuaPlayer
---@param reason string
function PlayersInventory.warn(player, reason)
    local warnings = global.players_inventory.warnings[player.index] or {}
    table.insert(warnings, reason)
    global.players_inventory.warnings[player.index] = warnings
    game.print({"players-inventory.message-warning", player.name, #warnings, reason})
end

-- Mute a player
---@param player LuaPlayer
function PlayersInventory.mute(player)
    global.players_inventory.mutes[player.index] = true
    game.mute_player(player)
end

-- Unmute a player
---@param player LuaPlayer
function PlayersInventory.unmute(player)
    global.players_inventory.mutes[player.index] = nil
    game.unmute_player(player)
end

-- Ban a player
---@param player LuaPlayer
---@param reason string
function PlayersInventory.ban(player, reason)
    global.players_inventory.bans[player.index] = reason
    game.ban_player(player, reason)
end

-- Unban a player
---@param player LuaPlayer
function PlayersInventory.unban(player)
    global.players_inventory.bans[player.index] = nil
    game.unban_player(player)
end


-- Utility methods --

-- Removes an item from list
---@param list table
---@param target_item any
function PlayersInventory.remove(list, target_item)
    for index, item in pairs(list) do
        if item == target_item then
            list[index] = nil
            return
        end
    end
end

-- Returns warnings list as LocalisedString
---@param warnings string[]
---@return LocalisedString
function PlayersInventory.get_warn_tooltip(warnings)
    if not warnings or #warnings == 0 then
        return ""
    end

    local tooltip = {"", {"players-inventory.tooltip-warnings"}}

    for index, warning in pairs(warnings) do
        table.insert(tooltip, "\n" .. index .. ". " .. warning)
    end

    return tooltip
end


-- Events --

-- Init module on first run
function PlayersInventory.on_init()
    if not global.players_inventory then
        global.players_inventory = {}
    end

    if not global.players_inventory.warnings then
        global.players_inventory.warnings = {}
    end

    if not global.players_inventory.mutes then
        global.players_inventory.mutes = {}
    end

    if not global.players_inventory.bans then
        global.players_inventory.bans = {}
    end

    if not global.wlist_state then
        global.wlist_state = false
    end

    if not global.wlist_bot_last_tick then
        global.wlist_bot_last_tick = 0
    end

    if not global.wlist_bot_connected then
        global.wlist_bot_connected = false
    end
end

-- Configuration changed
---@param data ConfigurationChangedData
function PlayersInventory.on_configuration_changed(data)
    if not data
    or not data.mod_changes
    or not data.mod_changes["Fed1sServerMod"]
    then
        return
    end

    PlayersInventory.on_init()
end

-- N-th tick rised
---@param data NthTickEventData
function PlayersInventory.on_nth_tick(data)
    -- 7200 ticks = 2 minutes
    if data.tick-global.wlist_bot_last_tick > 7200 then
        global.wlist_bot_connected = false
    end
end

-- Player created
---@param event Event
function PlayersInventory.on_player_created(event)
    if not event or not event.player_index then
        return
    end

    local player = game.get_player(event.player_index)

    if not player then
        return
    end

    PlayersInventory.create_toggle_button(player)
end

-- Player joined the game
---@param event Event
function PlayersInventory.on_player_joined_game(event)
    if not event or not event.player_index then
        return
    end

    local player_index = event.player_index
    local player = game.get_player(player_index)

    if not player then
        return
    end

    local button_flow = mod_gui.get_button_flow(player)

    if not button_flow or not button_flow.valid then
        PlayersInventory.create_toggle_button(player)
    end

    local window = PlayersInventory.main_window.get(player_index)

    if window and window.valid then
        PlayersInventory.main_window.close(player_index)
    end

    local confirm_window = ConfirmWindow.get(player_index)

    if confirm_window and confirm_window.valid then
        ConfirmWindow.close(player_index)
    end
end

-- Player demoted
---@param event Event
function PlayersInventory.on_player_demoted(event)
    if not event or not event.player_index then
        return
    end

    PlayersInventory.main_window.close(event.player_index)
end

-- Player clicks on GUI button
---@param event Event
function PlayersInventory.on_gui_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_toggle_window_button" then
        PlayersInventory.main_window.toggle(event.player_index)
    end
end


-- Global event handles registration --

local event_handlers = {
    on_init = PlayersInventory.on_init,
    on_configuration_changed = PlayersInventory.on_configuration_changed,
    on_nth_tick = {
        [600] = PlayersInventory.on_nth_tick
    },
    events = {
        [defines.events.on_player_created] = PlayersInventory.on_player_created,
        [defines.events.on_player_joined_game] = PlayersInventory.on_player_joined_game,
        [defines.events.on_player_demoted] = PlayersInventory.on_player_demoted,
        [defines.events.on_gui_click] = PlayersInventory.on_gui_click
    }
}
EventHandler.add_lib(event_handlers)


-- Debug --

-- commands.add_command("pi-debug", nil, function(command)
--     local player = game.get_player(command.player_index)

--     if not player then
--         return
--     end

--     local debug_ui = player.gui.center.debug_ui

--     if debug_ui and debug_ui.valid then
--         debug_ui.destroy()
--         return
--     end

--     debug_ui = player.gui.center.add{type="frame", name="debug_ui"}

--     local text = debug_ui.add{type="text-box", text=serpent.block(global)}
--     text.style.width = 500
--     text.style.height = 800
-- end)


-- Return --

return PlayersInventory
