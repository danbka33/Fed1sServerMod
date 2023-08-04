local Permissions = {}

Permissions.groups = {
    default = "Default",
    pick_role = "PickRole",
    manager = "Manager",
    admin = "Admin"
}

function Permissions.create_groups_and_apply_permissions()
    local default_group = game.permissions.get_group(Permissions.groups.default)

    default_group.set_allows_action(defines.input_action.set_player_color, false)
    default_group.set_allows_action(defines.input_action.start_research, false)
    default_group.set_allows_action(defines.input_action.cancel_research, false)
    default_group.set_allows_action(defines.input_action.set_research_finished_stops_game, false)
    default_group.set_allows_action(defines.input_action.toggle_map_editor, false)
    default_group.set_allows_action(defines.input_action.change_multiplayer_config, false)
    default_group.set_allows_action(defines.input_action.add_permission_group, false)
    default_group.set_allows_action(defines.input_action.edit_permission_group, false)
    default_group.set_allows_action(defines.input_action.delete_permission_group, false)
    default_group.set_allows_action(defines.input_action.import_permissions_string, false)
    default_group.set_allows_action(defines.input_action.admin_action, false)
    default_group.set_allows_action(defines.input_action.lua_shortcut, false)


    if not game.permissions.get_group(Permissions.groups.manager) then
        game.permissions.create_group(Permissions.groups.manager)
    end

    local manager_group = game.permissions.get_group(Permissions.groups.manager)

    manager_group.set_allows_action(defines.input_action.set_player_color, false)
    manager_group.set_allows_action(defines.input_action.set_research_finished_stops_game, false)
    manager_group.set_allows_action(defines.input_action.toggle_map_editor, false)
    manager_group.set_allows_action(defines.input_action.change_multiplayer_config, false)
    manager_group.set_allows_action(defines.input_action.add_permission_group, false)
    manager_group.set_allows_action(defines.input_action.edit_permission_group, false)
    manager_group.set_allows_action(defines.input_action.delete_permission_group, false)
    manager_group.set_allows_action(defines.input_action.import_permissions_string, false)
    manager_group.set_allows_action(defines.input_action.admin_action, false)
    manager_group.set_allows_action(defines.input_action.lua_shortcut, false)


    if not game.permissions.get_group(Permissions.groups.pick_role) then
        game.permissions.create_group(Permissions.groups.pick_role)
    end

    local pick_role_group = game.permissions.get_group(Permissions.groups.pick_role)

    for _, permission in pairs(defines.input_action) do
        pick_role_group.set_allows_action(permission, false)
    end

    pick_role_group.set_allows_action(defines.input_action.gui_checked_state_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_click, true)
    pick_role_group.set_allows_action(defines.input_action.gui_confirmed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_elem_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_hover, true)
    pick_role_group.set_allows_action(defines.input_action.gui_leave, true)
    pick_role_group.set_allows_action(defines.input_action.gui_location_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_selected_tab_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_selection_state_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_switch_state_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_text_changed, true)
    pick_role_group.set_allows_action(defines.input_action.gui_value_changed, true)
    pick_role_group.set_allows_action(defines.input_action.open_gui, true)
    pick_role_group.set_allows_action(defines.input_action.start_walking, true)
    pick_role_group.set_allows_action(defines.input_action.toggle_show_entity_info, true)
    pick_role_group.set_allows_action(defines.input_action.translate_string, true)
    pick_role_group.set_allows_action(defines.input_action.write_to_console, true)


    --game.permissions.get_group(Permissions.groups.admin).add_player("fed1s")
    --game.permissions.get_group(Permissions.groups.admin).add_player("danbka33")
    --game.permissions.get_group(Permissions.groups.admin).add_player("Ajick")


    if not game.permissions.get_group(Permissions.groups.admin) then
        game.permissions.create_group(Permissions.groups.admin)
    end


    if game.is_multiplayer() then
        return
    end

    local admin_group = game.permissions.get_group(Permissions.groups.admin)

    for _, player in pairs(game.players) do
        if player.admin then
            admin_group.add_player(player)
        else
            default_group.add_player(player)
        end
    end
end

function Permissions.set_group(player, group)
    if not player then
        return
    end

    if not game.permissions.get_group(group) then
        return
    end

    game.permissions.get_group(group).add_player(player)
end

function Permissions.in_group(player, group)
    if not player then
        return false
    end

    return player.permission_group.name == group
end


local event_handlers = {}
event_handlers.on_init = Permissions.create_groups_and_apply_permissions
EventHandler.add_lib(event_handlers)


return Permissions