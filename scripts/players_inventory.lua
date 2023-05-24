-- Copyright (c) 2023 Ajick


local mod_gui = require("__core__/lualib/mod-gui")


-- Constans and variables ----------------------------------------------------------------------------------------------

local in_debug = true
local in_single = false

local PlayersInventory = {}
PlayersInventory.players_data = {}
PlayersInventory.roles = {"warrior", "defender", "builder"} -- , "service"
PlayersInventory.roles_filters = {
    {"players-inventory.caption-all"},
    {"players-inventory.caption-warriors"},
    {"players-inventory.caption-defenders"},
    {"players-inventory.caption-builders"},
    "Неопределившиеся"
} -- , {"players-inventory.caption-service"}
PlayersInventory.inventories = {
    main = defines.inventory.character_main,
    armor = defines.inventory.character_armor,
    guns = defines.inventory.character_guns,
    ammo = defines.inventory.character_ammo,
    trash = defines.inventory.character_trash
}


-- Interface functions -------------------------------------------------------------------------------------------------

-- Toggle button --

function PlayersInventory.create_toggle_buttons()
    for _, player in pairs(game.players) do
        PlayersInventory.create_toggle_button(player)
    end
end

function PlayersInventory.create_toggle_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    local toggle_button = button_flow.players_inventory_toggle_button

    if toggle_button then
        toggle_button.destroy()
    end

    button_flow.add{
        type = "sprite-button",
        name = "players_inventory_toggle_button",
        sprite = "utility/slot_icon_armor",
        hovered_sprite = "utility/slot_icon_armor_black",
        clicked_sprite = "utility/slot_icon_armor_black",
        tooltip = {"players-inventory.caption"}
    }
end


-- Main window --

function PlayersInventory.build_players_inventory_window(player)
    local player_filters = global.players_inventory_filters[player.index]
    local players_data = PlayersInventory.players_data

    players_data[player.index] = {}

    if player.admin then
        players_data[player.index].selected = {main={}, armor={}, guns={}, ammo={}}
    end


    local window = player.gui.screen.add{type="frame", name="players_inventory_window", direction="vertical"}
    window.style.maximal_height = 850
    -- window.style.width = 650

    players_data[player.index].window = window


    -- Header --

    local titlebar = window.add{type="flow", direction="horizontal"}
    titlebar.drag_target = window

    titlebar.add{type="label", caption={"players-inventory.caption"}, ignored_by_interaction=true, style="frame_title"}

    local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
    spacer.style.horizontally_stretchable = true
    spacer.style.height = 24
    spacer.style.left_margin = 5
    spacer.style.right_margin = 5
    
    titlebar.add{
        type = "sprite-button",
        name = "players_inventory_close",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "frame_action_button"
    }


    -- Tabs --

    local tabs = window.add{type="tabbed-pane", name="players_inventory_tabs"}
    tabs.style.top_margin = 10

    for _, tab_name in pairs({"online", "offline", "warnings", "muted", "banned", "favorites", "search"}) do
        PlayersInventory.create_tab(tabs, tab_name, player_filters)
    end

    tabs.selected_tab_index = player_filters.tab_index


    return window
end

function PlayersInventory.create_tab(tabbed_pane, tab_name, player_filters)
    local tab = tabbed_pane.add{type="tab", caption={"players-inventory.caption-"..tab_name}}
    local content = tabbed_pane.add{type="flow", name=tab_name, direction="vertical"}


    -- Filters --

    local is_connection_tabs = (tab_name == "online" or tab_name == "offline")
    local is_search = (tab_name == "search")
    local filters

    if is_connection_tabs or is_search then
        filters = content.add{type="flow", name="filters", direction="horizontal"}
        filters.style.margin = 10
    end

    if is_connection_tabs then
        local roles = filters.add{
            type = "drop-down",
            name = "players_inventory_role",
            items = PlayersInventory.roles_filters,
            selected_index = player_filters.role_index
        }
    elseif is_search then
        local search = filters.add{type="textfield", name="players_inventory_search"}
        local clear_search = filters.add{
            type = "sprite-button",
            name = "players_inventory_clear_search",
            sprite = "utility/reset_white",
            hovered_sprite = "utility/reset",
            clicked_sprite = "utility/reset",
            style = "frame_action_button"
        }
        clear_search.style.top_margin = 3
    end


    -- Players list --

    local players = content.add{type="frame", name="players", direction="vertical", visible=false}

    local list = players.add{type="scroll-pane", name="list", direction="vertical"}
    list.style.horizontally_stretchable = true
    list.style.margin = 10

    local count = players.add{type="label", name="count", style="subheader_caption_label"}
    -- count.style.bottom_margin = 5
    count.caption = "Всего: 0"


    -- Empty placeholder --

    local placeholder = content.add{type="flow", name="placeholder", direction="vertical", visible=false}
    placeholder.style.horizontally_stretchable = true
    placeholder.style.minimal_height = 200
    placeholder.style.horizontal_align = "center"
    placeholder.style.vertical_align = "center"

    placeholder.add{type="sprite", sprite="utility/ghost_time_to_live_modifier_icon"}
    placeholder.add{type="label", caption={"players-inventory.caption-empty"}, style="inventory_label"}


    tabbed_pane.add_tab(tab, content)
