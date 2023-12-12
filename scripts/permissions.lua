local Permissions = {}

Permissions.groups = {
    default = "Default",
    pick_role = "PickRole",
    manager = "Manager",
    admin = "Admin"
}

function Permissions.create_groups_and_apply_permissions()
    local default_group = game.permissions.get_group(Permissions.groups.default)

    if default_group then
        default_group.set_allows_action(defines.input_action.set_player_color, false)
        default_group.set_allows_action(defines.input_action.start_research, false)
        default_group.set_allows_action(defines.input_action.cancel_research, false)
    end


    local manager_group = game.permissions.get_group(Permissions.groups.manager)

    if not manager_group then
        manager_group = game.permissions.create_group(Permissions.groups.manager)
    end

    if manager_group then
        manager_group.set_allows_action(defines.input_action.set_player_color, false)
    end


    local pick_role_group = game.permissions.get_group(Permissions.groups.pick_role)

    if not pick_role_group then
        pick_role_group = game.permissions.create_group(Permissions.groups.pick_role)
    end

    if pick_role_group then
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
    end


    local admin_group = game.permissions.get_group(Permissions.groups.admin)

    if not admin_group then
        admin_group = game.permissions.create_group(Permissions.groups.admin)
    end

    if admin_group then
        for _, player in pairs(game.players) do
            if player.admin then
                admin_group.add_player(player)
            elseif default_group then
                default_group.add_player(player)
            end
        end
    end
end

function Permissions.set_group(player, group_name)
    if not player or not group_name then
        return
    end

    local group = game.permissions.get_group(group_name)

    if not group then
        return
    end

    group.add_player(player)
end

function Permissions.in_group(player, group_name)
    if not player or not group_name then
        return false
    end

    return player.permission_group.name == group_name
end


local event_handlers = {}
event_handlers.on_init = Permissions.create_groups_and_apply_permissions
EventHandler.add_lib(event_handlers)


commands.add_command("fix-permissions", nil, function(command)
    if not command or not command.player_index then
        return
    end

    if game.is_multiplayer() then
       return
    end

    local player = game.get_player(command.player_index)

    if not player then
        return
    end

    Permissions.set_group(player, Permissions.groups.admin)
end)


return Permissions