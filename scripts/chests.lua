local Chests = {}
local ChestEntities = {
    ["necromancy-chest"] = 0,
    ["yellow-chest"] = 1,
    ["blue-chest2"] = 2
}

function Chests.on_init()
    global.necromancyChest = global.necromancyChest or {}
    global.blueChest = global.blueChest or {}
    global.yellowChest = global.yellowChest or {}
end

function Chests.on_character_corpse_expired(event)
    local corpse = event.corpse

    local CorpseInventory = corpse.get_inventory(defines.inventory.character_corpse)

    if CorpseInventory then
        local corpseInventoryContents = CorpseInventory.get_contents()

        if corpseInventoryContents then
            for itemName, itemCount in pairs(corpseInventoryContents) do
                game.print(itemName .. " " .. itemCount)
            end
        end
    end
end

function Chests.get_make_necromancy_chest(necromancy_chest_index)
    global.necromancyChest = global.necromancyChest or {}
    global.necromancyChest[necromancy_chest_index] = global.necromancyChest[necromancy_chest_index] or {}
    return global.necromancyChest[necromancy_chest_index]
end

function Chests.get_make_blue_chest(blue_chest_index)
    global.blueChest = global.blueChest or {}
    global.blueChest[blue_chest_index] = global.blueChest[blue_chest_index] or {}
    return global.blueChest[blue_chest_index]
end

function Chests.get_make_yellow_chest(yellow_chest_index)
    global.yellowChest = global.yellowChest or {}
    global.yellowChest[yellow_chest_index] = global.yellowChest[yellow_chest_index] or {}
    return global.yellowChest[yellow_chest_index]
end

function Chests.on_necromancy_chest_created(entity, player)
    local necromancyChestData = Chests.get_make_necromancy_chest(entity.unit_number)

    if necromancyChestData and necromancyChestData.entity and necromancyChestData.entity.valid then
        return
    end

    global.necromancyChest[entity.unit_number] = {
        entity = entity,
        started = false,
        valid = true,
        startPlayer = player
    };
end

function Chests.on_yellow_chest_created(entity, player)
    local yellowChestData = Chests.get_make_yellow_chest(entity.unit_number)

    if yellowChestData and yellowChestData.entity and yellowChestData.entity.valid then
        return
    end

    global.yellowChest[entity.unit_number] = {
        entity = entity,
        started = false,
        valid = true,
        startPlayer = player
    };
end

function Chests.on_blue_chest_created(entity, player)
    local blueChestData = Chests.get_make_blue_chest(entity.unit_number)

    if blueChestData and blueChestData.entity and blueChestData.entity.valid then
        return
    end

    global.blueChest[entity.unit_number] = {
        entity = entity,
        valid = true,
        startPlayer = player
    };
end

