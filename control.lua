--[[ Copyright (c) 2022 danbka33
 * Part of FedisServerMod
 *
 * See LICENSE.md in the project directory for license information.
--]]

Permissions = require('scripts/permissions')
Stats = require('scripts/stats')
ServerMod = require('scripts/server_mod')
Interface = require('scripts/interface')
Logs = require('scripts/logs')
PlayerColor = require('scripts/player_color')
AdminMessage = require('scripts/admin_message')
Chests = require('scripts/chests')

script.on_init(function()
    Permissions.create_groups_and_apply_permissions()
    ServerMod.on_init()
    AdminMessage.on_init()
    Stats.on_init()
end)

local function on_player_create(event)
    ServerMod.on_player_created(event)
    Stats.on_player_created(event);
    PlayerColor.on_player_created(event)
end
script.on_event(defines.events.on_player_created, on_player_create)

local function on_console_command(event)
    PlayerColor.on_console_command(event)
end
script.on_event(defines.events.on_console_command, on_console_command)

local function on_player_joined_game(event)
    PlayerColor.apply_player_color(event.player_index)
end
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

local function on_console_chat(event)
    PlayerColor.apply_player_color(event.player_index)
    AdminMessage.on_console_chat(event)
end
script.on_event(defines.events.on_console_chat, on_console_chat)

local function on_entity_created(event)
    Chests.on_entity_created(event)
    Logs.on_entity_created(event)
end
script.on_event(defines.events.on_built_entity, on_entity_created, filters_on_built)
script.on_event(defines.events.on_robot_built_entity, on_entity_created, filters_on_built)
script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive }, on_entity_created)

local function on_entity_removed(event)
    Chests.on_entity_removed(event)
end
script.on_event(defines.events.on_pre_player_mined_item, on_entity_removed, filters_on_mined)
script.on_event(defines.events.on_robot_pre_mined, on_entity_removed, filters_on_mined)
script.on_event(defines.events.on_entity_died, on_entity_removed, filters_on_mined)
script.on_event(defines.events.script_raised_destroy, on_entity_removed)

local function on_gui_closed(event)
    Chests.on_gui_closed(event)
    ServerMod.on_gui_closed(event)
end
script.on_event(defines.events.on_gui_closed, on_gui_closed)

local function on_gui_opened(event)
    Chests.on_gui_opened(event)
end
script.on_event(defines.events.on_gui_opened, on_gui_opened)

local function on_player_flushed_fluid(event)
    Logs.on_player_flushed_fluid(event)
end
script.on_event(defines.events.on_player_flushed_fluid, on_player_flushed_fluid)

local function on_player_mined_entity(event)
    Logs.on_player_mined_entity(event)
end
script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)

local function on_pre_ghost_deconstructed(event)
    Logs.on_pre_ghost_deconstructed(event)
end
script.on_event(defines.events.on_pre_ghost_deconstructed, on_pre_ghost_deconstructed)

local function on_gui_click(event)
    Chests.on_gui_click(event)
    ServerMod.on_gui_click(event)
end
script.on_event(defines.events.on_gui_click, on_gui_click)

local function on_nth_tick_60(event)
    Chests.on_nth_tick_60(event)
    Stats.on_nth_tick_60(event)
    AdminMessage.on_nth_tick_60(event)
    ServerMod.on_nth_tick_60(event)
end
script.on_nth_tick(60, on_nth_tick_60)

local function on_runtime_mod_setting_changed(event)
    ServerMod.on_runtime_mod_setting_changed(event)
    AdminMessage.on_runtime_mod_setting_changed(event)
    Stats.on_runtime_mod_setting_changed(event)
end
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)

local function on_configuration_changed()
    ServerMod.on_configuration_changed()
    Stats.on_configuration_changed()
    AdminMessage.on_configuration_changed()
end
script.on_configuration_changed(on_configuration_changed)