end


-- Current tab --

function PlayersInventory.settingup_and_fill_current_tab(player_index, in_search)
    local player_filters = global.players_inventory_filters[player_index]
    local player_data = PlayersInventory.players_data[player_index]
    local tab_content = player_data.window.players_inventory_tabs.tabs[player_filters.tab_index].content

    if tab_content.name == "favorites" and #player_filters.favorites == 0
    or tab_content.name == "warnings" and #global.players_inventory_warnings == 0
    or tab_content.name == "muted" and #global.players_inventory_muted == 0
    or tab_content.name == "banned" and #global.players_inventory_banned == 0
    then
        tab_content.players.visible = false
        tab_content.placeholder.visible = true
        return
    elseif tab_content.name == "search" then
        tab_content.filters.players_inventory_search.focus()

        if in_search and string.len(tab_content.filters.players_inventory_search.text) == 0 then
            tab_content.players.visible = false
            tab_content.placeholder.visible = true
            return
        elseif not in_search then
            tab_content.players.visible = (#tab_content.players.list.children > 0)
            tab_content.placeholder.visible = (#tab_content.players.list.children == 0)
            return
        end
    end

    local players_list = tab_content.players.list

    players_list.clear()

    if tab_content.name == "online" or tab_content.name == "offline" then
        local online = (tab_content.name == "online")

        if tab_content.filters.players_inventory_role.selected_index > 1 then
            local role = PlayersInventory.roles[tab_content.filters.players_inventory_role.selected_index - 1]
            PlayersInventory.fill_players_list_by_role(players_list, online, role)
        else
            PlayersInventory.fill_players_list_by_role(players_list, online)
        end
    elseif tab_content.name == "warnings" then
        PlayersInventory.fill_players_list_by_filter(players_list, global.players_inventory_warnings)
    elseif tab_content.name == "muted" then
        PlayersInventory.fill_players_list_by_filter(players_list, global.players_inventory_muted)
    elseif tab_content.name == "banned" then
        PlayersInventory.fill_players_list_by_filter(players_list, global.players_inventory_banned)
    elseif tab_content.name == "favorites" then
        PlayersInventory.fill_players_list_by_filter(players_list, player_filters.favorites)
    elseif tab_content.name == "search" then
        PlayersInventory.fill_players_list_by_name(
            players_list,
            string.lower(tab_content.filters.players_inventory_search.text)
        )
    end

    local count = #players_list.children

    if count > 0 then
        players_list.count.caption = {"players-inventory.caption-count", count}
    end

    tab_content.players.visible = (count > 0)
    tab_content.placeholder.visible = (count == 0)
end

function PlayersInventory.fill_players_list_by_role(players_list, online, role)
    for player_index, player in pairs(game.players) do
        if player.online ~= online then
            goto continue
        end

        if role then
            local playerdata = ServerMod.get_make_playerdata(player_index)

            if currentPlayerData.applied and playerdata.role ~= role then
                goto continue
            end
        end

        PlayersInventory.build_player_inventory_panel(players_list, game.players[player_index])

        ::continue::
    end
end

function PlayersInventory.fill_players_list_by_filter(players_list, filtered_players)
    for _, player_index in pairs(filtered_players) do
        PlayersInventory.build_player_inventory_panel(players_list, game.players[player_index])
    end
end

function PlayersInventory.fill_players_list_by_name(players_list, name)
    for _, player in pairs(game.players) do
        if string.match(string.lower(player.name), name) then
            PlayersInventory.build_player_inventory_panel(players_list, player)
        end
    end
end

function PlayersInventory.build_player_inventory_panel(window, player)
    local self_player = game.players[window.player_index]
    local panel = window["main-flow"].add{
        type = "frame",
        direction = "vertical",
        tags = {player_index=player.index}
    }
    panel.style.padding = 8


    -- Header ---------------------------------------------------------------------------------------------------------

    local header = panel.add{type="flow"}

    header.add{
        type = "sprite-button",
        name = "expand-player-inventory-button",
        sprite = "utility/expand",
        hovered_sprite = "utility/expand_dark",
        clicked_sprite = "utility/expand_dark",
        style = "frame_action_button",
        tags = {player_index=player.index}
    }
    header.add{
        type = "sprite-button",
        name = "follow-player-button",
        sprite = "utility/search_white",
        hovered_sprite = "utility/search_black",
        clicked_sprite = "utility/search_black",
        tooltip = {"players-inventory.caption-follow"},
        visible = player.connected,
        style = "frame_action_button",
        tags = {player_index=player.index}
    }

    header.add{type="label", caption=player.name, style="subheader_caption_label"}

    if player.admin then
        header.add{type="label", caption={"players-inventory.label-admin"}}
    end

    if player.permission_group.name == "Manager" then
        header.add{type="label", caption={"players-inventory.label-manager"}}
    end

    local playerdata = ServerMod.get_make_playerdata(player.index)

    if playerdata.applied then
        header.add{type="label", caption={"players-inventory.label-"..playerdata.role}}
    end

    if player.connected then
        header.add{type="label", caption={"players-inventory.label-online"}}
    else
        header.add{type="label", caption={"players-inventory.label-offline"}}
    end

    local spacer = header.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true

    header.add{
        type = "sprite-button",
        name = "mute-player-button",
        sprite = "utility/logistic_network_panel_white",
        hovered_sprite = "utility/logistic_network_panel_black",
        clicked_sprite = "utility/logistic_network_panel_black",
        tooltip = {"players-inventory.tooltip-mute"},
        visible = self_player.admin,
        style = "frame_action_button",
        tags = {player_index=player.index, action="mute", panel=panel.get_index_in_parent()}
    } -- 
    header.add{
        type = "sprite-button",
        name = "kick-player-button",
        sprite = "utility/warning_white",
        hovered_sprite = "utility/warning",
        clicked_sprite = "utility/warning",
        tooltip = {"players-inventory.tooltip-kick"},
        visible = self_player.admin,
        style = "frame_action_button",
        tags = {player_index=player.index, action="kick", panel=panel.get_index_in_parent()}
    }
    header.add{
        type = "sprite-button",
        name = "ban-player-button",
        sprite = "utility/trash_white",
        hovered_sprite = "utility/trash",
        clicked_sprite = "utility/trash",
        tooltip = {"players-inventory.tooltip-ban"},
        visible = self_player.admin,
        style = "frame_action_button",
        tags = {player_index=player.index, action="ban", panel=panel.get_index_in_parent()}
    }


    -- Content --------------------------------------------------------------------------------------------------------

    local content = panel.add{type="flow", name="content", direction="vertical"}
    content.style.top_margin = 5
    content.visible = false

    content.add{type="line", direction="horizontal"}

    local inventories = content.add{type="flow", name="inventories", direction="vertical"}
    inventories.style.horizontally_stretchable = true
    inventories.style.horizontal_align = "center"

    PlayersInventory.build_player_inventory_flow(
        inventories,
        "main-inventory",
        {"players-inventory.label-main-inventory"}
    )
    PlayersInventory.build_player_inventory_flow(
        inventories,
        "ammunition-inventory",
        {"players-inventory.label-ammunition-inventory"}
    )
    PlayersInventory.build_player_inventory_flow(
        inventories,
        "trash-inventory",
        {"players-inventory.label-trash-inventory"}
    )

    local line = content.add{type="line", direction="horizontal"}
    line.style.top_margin = 18

    -- Buttons --------------------------------------------------------------------------------------------------------

    local buttons = content.add{type="flow", name="buttons", direction="horizontal"}
    buttons.style.padding = 8

    spacer = buttons.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true

    buttons.add{
        type = "button",
        name = "take-player-inventory-button",
        caption = {"players-inventory.caption-take"},
        enabled = false,
        tags = {player_index=player.index, panel=panel.get_index_in_parent()}
    }
end


-- ? --

function PlayersInventory.build_players_inventory_list_old(window)
    local self_player = game.players[window.player_index]
    local players_list = window["main-flow"]
    local filters = window["filters-flow"]
    local connected_state = filters["filter-connected"].switch_state
    local role_index = filters["filter-role"].selected_index
    local search_name = string.lower(filters["filter-search"].text)
    local count = 0

    global.selected_items_count[self_player.index] = {}
    players_list.clear()

    for _, player in pairs(game.players) do
        if player.admin and not self_player.admin then 
            goto continue
        end

        if player.index == self_player.index and not in_debug and not in_single then 
            goto continue
        end

        if connected_state
        and (connected_state == "left" and not player.connected)
        or (connected_state == "right" and player.connected) then
            goto continue
        end

        local playerdata = ServerMod.get_make_playerdata(player.index)

        if role_index ~= 1
        and playerdata.role ~= PlayersInventory.roles[role_index-1] then
            goto continue
        end

        if search_name
        and not string.find(string.lower(player.name), search_name) then
            goto continue
        end

        PlayersInventory.build_player_inventory_panel(window, player)

        count = count + 1

        ::continue::
    end

    local is_empty = (count == 0)

    if not is_empty then
        window["count-flow"]["count"].caption = {"players-inventory.caption-count", count}
    end

    window["empty-flow"].visible = is_empty
    window["count-flow"].visible = not is_empty
end

function PlayersInventory.build_player_inventory_flow(parent, name, caption)
    local inventory_flow = parent.add{type="flow", name=name, direction="vertical"}
    inventory_flow.style.top_margin = 12
    inventory_flow.add{type="label", caption=caption, style="heading_2_label"}
    inventory_flow.add{type="table", name="grid", column_count=10}
end

function PlayersInventory.build_player_inventories(inventories, player)
    PlayersInventory.build_common_inventory(
        inventories["main-inventory"],
        player.get_inventory(defines.inventory.character_main)
    )
    PlayersInventory.build_ammunition_inventory(inventories["ammunition-inventory"], player)
    PlayersInventory.build_common_inventory(
        inventories["trash-inventory"],
        player.get_inventory(defines.inventory.character_trash)
    )
end

function PlayersInventory.build_common_inventory(inventory_flow, inventory)
    if not inventory or inventory.get_item_count() == 0 then
        inventory_flow.visible = false
        return
    end

    local grid = inventory_flow["grid"]
    local inventory_type = inventory.index
    local content = inventory.get_contents()

    if inventory_type == defines.inventory.character_main then
        inventory_type = "main"
    else
        inventory_type = "trash"
    end

    local tags = {
        player_index = inventory.player_owner.index,
        inventory_type = inventory_type,
        panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
    }

    grid.clear()

    for item_name, amount in pairs(content) do
        tags.item_name = item_name
        PlayersInventory.build_inventory_button(grid, "item/"..item_name, tags, {amount=amount})
    end

    local cells_count = #grid.children

    if inventory.index ~= defines.inventory.character_main and cells_count == 0 then
        inventory_flow.visible = false
        return
    end
    
    if cells_count > 0 then
        if cells_count % 10 > 0 then
            for _ = 1, 10 - cells_count % 10 do
                PlayersInventory.build_inventory_button(grid)
            end
        end
    else
        for _ = 1, 10 do
            PlayersInventory.build_inventory_button(grid)
        end
    end

    inventory_flow.visible = true
end

function PlayersInventory.build_ammunition_inventory(inventory_flow, target_player)
    local armor_inventory = target_player.get_inventory(defines.inventory.character_armor)
    local guns_inventory = target_player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = target_player.get_inventory(defines.inventory.character_ammo)

    local grid = inventory_flow["grid"]
    grid.clear()


    -- Armor ----------------------------------------------------------------------------------------------------------

    if armor_inventory and not armor_inventory.is_empty() then
        local armor_name = armor_inventory[1].name
        local tags = {
            player_index = armor_inventory.player_owner.index,
            inventory_type = "armor",
            item_name = armor_name,
            panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
        }

        PlayersInventory.build_inventory_button(grid, "item/"..armor_name, tags, {name="armor"})
    else
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_armor")
    end


    -- Guns -----------------------------------------------------------------------------------------------------------

    if guns_inventory then
        for gun_index = 1, #guns_inventory do 
            local item = guns_inventory[gun_index]

            if item.valid_for_read then
                local tags = {
                    player_index = guns_inventory.player_owner.index,
                    inventory_type = "guns",
                    item_name = item.name,
                    panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
                }

                PlayersInventory.build_inventory_button(grid, "item/"..item.name, tags)
            else
                PlayersInventory.build_inventory_button(grid, "utility/slot_icon_gun")
            end
        end
    else
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_gun")
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_gun")
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_gun")
    end


    -- Fillers --------------------------------------------------------------------------------------------------------

    for _ = 1, 7 do
        local filler = grid.add{type="empty-widget"}
        filler.style.width = 40
    end


    -- Ammo -----------------------------------------------------------------------------------------------------------

    if ammo_inventory then
        for ammo_index = 1, #ammo_inventory do
            local item = ammo_inventory[ammo_index]

            if item.valid_for_read then
                local tags = {
                    player_index = ammo_inventory.player_owner.index,
                    inventory_type = "ammo",
                    item_name = item.name,
                    panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
                }

                PlayersInventory.build_inventory_button(grid, "item/"..item.name, tags, {amount=item.count})
            else
                PlayersInventory.build_inventory_button(grid, "utility/slot_icon_ammo")
            end
        end
    else
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_ammo")
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_ammo")
        PlayersInventory.build_inventory_button(grid, "utility/slot_icon_ammo")
    end
end

function PlayersInventory.build_inventory_button(parent, sprite, tags, params)
    local player = game.players[parent.player_index]
    local index, name

    if params and params.name then
        name = params.name
    else
        index = #parent.children + 1
        name = "inventory-item-"..index
    end

    local button = parent.add{
        type = "sprite-button",
        name = name,
        style = "inventory_slot"
    }

    if sprite then
        button.sprite = sprite
    end

    if tags then
        button.tags = tags
    end

    if params and params.amount then
        button.number = params.amount
    end

    if player.admin or name == "armor" then
        button.tooltip = {"players-inventory.tooltip-inventory-button"}
    end

    if not tags or not player.admin and name ~= "armor" then
        button.ignored_by_interaction = true
    end
end

function PlayersInventory.build_kickban_accept_window(player, tags)
    if player.gui.screen["kickban-accept-window"] then
        return
    end

    local target_player = game.players[tags.player_index]
    local window = player.gui.screen.add{type="frame", name="kickban-accept-window", direction="vertical"}


    -- Header ---------------------------------------------------------------------------------------------------------

    local titlebar = window.add{type="flow", direction="horizontal"}
    titlebar.drag_target = window

    titlebar.add{
        type = "label",
        caption = {"players-inventory.caption-action", {"players-inventory.caption-"..tags.action}, target_player.name},
        ignored_by_interaction = true,
        style = "frame_title"
    }

    local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
    spacer.style.horizontally_stretchable = true
    spacer.style.height = 24
    spacer.style.left_margin = 4
    spacer.style.right_margin = 4
    
    titlebar.add{
        type = "sprite-button",
        name = "close-kickban-accept-window-button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "frame_action_button"
    }


    -- Reason ---------------------------------------------------------------------------------------------------------

    window.add{type="label", caption={"players-inventory.caption-reason"}, style="inventory_label"}

    local reason_textbox = window.add{type="text-box", name="reason-textbox", text="Пшёл вон!"}
    reason_textbox.style.width = 350
    reason_textbox.style.height = 100

    
    -- Buttons --------------------------------------------------------------------------------------------------------

    local buttons = window.add{type="flow", direction="horizontal"}
    buttons.style.horizontally_stretchable = true
    buttons.style.top_margin = 5
    buttons.style.horizontal_align = "right"

    buttons.add{
        type = "button",
        name = "accept-kickban-button",
        caption = {"players-inventory.caption-"..tags.action},
        tags = tags
    }
    buttons.add{
        type = "button",
        name = "cancel-kickban-button",
        caption = {"players-inventory.caption-cancel"}
    }


    return window
end


function PlayersInventory.take_common_inventory(from_inventory, to_inventory, filters)
    local player = to_inventory.player_owner
    local fit_all

    for i = 1, #from_inventory do
        local stack = from_inventory[i]

        if not stack.valid_for_read
        or not PlayersInventory.selected(stack.name, filters) then
            goto continue
        end

        fit_all = PlayersInventory.take_stack(from_inventory, to_inventory, stack)

        if not fit_all then
            player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
            return false
        end

        ::continue::
    end

    return true
end

function PlayersInventory.take_ammunition_inventory(from_inventories, to_inventory, filters)
    local armor_inventory = from_inventories[1]
    local guns_inventory = from_inventories[2]
    local ammo_inventory = from_inventories[3]

    local player = to_inventory.player_owner
    local fit_all

    if in_single then
        player = armor_inventory.player_owner
    end

    
    -- Armor ----------------------------------------------------------------------------------------------------------

    local stack = armor_inventory[1]

    if stack.valid_for_read
    and PlayersInventory.match_and_selected(filters.children[1], stack.name) then
        fit_all = PlayersInventory.take_stack(armor_inventory, to_inventory, stack)

        if not fit_all then
            player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
            return
        end
    end


    -- Guns -----------------------------------------------------------------------------------------------------------

    for i = 1, #guns_inventory do
        local stack = guns_inventory[i]

        if stack.valid_for_read
        and PlayersInventory.match_and_selected(filters.children[i+1], stack.name) then
            fit_all = PlayersInventory.take_stack(guns_inventory, to_inventory, stack)

            if not fit_all then
                player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
                return
            end
        end
    end


    -- Ammo -----------------------------------------------------------------------------------------------------------

    for i = 1, #ammo_inventory do
        local stack = ammo_inventory[i]

        if stack.valid_for_read
        and PlayersInventory.match_and_selected(filters.children[i+11], stack.name) then
            fit_all = PlayersInventory.take_stack(ammo_inventory, to_inventory, stack)

            if not fit_all then
                player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
                return
            end
        end
    end
end

function PlayersInventory.take_items(player, button, one_stack)
    one_stack = one_stack or false
    local inventory_type = PlayersInventory.inventories[button.tags.inventory_type]
    local from_player = game.players[button.tags.player_index]
    local from_inventory = from_player.get_inventory(inventory_type)
    local to_inventory = player.get_main_inventory()

    if in_single then
        local chests = player.surface.find_entities_filtered{radius=5, name="steel-chest"}

        if #chests == 0 then
            print("Поставь сундук!")
            return
        end

        to_inventory = chests[1].get_inventory(defines.inventory.chest)
    end

    local fit_all = true

    while true do
        local stack, _ = from_inventory.find_item_stack(button.tags.item_name)
        
        if not stack then
            break
        end

        fit_all = PlayersInventory.take_stack(from_inventory, to_inventory, stack)

        if not fit_all or one_stack then
            break
        end
    end

    if not fit_all then
        player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
    end

    global.selected_items_count[player.index][button.tags.panel_index] = 0
    button.parent.parent.parent.parent["buttons"]["take-player-inventory-button"].enabled = false

    -- TODO: Сделать перестройку только того инвентаря, из которого были изъяты предметы
    -- local profiler = game.create_profiler()
    PlayersInventory.build_player_inventories(button.parent.parent.parent, from_player)
    -- prifiler2.stop()
    -- game.print("Build inventories: ")
    -- game.print(profiler);
end

function PlayersInventory.take_stack(from_inventory, to_inventory, stack)
    if not to_inventory.can_insert(stack) then
        return false
    end

    local inserted = to_inventory.insert(stack)

    if inserted < stack.count then
        stack.count = stack.count - inserted

        if to_inventory.can_insert(stack) then
            return true
        end
        
        return false
    else
        from_inventory.remove(stack)
        return true
    end
end


-- Interface utility function ------------------------------------------------------------------------------------------






function PlayersInventory.selected(item_name, filters)
    for i = 1, #filters.children do
        local button = filters.children[i]

        if button.sprite and PlayersInventory.match_and_selected(button, item_name) then
            return true
        end
    end

    return false
end

function PlayersInventory.match_and_selected(button, item_name)
    local item_name = string.gsub(item_name, "%-", "%%-")
    return string.match(button.sprite, item_name) and button.style.name == "filter_inventory_slot"
end





-- Events --------------------------------------------------------------------------------------------------------------

-- Configuration --

function reinit() -- FOR DEBUG

    global.players_inventory_warnings = {}
    global.players_inventory_muted = {}
    global.players_inventory_banned = {}
    global.players_inventory_filters = {}

    for player_index = 1, #game.players do
        global.players_inventory_filters[player_index] = {}
        global.players_inventory_filters[player_index].favorites = {}
        global.players_inventory_filters[player_index].tab_index = 1
        global.players_inventory_filters[player_index].role_index = 1

        PlayersInventory.create_toggle_button(game.players[player_index])
    end
end

function PlayersInventory.on_init()
    global.players_inventory_warnings = global.players_inventory_warnings or {}
    global.players_inventory_muted = global.players_inventory_muted or {}
    global.players_inventory_banned = global.players_inventory_banned or {}
    global.players_inventory_filters = global.players_inventory_filters or {}
end

function PlayersInventory.on_configuration_changed(data)
    PlayersInventory.on_init()
    PlayersInventory.create_toggle_buttons()

    if gebug then
        game.print("Configuration updated")
    end
end

function PlayersInventory.on_player_created(event)
    local player_index = event.player_index

    global.players_inventory_filters[player_index] = {}
    global.players_inventory_filters[player_index].favorites = {}
    global.players_inventory_filters[player_index].tab_index = 1
    global.players_inventory_filters[player_index].role_index = 1

    PlayersInventory.create_toggle_button(game.players[player_index])
end


-- Main window --

function PlayersInventory.on_toggle_players_inventory_window(event)
    local players_data = PlayersInventory.players_data
    local player_index = event.player_index

    if players_data[player_index] then
        players_data[player_index].window.destroy()
        players_data[player_index] = nil
        return
    end

    local window = PlayersInventory.build_players_inventory_window(game.players[player_index])

    PlayersInventory.settingup_and_fill_current_tab(player_index)

    window.force_auto_center()
end

function PlayersInventory.on_players_inventory_close(event)
    local players_data = PlayersInventory.players_data
    local player_index = event.player_index

    if players_data[player_index] then
        players_data[player_index].window.destroy()
        players_data[player_index] = nil
    end
end

function PlayersInventory.on_gui_selected_tab_changed(event)
    local tabbed_pane = event.element
    local player_filters = global.players_inventory_filters[event.player_index]

    player_filters.tab_index = tabbed_pane.selected_tab_index

    for index, tab in pairs(tabbed_pane.tabs) do
        if index ~= tabbed_pane.selected_tab_index then
            tab.content.players.visible = false
            tab.content.placeholder.visible = false
        end
    end

    PlayersInventory.settingup_and_fill_current_tab(event.player_index)
end




function PlayersInventory.on_change_filters(event)
    if not event.element.valid then
        return
    end

    if event.element.name ~= "players_inventory_role" then
        return
    end

    
    local player_filters = global.players_inventory_filters[event.player_index]
    local player_data = PlayersInventory.players_data[event.player_index]
    local window = player_data.window
    local tabs = window.players_inventory_tabs
    -- local tab = global.

    player_filters.role_index = event.element.selected_index

    tabs.online.filters.players_inventory_role.selected_index = player_filters.role_index
    tabs.offline.filters.players_inventory_role.selected_index = player_filters.role_index

    -- PlayersInventory.build_players_inventory_list(window)
end

function PlayersInventory.on_expand_player_inventory_button_click(event)
    local button = event.element
    local player = game.players[button.tags.player_index]
    local content = button.parent.parent["content"]
    local inventory_index = button.parent.parent.get_index_in_parent()

    if content.visible then
        button.sprite = "utility/expand"
        button.hovered_sprite = "utility/expand_dark"
        button.clicked_sprite = "utility/expand_dark"

        global.selected_items_count[event.player_index][inventory_index] = nil
    else
        button.sprite = "utility/collapse"
        button.hovered_sprite = "utility/collapse_dark"
        button.clicked_sprite = "utility/collapse_dark"

        global.selected_items_count[event.player_index][inventory_index] = 0

        PlayersInventory.build_player_inventories(content["inventories"], player)
        button.parent.parent.parent.scroll_to_element(button.parent.parent)
    end

    content.visible = not content.visible
end


-- Common actions --

function PlayersInventory.on_search(event)
    PlayersInventory.settingup_and_fill_current_tab(event.player_index, true)
end

function PlayersInventory.on_clear_search(event)
    event.element.parent.players_inventory_search.text = ""
    PlayersInventory.settingup_and_fill_current_tab(event.player_index, true)
end

function PlayersInventory.on_show_player_button_click(event)
    local character = game.players[event.element.tags.player_index].character

    if not character then
        return
    end

    game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
    game.players[event.player_index].zoom_to_world(character.position, 1.0, character)
end

function PlayersInventory.on_armor_click(event) -- NOT_IMPLEMENTED
    -- body
end

-- Common actions --

function PlayersInventory.on_take_player_inventory_button_click(event)
    local from_player = game.players[event.element.tags.player_index]
    local main_inventory = from_player.get_inventory(defines.inventory.character_main)
    local armor_inventory = from_player.get_inventory(defines.inventory.character_armor)
    local guns_inventory = from_player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = from_player.get_inventory(defines.inventory.character_ammo)
    local trash_inventory = from_player.get_inventory(defines.inventory.character_trash)

    local window = game.players[event.player_index].gui.screen["players-inventory-window"]
    local panel = window["main-flow"].children[event.element.tags.panel]["content"]
    local take_button = panel["buttons"]["take-player-inventory-button"]
    local buttons = panel["inventories"]
    local main_buttons = buttons["main-inventory"]["grid"]
    local ammunition_buttons = buttons["ammunition-inventory"]["grid"]
    local trash_buttons = buttons["trash-inventory"]["grid"]

    local to_player = game.players[event.player_index]
    local to_inventory = to_player.get_main_inventory()

    if in_single then
        local chests = to_player.surface.find_entities_filtered{radius=5, name="steel-chest"}

        if #chests == 0 then
            print("Поставь сундук!")
            return
        end

        to_inventory = chests[1].get_inventory(defines.inventory.chest)
    end

    if not PlayersInventory.take_common_inventory(main_inventory, to_inventory, main_buttons) then
        goto exit
    end

    if not PlayersInventory.take_common_inventory(trash_inventory, to_inventory, trash_buttons) then
        goto exit
    end

    PlayersInventory.take_ammunition_inventory(
        {armor_inventory, guns_inventory, ammo_inventory},
        to_inventory,
        ammunition_buttons
    )

    ::exit::

    take_button.enabled = false
    global.selected_items_count[to_player.index][event.element.tags.panel] = 0

    -- local profiler = game.create_profiler()
    -- TODO: Сделать перестройку только того инвентаря, из которого были изъяты предметы
    PlayersInventory.build_player_inventories(buttons, from_player)
    -- profiler.stop()
    -- game.print("Build inventories: ")
    -- game.print(profiler)
end

function PlayersInventory.on_inventory_button_click(event)
    local button = event.element
    local player = game.players[event.player_index]

    if event.button == 2 then
        if event.shift and player.admin then
            PlayersInventory.take_items(player, button, true)
        elseif event.control and player.admin then
            PlayersInventory.take_items(player, button)
        elseif button.name == "armor" then
            -- players_inventory_armor
            local target_player = game.players[button.tags.player_index]
            player.print("[armor="..target_player.name.."]")
        end
    elseif event.button == 4 and player.admin then
        local panel = button.parent.parent.parent.parent.parent
        local panel_index = panel.get_index_in_parent()
        local selected_items = global.selected_items_count[player.index]

        if button.style.name == "inventory_slot" then
            button.style = "filter_inventory_slot"
            selected_items[panel_index] = selected_items[panel_index] + 1
        else
            button.style = "inventory_slot"
            selected_items[panel_index] = selected_items[panel_index] - 1
        end

        panel["content"]["buttons"]["take-player-inventory-button"].enabled = selected_items[panel_index] > 0
    end
end


function PlayersInventory.on_mute_button_click(event)
    game.mute_player(game.players[event.player_index])
end

function PlayersInventory.on_kickban_buttons_click(event)
    local player = game.players[event.player_index]
    local window = PlayersInventory.build_kickban_accept_window(player, event.element.tags)
    window["reason-textbox"].focus()
    window["reason-textbox"].select_all()

    window.force_auto_center()
end

function PlayersInventory.on_kickban_accept_button_click(event)
    local tags = event.element.tags
    local player = game.players[tags.player_index]
    local window = game.players[event.player_index].gui.screen["players-inventory-window"]
    local kickban_window = game.players[event.player_index].gui.screen["kickban-accept-window"]

    game[tags.action.."_player"](player, kickban_window["reason-textbox"].text)
    window['main-flow'].children[tags.panel].destroy()

    kickban_window.destroy()
end

function PlayersInventory.on_kickban_closecancel_buttons_click(event)
    game.players[event.player_index].gui.screen["kickban-accept-window"].destroy()
end


-- GUI clicks dispatcher --

function PlayersInventory.on_gui_click(event)
    if not event or not event.element or not event.element.valid then
        return
    end

    local element_name = event.element.name

    if PlayersInventory.players_inventory_gui_click_events[element_name] then
        PlayersInventory.players_inventory_gui_click_events[element_name](event)
    elseif string.match(element_name, "inventory%-item%-") or element_name == "armor" then
        PlayersInventory.on_inventory_button_click(event)
    end
end

PlayersInventory.players_inventory_gui_click_events = {
    ["players_inventory_toggle_button"] = PlayersInventory.on_toggle_players_inventory_window,
    ["players_inventory_close"] = PlayersInventory.on_players_inventory_close,
    ["?expand-player-inventory-button"] = PlayersInventory.on_expand_player_inventory_button_click,

    ["players_inventory_clear_search"] = PlayersInventory.on_clear_search,
    ["?follow-player-button"] = PlayersInventory.on_show_player_button_click,
    ["players_inventory_armor"] = PlayersInventory.on_armor_click,

    ["?take-player-inventory-button"] = PlayersInventory.on_take_player_inventory_button_click,

    ["?mute-player-button"] = PlayersInventory.on_mute_button_click,
    ["?kick-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["?ban-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["?accept-kickban-button"] = PlayersInventory.on_kickban_accept_button_click,
    ["?cancel-kickban-button"] = PlayersInventory.on_kickban_closecancel_buttons_click,
    ["?close-kickban-accept-window-button"] = PlayersInventory.on_kickban_closecancel_buttons_click
}


-- Utility functions ---------------------------------------------------------------------------------------------------

function print(str)
    game.print(str)
end

function pprint(obj, types)
    for i, k in pairs(obj) do
        if types then 
            game.print(i .. " - " .. type(k))
        else
            game.print(i .. " - " .. tostring(k))
        end
    end
end


-- Events dispatcher ---------------------------------------------------------------------------------------------------

local event_handlers = {}
event_handlers.on_init = PlayersInventory.on_init
event_handlers.on_configuration_changed = PlayersInventory.on_configuration_changed
event_handlers.events = {
    [defines.events.on_player_created] = PlayersInventory.on_player_created,
    [defines.events.on_player_demoted] = PlayersInventory.on_players_inventory_close,

    ["on-toggle-players-inventory-window"] = PlayersInventory.on_toggle_players_inventory_window,

    [defines.events.on_gui_selected_tab_changed] = PlayersInventory.on_gui_selected_tab_changed,

    [defines.events.on_gui_selection_state_changed] = PlayersInventory.on_change_filters,
    [defines.events.on_gui_text_changed] = PlayersInventory.on_search,

    [defines.events.on_gui_click] = PlayersInventory.on_gui_click
}
EventHandler.add_lib(event_handlers)

commands.add_command(
    "fadmin",
    {"players-inventory.open-description"},
    PlayersInventory.on_toggle_players_inventory_window
)



return PlayersInventory