function Chests.on_entity_created(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then
        return
    end

    local playerIndex = event.player_index

    if ChestEntities[entity.name] then
        if not playerIndex then
            entity.destroy()
            return
        end
        local player = game.players[playerIndex]

        if player then
            if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" then
                entity.destructible = false

                game.print(player.name .. " поставил [entity=" .. entity.name .. "] [gps=" .. entity.position.x .. "," .. entity.position.y .. "] " , { 0, 1, 1, 1 })

                if entity.name == "necromancy-chest" then
                    Chests.on_necromancy_chest_created(entity, player)
                elseif entity.name == "yellow-chest" then
                    Chests.on_yellow_chest_created(entity, player)
                elseif entity.name == "blue-chest" then
                    Chests.on_blue_chest_created(entity, player)
                end

            else
                if (player.connected) then
                    player.print("Вы не можете ставить этот сундук", { 0, 1, 1, 1 });
                end
                entity.destroy()
            end
        else
            entity.destroy();
        end
    end
end

function Chests.on_entity_removed(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end

    if ChestEntities[entity.name] then
        game.print("Удален [entity=" .. entity.name .. "] [gps=" .. entity.position.x .. "," .. entity.position.y .. "] " , { 0, 1, 1, 1 })

        if entity.name == "yellow-chest" then
            global.yellowChest[entity.unit_number] = nil
        elseif entity.name == "blue-chest" then
            global.blueChest[entity.unit_number] = nil
        elseif entity.name == "necromancy-chest" then
            global.necromancyChest[entity.unit_number] = nil
        end

    end
end

function Chests.on_gui_closed(event)
    local player = game.players[event.player_index]

    local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]
    if (yellowChestGui) then
        yellowChestGui.destroy();
    end
end

function Chests.check_player_inventories_for_request(player, requested, chestInventory)
    if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" then
        return true
    end

    local mainInventory = player.get_inventory(defines.inventory.character_main);
    local trashInventory = player.get_inventory(defines.inventory.character_trash);

    if not Chests.check_player_inventory_for_request(player, mainInventory, requested, chestInventory) then
        return false
    end

    if not Chests.check_player_inventory_for_request(player, trashInventory, requested, chestInventory) then
        return false
    end

    return true
end

function Chests.check_player_inventory_for_request(player, playerInventory, requested, chestInventory)

    if not playerInventory then
        return true
    end

    for itemName, count in pairs(playerInventory.get_contents()) do
        if itemName and count then
            local insertable = chestInventory.get_insertable_count(itemName)

            if requested[itemName] and requested[itemName] > 0 then
                local toInsert = requested[itemName]

                if insertable < toInsert then
                    toInsert = insertable
                end

                if insertable <= 0 then
                    return false
                end

                --game.print("Found " .. itemName .. " in amount " .. count .. " in player" .. player.name)
                if count >= toInsert then
                    --game.print("Remove " .. itemName .. " in amount " .. toInsert .. " from player" .. player.name)
                    --game.print(count .. ">=" .. toInsert)
                    if (player.connected) then
                        player.print("У вас изъяли [item=" .. itemName .. "] x " .. toInsert .. " на нужды партии.", { 0, 1, 1, 1 })
                    end
                    playerInventory.remove({ name = itemName, count = toInsert })
                    chestInventory.insert({ name = itemName, count = toInsert })
                    requested[itemName] = requested[itemName] - toInsert
                elseif count < toInsert then
                    --game.print("Remove " .. itemName .. " in amount " .. count .. " from player" .. player.name)
                    --game.print(count .. "<" .. toInsert)
                    if (player.connected) then
                        player.print("У вас изъяли [item=" .. itemName .. "] x " .. count .. " на нужды партии.", { 0, 1, 1, 1 })
                    end
                    playerInventory.remove({ name = itemName, count = count })
                    chestInventory.insert({ name = itemName, count = count })
                    requested[itemName] = requested[itemName] - count
                end
            end

        end
    end

    return true
end

function Chests.on_gui_click(event)
    if event.element.tags and event.element.tags.id and event.element.tags.chestType then
        local id = event.element.tags.id
        local chestType = event.element.tags.chestType

        if chestType == "yellow" then

            local yellowChestData = Chests.get_make_yellow_chest(id)

            if yellowChestData then
                if event.element.name == "fed1s_gui_yellow_chest_start_button" then
                    yellowChestData.started = true
                elseif event.element.name == "fed1s_gui_yellow_chest_stop_button" then
                    yellowChestData.started = false
                end

                for _, player in pairs(game.players) do
                    local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]

                    if yellowChestGui then
                        yellowChestGui.destroy()
                        return
                    end
                end
            end
        end
    end
end

