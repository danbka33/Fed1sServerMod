local PlayerColor = {};

function PlayerColor.apply_player_color_handler(event)
    PlayerColor.apply_player_color(event.player_index)
end

function PlayerColor.apply_player_color(player_index)
    if player_index then
        local player = game.get_player(player_index)
        local playerData = ServerMod.get_make_playerdata(player_index)

        if playerData then
            if playerData.role then
                local color = { 1, 1, 1, 1 }
                local chatColor = { 1, 1, 1, 1 }

                if playerData.role == "warrior" then
                    color = { 1, 0.5, 0, 1 }
                elseif playerData.role == "builder" then
                    color = { 0, 0.5, 0.5, 1 }
                elseif playerData.role == "defender" then
                    color = { 0, 0.5, 1, 1 }
                elseif playerData.role == "service" then
                    color = { 0, 0.5, 0.5, 1 }
                end

                if player.permission_group.name == "Admin" then
                    color = { 1, 1, 0, 1 }
                    chatColor = { 1, 1, 0, 1 }
                elseif player.permission_group.name == "Manager" then
                    color = { 0, 1, 0, 1 }
                    chatColor = { 0, 1, 0, 1 }
                end

                player.chat_color = chatColor
                player.color = color
            end
        else
            player.chat_color = { 1, 1, 1, 1 }
            player.color = { 1, 1, 1, 1 }
        end
    end
end

function PlayerColor.on_player_created(event)
    PlayerColor.apply_player_color(event.player_index)
end

function PlayerColor.on_console_command(event)
    if event.name == defines.events.on_console_command and event.command == "color" then
        local player = game.players[event.player_index]
        PlayerColor.apply_player_color(event.player_index)
        game.print("Осуждаем игрока " .. player.name, { 1, 1, 0, 1 })
    end
end

local event_handlers = {}
event_handlers.events = {
    [defines.events.on_player_created] = PlayerColor.on_player_created,
    [defines.events.on_console_command] = PlayerColor.on_console_command,
    [defines.events.on_player_joined_game] = PlayerColor.apply_player_color_handler,
    [defines.events.on_console_chat] = PlayerColor.apply_player_color_handler
}
EventHandler.add_lib(event_handlers)

return PlayerColor