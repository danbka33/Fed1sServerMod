local PlayerColor = {};

function PlayerColor.apply_player_color(player_index)
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

function PlayerColor.on_player_created(event)
    PlayerColor.apply_player_color(event.player_index)
end

function PlayerColor.on_console_command(event)
    if event.name == defines.events.on_console_command and event.command == "color" then
        local player = game.players[event.player_index]
        apply_player_color(event.player_index)
        game.print("Осуждаем игрока " .. player.name, { 1, 1, 0, 1 })
    end
end

return PlayerColor