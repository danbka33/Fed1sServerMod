local Logs = {};

function Logs.on_entity_created(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then
        return
    end

    local playerIndex = event.player_index

    if entity.name == "programmable-speaker" then
        if not playerIndex then
            entity.destroy()
            return
        end

        local player = game.players[playerIndex]

        if not (player.permission_group.name == "Admin" or player.permission_group.name == "Manager") then
            game.print(player.name .. " ПОСТАВИЛ ДИНАМИК " .. ". [gps=" .. entity.position.x .. "," .. entity.position.y .. "] ", { 1, 1, 0, 1 })
        end
    end

end

function Logs.on_player_flushed_fluid(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    game.print(player.name .. " УДАЛИЛ ЖИДКОСТЬ В ТРУБЕ " .. event.fluid .. " В КОЛИЧЕСТВЕ " .. math.floor(event.amount) .. ". [gps=" .. entity.position.x .. "," .. entity.position.y .. "] ", { 1, 1, 0, 1 })
end

function Logs.on_pre_ghost_deconstructed(event)
    local player = game.players[event.player_index]

    if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" or player.name == "fed1s" then
        return ;
    end

    local ghost = event.ghost

    local lastUser = ghost.last_user

    local ownername = "unknowm"

    if lastUser then
        ownername = lastUser.name
    end

    if ownername == "fed1s" then
        game.print(player.name .. ' УДАЛЯЕТ ЧЕРТЕЖ АДМИНИСТРАТОРА. ' .. ". [gps=" .. ghost.position.x - math.floor(ghost.position.x % 32) .. "," .. ghost.position.y - math.floor(ghost.position.y % 32) .. "] ", { 1, 1, 0, 1 })
    end
end

function Logs.on_player_mined_entity(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" or player.name == "fed1s" then
        return ;
    end

    local lastUser = entity.last_user
    local ownername = "unknowm"

    if lastUser then
        ownername = lastUser.name
    end

    if (entity.name == "storage-tank") then
        local fluidExist = false
        local fluidList = ''

        for asd, fluid in pairs(entity.get_fluid_contents()) do

            if fluid > 100 then
                fluidExist = true
                fluidList = fluidList .. asd .. ': ' .. math.floor(fluid) .. '  '
            end
        end

        if fluidExist then
            game.print(player.name .. ' УДАЛЯЕТ РЕЗЕРВУАР С ЖИДКОСТЬЮ. ' .. fluidList .. ". [gps=" .. entity.position.x .. "," .. entity.position.y .. "] ", { 1, 1, 0, 1 })
        end
    end

    if entity.type == "entity-ghost" and ownername == "fed1s" then
        game.print(player.name .. ' УДАЛЯЕТ ЧЕРТЕЖ АДМИНИСТРАТОРА.' .. ". [gps=" .. entity.position.x - math.floor(entity.position.x % 32) .. "," .. entity.position.y - math.floor(entity.position.y % 32) .. "] ", { 1, 1, 0, 1 })
    end
end

return Logs