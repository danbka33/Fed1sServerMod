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

    global.players_inventory = {}

    PlayersInventory.on_init()

    local globals = global.players_inventory

    if globals.favorites then
        for player_index, favorites in pairs(globals.favorites) do
            if favorites then
                local filters = PlayersInventory.main_window.get_window_filters(player_index)
                filters.favorites = favorites
            end
        end

        globals.favorites = nil
    end

    if global.warned then
        globals.warnings = global.warned
        global.warned = nil
    end

    if global.muted then
        globals.mutes = global.muted
        global.muted = nil
    end

    if global.banned then
        globals.bans = global.banned
        global.banned = nil
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

commands.add_command("wlist-state", nil, function(command)
    if not command then
        return
    end

    local player

    if command.player_index then
		player = game.get_player(command.player_index)
	else
		player = rcon
	end

    if not player then
        return
    end

    if global.wlist_state then
        player.print("1")
    else
        player.print("0")
    end

    global.wlist_bot_connected = true
    global.wlist_bot_last_tick = command.tick
end)

--[[ commands.add_command("bot-state", nil, function(command)
    if not command or not command.parameter then
        return
    end

    local parameter = command.parameter

    if not parameter then
        return
    end

    if parameter == "on" then
        PlayersInventory.wlist_bot_enabled = true
    elseif parameter == "off" then
        PlayersInventory.wlist_bot_enabled = false
    else
        return
    end

    PlayersInventory.wlist_bot_connected = true
    PlayersInventory.wlist_bot_last_tick = game.tick
end) ]]

--[[ commands.add_command("voice-in", nil, function(command)
    if not command or not command.parameter then
        return
    end

    local parameter = command.parameter

    if not parameter then
        return
    end

    local channel, player_name = string.match(parameter, "(.+)%s(.+)")

    if not channel or not player_name then
        return
    end

    local player = game.get_player(player_name)

    if not player then
        return
    end

    --
end) ]]