function Chests.on_nth_tick_60(event)
    if not global.yellowChest then
        global.yellowChest = {}
    end

    if not global.blueChest then
        global.blueChest = {}
    end

    local tick = event.tick

    if not global.tick_blue_index then
        global.tick_blue_index = nil
    end
    if not global.tick_yellow_index then
        global.tick_yellow_index = nil
    end
    if not global.tick_blue_player_index then
        global.tick_blue_player_index = nil
    end
    if not global.tick_yellow_player_index then
        global.tick_yellow_player_index = nil
    end
    if not global.tick_yellow_player_connected then
        global.tick_yellow_player_connected = false
    end
    if not global.tick_blue_state then
        global.tick_blue_state = 0
    end
    if not global.tick_yellow_state then
        global.tick_yellow_state = 0
    end

    -- Pick yellow chest
    if global.tick_yellow_state == 0 then

        --game.print("Picking yellow chest")

        if global.tick_yellow_index and not global.yellowChest[global.tick_yellow_index] then
            global.yellowChest[global.tick_yellow_index] = nil
        end

        local yellowIndex, yellowChestData = next(global.yellowChest, global.tick_yellow_index)
        if yellowIndex then
            --game.print("Picked yellow chest " .. yellowIndex)
            global.tick_yellow_index = yellowIndex
            yellowChestData.requested = {}
            yellowChestData.players = {}

            if yellowChestData.started then
                local yellowChestEntity = yellowChestData.entity

                if not yellowChestEntity or not yellowChestEntity.valid then
                    global.yellowChest[global.tick_yellow_index] = nil
                else
                    for _, player in pairs(game.players) do
                        yellowChestData.players[player.index] = player
                    end

                    global.tick_yellow_state = 1
                    --game.print("Yellow chest " .. yellowIndex .. " start inventory check")
                    for i = 1, yellowChestData.entity.request_slot_count do
                        local slot = yellowChestData.entity.get_request_slot(i);
                        if slot then
                            --game.print("Need " .. slot.name .. " in amount " .. slot.count)
                            yellowChestData.requested[slot.name] = slot.count
                        end
                    end

                    local chestInventory = yellowChestEntity.get_inventory(defines.inventory.chest);
                    if chestInventory then
                        for itemName, count in pairs(chestInventory.get_contents()) do
                            if itemName and count then
                                if yellowChestData.requested[itemName] and yellowChestData.requested[itemName] > 0 then
                                    if count >= yellowChestData.requested[itemName] then
                                        yellowChestData.requested[itemName] = 0
                                    elseif count < yellowChestData.requested[itemName] then
                                        yellowChestData.requested[itemName] = yellowChestData.requested[itemName] - count
                                    end
                                end
                            end
                        end
                    end
                end
            else
                --game.print("Yellow chest " .. yellowIndex .. " not started")
            end
        else
            -- yellow chest updates complete, moving on
            global.tick_yellow_index = nil
        end
        -- Inventory check for yellow chest
    elseif global.tick_yellow_state == 1 then

        --game.print("Inventory check for yellow chest " .. global.tick_yellow_index)

        if global.tick_yellow_index and not global.yellowChest[global.tick_yellow_index] then
            --game.print("reset in 1 state")
            global.tick_yellow_state = 0
            global.yellowChest[global.tick_yellow_index] = nil
        else

            local yellowChestData = global.yellowChest[global.tick_yellow_index]
            local yellowChestEntity = yellowChestData.entity
            local requested = yellowChestData.requested

            if yellowChestEntity and yellowChestEntity.valid then

                if yellowChestData.started then
                    --game.print("Yellow chest " .. global.tick_yellow_index .. " inventory check. Started")
                    -- 5 check per tick
                    for i = 1, 5 do
                        local playerIndex, _ = next(yellowChestData.players, global.tick_yellow_player_index)

                        --game.print("Yellow player index: " .. tostring(playerIndex))
                        --game.print(global.tick_yellow_player_connected)

                        if playerIndex then
                            local player = game.players[playerIndex]

                            global.tick_yellow_player_index = playerIndex

                            if player then
                                --game.print("Scout player: " .. player.name)
                                if player.connected == global.tick_yellow_player_connected then
                                    --game.print("Scout with connection check player: " .. player.name)

                                    local chestInventory = yellowChestEntity.get_inventory(defines.inventory.chest);

                                    if not chestInventory then
                                        break
                                    end

                                    if not Chests.check_player_inventories_for_request(player, requested, chestInventory) then
                                        yellowChestData.players = {}
                                        global.tick_blue_player_connected = false
                                        yellowChestData.started = false
                                        global.tick_yellow_player_index = nil
                                        global.tick_yellow_state = 0
                                        game.print("Сундук сбора ресурсов на нужды партии полон. Сбор ресурсов остановлен", { 0, 1, 1, 1 })
                                        break
                                    end
                                end

                            end
                        else
                            --game.print("Switch player connected: " .. tostring(global.tick_yellow_player_connected) .. " to " .. tostring(not global.tick_yellow_player_connected))
                            global.tick_yellow_player_connected = not global.tick_yellow_player_connected
                            global.tick_yellow_player_index = nil
                        end
                    end

                    local needRequest = false
                    for itemName, count in pairs(requested) do
                        if count > 0 then
                            needRequest = true
                        end
                    end

                    if not needRequest then
                        game.print("Сбор ресурсов на нужды партии завершен!", { 0, 1, 1, 1 })
                        yellowChestData.players = {}
                        global.tick_blue_player_connected = false
                        yellowChestData.started = false
                        global.tick_yellow_player_index = nil
                        global.tick_yellow_state = 0
                    end
                else
                    yellowChestData.players = {}
                    yellowChestData.requested = {}
                    global.tick_yellow_state = 0
                    global.tick_yellow_player_index = nil
                end
            else
                -- Get next yellow chest
                global.tick_yellow_state = 0
            end
        end
    else
        global.tick_yellow_state = 0
    end

    if global.tick_blue_state == 0 then
        if global.tick_blue_index and not global.blueChest[global.tick_blue_index] then
            global.blueChest[global.tick_blue_index] = nil
        end

        local blueIndex, blueChestData = next(global.blueChest, global.tick_blue_index)
        if blueIndex then
            --game.print("Picked yellow chest " .. blueIndex)
            global.tick_blue_index = blueIndex
            blueChestData.requested = {}
            if blueChestData.started then
                local blueChestEntity = blueChestData.entity

                if not blueChestEntity or not blueChestEntity.valid then
                    global.blueChest[global.tick_blue_index] = nil
                else
                    global.tick_blue_state = 1
                    for i = 1, blueChestData.entity.request_slot_count do
                        local slot = blueChestData.entity.get_request_slot(i);
                        if slot then
                            --game.print("Need " .. slot.name .. " in amount " .. slot.count)
                            blueChestData.requested[slot.name] = slot.count
                        end
                    end
                end
            end
        else
            -- blue chest updates complete, moving on
            global.tick_blue_index = nil
        end
        -- Inventory check for blue chest
    elseif global.tick_blue_state == 1 then

        --game.print("Inventory check for blue chest " .. global.tick_blue_index)

        if global.tick_blue_index and not global.blueChest[global.tick_blue_index] then
            global.blueChest[global.tick_blue_index] = nil
        else

            local blueChestData = global.blueChest[global.tick_blue_index]
            local blueChestEntity = blueChestData.entity

            if blueChestEntity and blueChestEntity.valid then

                if blueChestData.started then
                    -- 5 check per tick
                    for i = 1, 5, 1 do
                        local playerIndex, player = next(game.players, global.tick_blue_player_index)

                        if playerIndex then
                            if not player.connected then
                                --game.print("Scout player: " .. player.name)
                                local requested = blueChestData.requested

                                local chestInventory = entity.get_inventory(defines.inventory.chest);

                                if not chestInventory then
                                    break
                                end

                                Chests.check_player_inventories_for_request(player, requested, chestInventory)
                            end
                        else
                            global.tick_blue_player_index = nil
                            global.tick_blue_state = 0
                        end
                    end

                    local needRequest = false
                    for itemName, count in pairs(requested) do
                        if count > 0 then
                            needRequest = true
                        end
                    end

                    if not needRequest then
                        global.tick_blue_player_connected = false
                        blueChestData.started = false
                        global.tick_blue_state = 0
                    end
                end
            else
                -- Get next blue chest
                global.tick_blue_state = 0
            end
        end
    else
        global.tick_blue_state = 0
    end
