local PlayerColor = {};

function PlayerColor.apply_player_color(player)
    if not player then
        return
    end

    local playerData = ServerMod.get_make_playerdata(player.index)

    if player.admin then
        player.color = { 1, 1, 0, 1 }
        player.chat_color = { 1, 1, 0, 1 }
    elseif playerData.manager then
        player.color = { 0, 1, 0, 1 }
        player.chat_color = { 0, 1, 0, 1 }
    elseif playerData.applied then
        if playerData.role == ServerMod.roles.warrior then
            player.color = { 1, 0.5, 0, 1 }
        elseif playerData.role == ServerMod.roles.builder then
            player.color = { 0, 0.5, 0.5, 1 }
        elseif playerData.role == ServerMod.roles.defender then
            player.color = { 0, 0.5, 1, 1 }
        end

        player.chat_color = { 1, 1, 1, 1 }
    else
        player.color = { 1, 1, 1, 1 }
        player.chat_color = { 1, 1, 1, 1 }
    end
end

function PlayerColor.on_player_created(event)
    PlayerColor.apply_player_color(game.players[event.player_index])
end

function PlayerColor.on_console_command(event)
    if event.name == defines.events.on_console_command and event.command == "color" then
        local player = game.players[event.player_index]
        PlayerColor.apply_player_color(player)
        game.print("Осуждаем игрока " .. player.name, { 1, 1, 0, 1 })
    end
end

local event_handlers = {}
event_handlers.events = {
    [defines.events.on_player_created] = PlayerColor.on_player_created,
    [defines.events.on_console_command] = PlayerColor.on_console_command,
    [defines.events.on_player_joined_game] = PlayerColor.apply_player_color_handler
}
EventHandler.add_lib(event_handlers)

return PlayerColor