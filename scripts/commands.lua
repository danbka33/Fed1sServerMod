-- Migration and fixup commands --


local mod_gui = require("__core__/lualib/mod-gui")


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


commands.add_command("reinit", nil, function(command)
    if not command or not command.player_index then
        return
    end

    local player = game.get_player(command.player_index)

    if not player then
        return
    end

    if not player.admin then
        return
    end

    PlayersInventory.on_init()

    local globals = global.players_inventory

    if globals.filters then
        globals.window_filters = globals.filters
        globals.filters = nil
    end

    if globals.favorites then
        for player_index, favorites in pairs(globals.favorites) do
            local filters = PlayersInventory.main_window.get_window_filters(player_index)
            filters.favorites = favorites
        end

        globals.favorites = nil
    end

    if globals.warned then
        global.warnings = globals.warned
        globals.warned = nil
    end

    if globals.muted then
        global.mutes = globals.muted
        globals.muted = nil
    end

    if globals.banned then
        global.bans = globals.banned
        globals.banned = nil
    end

    for player_index, player in pairs(game.players) do
        local button_flow = mod_gui.get_button_flow(player)

        if not button_flow or not button_flow.valid then
            goto continue
        end

        if button_flow.fed1s_stats_table then
            if button_flow.fed1s_stats_table.valid then
                button_flow.fed1s_stats_table.destroy()
            else
                button_flow.fed1s_stats_table = nil
            end
        end

        if button_flow.players_inventory_toggle_window then
            if button_flow.players_inventory_toggle_window.valid then
                button_flow.players_inventory_toggle_window.destroy()
            else
                button_flow.players_inventory_toggle_window = nil
            end
        end

        PlayersInventory.create_toggle_button(player)

        local top = player.gui.top

        if top and top.valid then
            if top.children[1] ~= button_flow
            and top.children[1].name ~= "GameStats_ui__container"
            then
                top.swap_children(1, button_flow.parent.get_index_in_parent())
            elseif top.children[2] ~= button_flow
            then
                top.swap_children(2, button_flow.parent.get_index_in_parent())
            end
        end

        ::continue::
    end
end)