end

function Chests.on_gui_opened(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    if not player then
        return
    end

    if not entity then
        return
    end

    if entity.name == "yellow-chest" then
        if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" then
            local yellowChestData = Chests.get_make_yellow_chest(entity.unit_number)

            if yellowChestData.entity and yellowChestData.entity.valid then
                local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]
                if (yellowChestGui) then
                    yellowChestGui.destroy();
                end
                yellowChestGui = player.gui.relative.add({
                    type = "frame",
                    name = "fed1s_yellow_chest_gui",
                    direction = "vertical",
                    caption = { "gui.yellow-chest-gui-label" },
                    tags = {
                        id = entity.unit_number,
                        chestType = "yellow"
                    }
                })
                yellowChestGui.anchor = {
                    gui = defines.relative_gui_type.container_gui,
                    position = defines.relative_gui_position["left"],
                }

                local statusText = "Включено"

                if not yellowChestData.started then
                    statusText = "Выключено"
                end

                yellowChestGui.add({
                    type = "label",
                    name = "fed1s_gui_yellow_chest_status",
                    caption = { "gui.yellowchest_status", statusText },

                })

                yellowChestGui.add({
                    type = "button",
                    name = "fed1s_gui_yellow_chest_start_button",
                    caption = { "gui.yellowchest_start_button" },
                    style = "green_button",
                    tags = { id = entity.unit_number, chestType = "yellow" },
                    enabled = not yellowChestData.started
                })

                yellowChestGui.add({
                    type = "button",
                    name = "fed1s_gui_yellow_chest_stop_button",
                    caption = { "gui.yellowchest_stop_button" },
                    style = "red_button",
                    tags = { id = entity.unit_number, chestType = "yellow" },
                    enabled = yellowChestData.started
                })
            end
        end

    end

end

return Chests;