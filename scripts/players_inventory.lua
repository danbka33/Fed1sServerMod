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
    {"players-inventory.caption-builders"}
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
    local toggle_button = button_flow.players_inventory_toggle_window
    
    if toggle_button then
        toggle_button.destroy()
    end

    button_flow.add{
        type = "sprite-button",
        name = "players_inventory_toggle_window",
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

    local window = player.gui.screen.add{type="frame", name="players_inventory_window", direction="vertical"}
    window.style.maximal_height = 850

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
        name = "players_inventory_close_window_button",
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


    --

    return window
end

function PlayersInventory.create_tab(tabbed_pane, tab_name, player_filters)
    local tab = tabbed_pane.add{type="tab", caption={"players-inventory.caption-"..tab_name}}
    local content = tabbed_pane.add{type="frame", name=tab_name, direction="vertical"}
    content.style.top_margin = -2
    content.style.padding = 10


    -- Filters --

    local is_connection_tabs = (tab_name == "online" or tab_name == "offline")
    local is_search = (tab_name == "search")
    local filters

    if is_connection_tabs or is_search then
        filters = content.add{type="flow", name="filters", direction="horizontal"}
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

    local players = content.add{type="flow", name="players", direction="vertical", visible=false}
    players.style.top_margin = 10

    local list = players.add{type="scroll-pane", name="list", direction="vertical"}
    list.style.horizontally_stretchable = true
    
    local count = players.add{type="label", name="count", style="subheader_caption_label"}
    count.style.top_margin = 10
    count.style.padding = 0


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

    player_data.selected = nil

    if tab_content.name == "favorites" and #player_filters.favorites == 0
    or tab_content.name == "warnings" and  table_size(global.players_inventory_warnings) == 0
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
    elseif tab_content.name == "online" or tab_content.name == "offline" then
        tab_content.filters.players_inventory_role.selected_index = player_filters.role_index
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
        PlayersInventory.fill_players_list_by_warnings(players_list)
    elseif tab_content.name == "muted" then
        PlayersInventory.fill_players_list_by_filter(players_list, global.players_inventory_muted)
    elseif tab_content.name == "banned" then
        PlayersInventory.fill_players_list_by_filter(players_list, global.players_inventory_banned)
    elseif tab_content.name == "favorites" then
        PlayersInventory.fill_players_list_by_filter(players_list, player_filters.favorites)
    elseif tab_content.name == "search" then
        PlayersInventory.fill_players_list_by_name(
            players_list, string.lower(tab_content.filters.players_inventory_search.text)
        )
    end

    local count = #players_list.children

    if count > 0 then
        tab_content.players.count.caption = {"players-inventory.caption-count", count}
        tab_content.players.list.scroll_to_top()
    end

    tab_content.players.visible = (count > 0)
    tab_content.placeholder.visible = (count == 0)
end

function PlayersInventory.fill_players_list_by_role(players_list, online, role)
    for player_index, player in pairs(game.players) do
        if player.connected ~= online then
            goto continue
        end

        if role then
            local playerdata = ServerMod.get_make_playerdata(player_index)

            if not playerdata.applied or playerdata.applied and playerdata.role ~= role then
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

function PlayersInventory.fill_players_list_by_warnings(players_list)
    for player_index, _ in pairs(global.players_inventory_warnings) do
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

function PlayersInventory.build_player_inventory_panel(players_list, target_player)
    local self_player = game.players[players_list.player_index]
    local muted = PlayersInventory.is_muted(target_player.index)
    local banned = PlayersInventory.is_banned(target_player.index)
    local warnings = global.players_inventory_warnings[target_player.index] or 0
    local tab_index = PlayersInventory.players_data[self_player.index].window.players_inventory_tabs.selected_tab_index
    local role_index = global.players_inventory_filters[self_player.index].role_index

    local panel = players_list.add{type="frame", name=target_player.name, direction="vertical"}
    panel.style.vertically_stretchable = false
    panel.style.padding = 5


    -- Header --

    local header = panel.add{type="flow", name="header"}

    header.add{
        type = "sprite-button",
        name = "players_inventory_expand_button",
        sprite = "utility/expand",
        hovered_sprite = "utility/expand_dark",
        clicked_sprite = "utility/expand_dark",
        style = "frame_action_button",
        tags = {player_index=target_player.index}
    }

    header.add{type="label", caption=target_player.name, style="subheader_caption_label"}

    header.add{
        type="label", name="admin", caption={"players-inventory.label-admin-badge"},
        visible=target_player.admin
    }

    header.add{
        type="label", name="manager", caption={"players-inventory.label-manager-badge"},
        visible=(target_player.permission_group.name == "Manager")
    }

    if (tab_index == 1 or tab_index == 2) and role_index == 1
    or tab_index ~= 1 and tab_index ~= 2
    then
        local playerdata = ServerMod.get_make_playerdata(target_player.index)

        if playerdata.applied then
            header.add{type="label", name="role", caption={"players-inventory.label-"..playerdata.role.."-badge"}}
        else
            header.add{type="label", name="role", caption={"players-inventory.label-undecided-badge"}}
        end
    end

    header.add{
        type="label", name="warnings", caption={"players-inventory.label-warnings-badge", warnings},
        visible=(warnings > 0)
    }

    header.add{
        type="label", name="muted", caption={"players-inventory.label-muted-badge"},
        visible=(tab_index ~= 4 and muted)
    }

    header.add{
        type="label", name="banned", caption={"players-inventory.label-banned-badge"},
        visible=(tab_index ~= 5 and banned)
    }
    
    if tab_index ~= 1 and tab_index ~= 2 and tab_index ~= 5 then
        if target_player.connected then
            header.add{type="label", name="connection", caption={"players-inventory.label-online-badge"}}
        else
            header.add{type="label", name="connection", caption={"players-inventory.label-offline-badge"}}
        end
    end
    
    local spacer = header.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true

    header.add{
        type = "sprite-button",
        name = "players_inventory_follow_button",
        sprite = "utility/search_white",
        hovered_sprite = "utility/search_black",
        clicked_sprite = "utility/search_black",
        tooltip = {"players-inventory.tooltip-follow"},
        style = "frame_action_button",
        visible = target_player.connected,
        tags = {player_index=target_player.index}
    }

    do 
        local sprite, altered_sprite, tooltip

        if PlayersInventory.is_favorite(self_player.index, target_player.index) then
            sprite = "players_inventory_unfavorite_white"
            altered_sprite = "players_inventory_unfavorite_black"
            tooltip = {"players-inventory.tooltip-unfavorite"}
        else
            sprite = "players_inventory_favorite_white"
            altered_sprite = "players_inventory_favorite_black"
            tooltip = {"players-inventory.tooltip-favorite"}
        end

        header.add{
            type = "sprite-button",
            name = "players_inventory_favorite_button",
            sprite = sprite,
            hovered_sprite = altered_sprite,
            clicked_sprite = altered_sprite,
            tooltip = tooltip,
            style = "frame_action_button",
            tags = {player_index=target_player.index}
        }
    end

    if self_player.admin then
        local line = header.add{type="line", direction="vertical", visible=self_player.admin}
        line.style.left_margin = 5
        line.style.right_margin = 5
        line.style.height = 25

        header.add{
            type = "sprite-button",
            name = "players_inventory_warn_button",
            sprite = "players_inventory_warning_white",
            hovered_sprite = "players_inventory_warning_black",
            clicked_sprite = "players_inventory_warning_black",
            tooltip = {"players-inventory.tooltip-warn"},
            style = "frame_action_button",
            tags = {player_index=target_player.index, action="warn"}
        }

        do
            local sprite, altered_sprite, tooltip

            if muted then
                sprite = "players_inventory_unmute_white"
                altered_sprite = "players_inventory_unmute_black"
                tooltip = {"players-inventory.tooltip-unmute"}
            else
                sprite = "players_inventory_mute_white"
                altered_sprite = "players_inventory_mute_black"
                tooltip = {"players-inventory.tooltip-mute"}
            end

            header.add{
                type = "sprite-button",
                name = "players_inventory_mute_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = {player_index=target_player.index, action="mute"}
            }
        end

        if target_player.connected then
            header.add{
                type = "sprite-button",
                name = "players_inventory_kick_button",
                sprite = "players_inventory_kick_white",
                hovered_sprite = "players_inventory_kick_black",
                clicked_sprite = "players_inventory_kick_black",
                tooltip = {"players-inventory.tooltip-kick"},
                style = "frame_action_button",
                tags = {player_index=target_player.index, action="kick"}
            }
        end

        do
            local sprite, altered_sprite, tooltip

            if banned then
                sprite = "players_inventory_unban_white"
                altered_sprite = "players_inventory_unban_black"
                tooltip = {"players-inventory.tooltip-unban"}
            else
                sprite = "players_inventory_ban_white"
                altered_sprite = "players_inventory_ban_black"
                tooltip = {"players-inventory.tooltip-ban"}
            end

            header.add{
                type = "sprite-button",
                name = "players_inventory_ban_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = {player_index=target_player.index, action="ban"}
            }
        end
    end


    -- Content --

    local content = panel.add{type="flow", name="content", direction="vertical"}
    content.style.top_margin = 5
    content.visible = false

    content.add{type="line", direction="horizontal"}

    local inventories = content.add{type="flow", name="inventories", direction="vertical"}
    inventories.style.horizontally_stretchable = true
    inventories.style.horizontal_align = "center"

    local main_inventory = inventories.add{type="flow", name="main", direction="vertical"}
    main_inventory.style.top_margin = 12
    main_inventory.add{type="label", caption={"players-inventory.label-main-inventory"}, style="heading_2_label"}
    main_inventory.add{type="table", name="grid", column_count=10, tags={counter=1}}

    local ammunition_inventory = inventories.add{type="flow", name="ammunition", direction="vertical"}
    ammunition_inventory.style.top_margin = 12
    ammunition_inventory.add{type="label", caption={"players-inventory.label-ammunition-inventory"}, style="heading_2_label"}
    ammunition_inventory.add{type="table", name="grid", column_count=10, tags={counter=1}}

    local trash_inventory = inventories.add{type="flow", name="trash", direction="vertical"}
    trash_inventory.style.top_margin = 12
    trash_inventory.add{type="label", caption={"players-inventory.label-trash-inventory"}, style="heading_2_label"}
    trash_inventory.add{type="table", name="grid", column_count=10, tags={counter=1}}

    line = content.add{type="line", direction="horizontal"}
    line.style.top_margin = 12


    -- Buttons --

    local buttons = content.add{type="flow", name="buttons", direction="horizontal"}
    buttons.style.padding = 8

    spacer = buttons.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true

    buttons.add{
        type = "button",
        name = "players_inventory_take_selected_button",
        caption = {"players-inventory.caption-take"},
        enabled = false,
        tags = {player_index=target_player.index}
    }
end


-- Inventories --

function PlayersInventory.fill_inventories_grids(inventories, self_player, target_player)
    PlayersInventory.fill_common_inventory_grid(
        inventories.main,
        self_player,
        target_player.get_inventory(defines.inventory.character_main)
    )
    PlayersInventory.fill_common_inventory_grid(
        inventories.trash,
        self_player,
        target_player.get_inventory(defines.inventory.character_trash)
    )
    PlayersInventory.fill_ammunition_inventory_grid(inventories.ammunition.grid, self_player, target_player)
end

function PlayersInventory.fill_common_inventory_grid(parent, self_player, inventory)
    if not inventory or inventory.get_item_count() == 0 then
        parent.visible = false
        return
    end

    local grid = parent.grid
    grid.clear()

    local content = inventory.get_contents()
    local player_index = inventory.player_owner.index

    for item_name, amount in pairs(content) do
        local tags = {
            player_index = player_index,
            inventory_type = parent.name,
            item_name = item_name
        }
        PlayersInventory.build_inventory_button{
            grid=grid, sprite="item/"..item_name, tags=tags, amount=amount, admin=self_player.admin
        }
    end

    local cells_count = #grid.children
    
    if cells_count > 0 then
        if cells_count % 10 > 0 then
            for _ = 1, 10 - cells_count % 10 do
                PlayersInventory.build_inventory_button{grid=grid}
            end
        end
    else
        for _ = 1, 10 do
            PlayersInventory.build_inventory_button{grid=grid}
        end
    end
end

function PlayersInventory.fill_ammunition_inventory_grid(grid, self_player, target_player)
    local armor_inventory = target_player.get_inventory(defines.inventory.character_armor)
    local guns_inventory = target_player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = target_player.get_inventory(defines.inventory.character_ammo)

    grid.clear()


    -- Armor --

    if armor_inventory and not armor_inventory.is_empty() then
        local armor_name = armor_inventory[1].name
        local tags = {
            player_index = armor_inventory.player_owner.index,
            inventory_type = "armor",
            item_name = armor_name
        }

        PlayersInventory.build_inventory_button{
            grid=grid, sprite="item/"..armor_name, tags=tags, admin=self_player.admin, armor=true
        }
    else
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_armor"}
    end


    -- Guns --

    if guns_inventory then
        for gun_index = 1, #guns_inventory do 
            local item = guns_inventory[gun_index]

            if item.valid_for_read then
                local tags = {
                    player_index = guns_inventory.player_owner.index,
                    inventory_type = "guns",
                    item_name = item.name
                }

                PlayersInventory.build_inventory_button{
                    grid=grid, sprite="item/"..item.name, tags=tags, admin=self_player.admin
                }
            else
                PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_gun"}
            end
        end
    else
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_gun"}
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_gun"}
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_gun"}
    end


    -- Fillers --

    for _ = 1, 7 do
        local filler = grid.add{type="empty-widget"}
        filler.style.width = 40
    end


    -- Ammo --

    if ammo_inventory then
        local player_index = ammo_inventory.player_owner.index

        for ammo_index = 1, #ammo_inventory do
            local item = ammo_inventory[ammo_index]

            if item.valid_for_read then
                local tags = {
                    player_index = player_index,
                    inventory_type = "ammo",
                    item_name = item.name
                }

                PlayersInventory.build_inventory_button{
                    grid=grid, sprite="item/"..item.name, tags=tags, amount=item.count, admin=self_player.admin
                }
            else
                PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_ammo"}
            end
        end
    else
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_ammo"}
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_ammo"}
        PlayersInventory.build_inventory_button{grid=grid, sprite="utility/slot_icon_ammo"}
    end
end

function PlayersInventory.build_inventory_button(params)
    -- INFO: It's very slow then set tooltip like `button.tooltip = str` against `add{tooltip=str}`

    local tooltip

    if params.admin then
        tooltip = {"players-inventory.tooltip-inventory-button"}
    end

    local button = params.grid.add{
        type = "sprite-button",
        name = "players_inventory_take_item_button_" .. params.grid.tags.counter,
        sprite = params.sprite,
        tooltip = tooltip,
        ignored_by_interaction = (not params.tags or not params.admin and params.armor),
        tags = params.tags,
        style = "inventory_slot"
    }

    if params.amount then
        button.number = params.amount
    end

    tags = {counter=(params.grid.tags.counter + 1)}
    params.grid.tags = tags
end


-- Punishments --

function PlayersInventory.build_accept_prompt_window(self_player, tags)
    local players_data = PlayersInventory.players_data[self_player.index]

    if players_data.accept_prompt_window then
        return
    end

    local target_player = game.players[tags.player_index]
    local window = self_player.gui.screen.add{
        type="frame", name="players_inventory_accept_prompt_window", direction="vertical"
    }

    players_data.accept_prompt_window = window


    -- Header --

    local titlebar = window.add{type="flow", direction="horizontal"}
    titlebar.drag_target = window

    titlebar.add{
        type = "label",
        caption = {"players-inventory.caption-action", {"players-inventory.tooltip-"..tags.action}, target_player.name},
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
        name = "players_inventory_close_accept_prompt_window_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "frame_action_button"
    }


    -- Reason --

    window.add{type="label", caption={"players-inventory.caption-reason"}, style="inventory_label"}

    local reason_textbox = window.add{type="text-box", name="players_inventory_reason_textbox"}
    reason_textbox.style.width = 450
    reason_textbox.style.height = 100

    local player_warnings = global.players_inventory_warnings[target_player.index] or 0

    if tags.action == "warn" then
        local warn_info = window.add{
            type="label", caption={"players-inventory.label-warnings-info", player_warnings}
        }
        warn_info.style.font_color = {0.6 ,0.6, 0.6, 1}
    end

    
    -- Buttons --

    local buttons = window.add{type="flow", direction="horizontal"}
    buttons.style.horizontally_stretchable = true
    buttons.style.top_margin = 5
    buttons.style.horizontal_align = "right"

    buttons.add{
        type = "button",
        name = "players_inventory_accept_punishment_button",
        caption = {"players-inventory.tooltip-"..tags.action},
        tags = tags
    }
    buttons.add{
        type = "button",
        name = "players_inventory_cancel_punishment_button",
        caption = {"players-inventory.caption-cancel"}
    }


    -- 

    reason_textbox.focus()
    window.force_auto_center()
end

function PlayersInventory.warn_player(self_index, target_player, reason)
    local warnings_count = PlayersInventory.warn(target_player, reason)
    local tabs = PlayersInventory.players_data[self_index].window.players_inventory_tabs
    local panel = tabs.tabs[tabs.selected_tab_index].content.players.list[target_player.name]

    panel.header.warnings.caption = {"players-inventory.label-warnings-badge", warnings_count}
    panel.header.warnings.visible = true
end

function PlayersInventory.kick_player(self_index, target_player, reason)
    game.kick_player(target_player, reason)

    local tabs = PlayersInventory.players_data[self_index].window.players_inventory_tabs
    
    if tabs.selected_tab_index == 1 then
        if PlayersInventory.players_data[self_index].selected then
            PlayersInventory.players_data[self_index].selected[target_player.name] = nil
        end

        local tab_content = tabs.tabs[tabs.selected_tab_index].content
        tab_content.players.list[target_player.name].destroy()
        
        if #tab_content.players.list.children > 0 then
            tab_content.players.count.caption = {
                "players-inventory.caption-count", #tab_content.players.list.children
            }
        else
            tab_content.players.visible = false
            tab_content.placeholder.visible = true
        end
    else
        local header = tabs.tabs[tabs.selected_tab_index].content.players.list[target_player.name].header

        if header.connection.visible then
            header.connection.caption = {"players-inventory.label-offline-badge"}
        end

        header.players_inventory_ban_button.sprite = "utility/reset_white"
        header.players_inventory_ban_button.hovered_sprite = "utility/reset"
        header.players_inventory_ban_button.clicked_sprite = "utility/reset"
        header.players_inventory_ban_button.tooltip = {"players-inventory.tooltip-unban"}
    end
end

function PlayersInventory.ban_player(self_index, target_player, reason)
    PlayersInventory.ban(target_player, reason)

    local tabs = PlayersInventory.players_data[self_index].window.players_inventory_tabs
    
    if tabs.selected_tab_index == 1 then
        if PlayersInventory.players_data[self_index].selected then
            PlayersInventory.players_data[self_index].selected[target_player.name] = nil
        end

        local tab_content = tabs.tabs[tabs.selected_tab_index].content
        tab_content.players.list[target_player.name].destroy()
        
        if #tab_content.players.list.children > 0 then
            tab_content.players.count.caption = {
                "players-inventory.caption-count", #tab_content.players.list.children
            }
        else
            tab_content.players.visible = false
            tab_content.placeholder.visible = true
        end
    else
        local header = tabs.tabs[tabs.selected_tab_index].content.players.list[target_player.name].header

        if header.connection and header.connection.visible then
            header.connection.caption = {"players-inventory.label-offline-badge"}
        end

        header.banned.visible = true

        header.players_inventory_ban_button.sprite = "players_inventory_unban_white"
        header.players_inventory_ban_button.hovered_sprite = "players_inventory_unban_black"
        header.players_inventory_ban_button.clicked_sprite = "players_inventory_unban_black"
        header.players_inventory_ban_button.tooltip = {"players-inventory.tooltip-unban"}
    end
end


-- Inventory utility function --

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

function PlayersInventory.take_items(self_player, button, one_stack)
    local inventory_type = PlayersInventory.inventories[button.tags.inventory_type]
    local from_player = game.players[button.tags.player_index]
    local from_inventory = from_player.get_inventory(inventory_type)
    local self_inventory = self_player.get_main_inventory()
    local selected = PlayersInventory.players_data[self_player.index].selected or {}
    local items

    if one_stack then
        items = from_inventory.find_item_stack(button.tags.item_name)
    else
        items = {name=button.tags.item_name, count=from_inventory.get_item_count(button.tags.item_name)}
    end

    local fits_all = PlayersInventory.move_items(from_inventory, self_inventory, items)

    if not fits_all then
        if button.tags.inventory_type ~= "armor" and button.tags.inventory_type ~= "guns" then
            button.number = from_inventory.get_item_count(button.tags.item_name)
        end

        self_player.play_sound{path="utility/cannot_build"}
        self_player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
    else
        self_player.play_sound{path="utility/inventory_move"}

        if button.tags.inventory_type == "main" or button.tags.inventory_type == "trash" then
            local count = from_inventory.get_item_count(button.tags.item_name)

            if count > 0 then
                button.number = count
                return
            end

            if button.style.name == "filter_inventory_slot" then
                selected[from_player.name] = selected[from_player.name] - 1
            end

            local fillers = {}

            for index = #button.parent.children, 1, -1 do
                local temp_button = button.parent.children[index]

                if temp_button.sprite ~= "" then
                    break
                end

                table.insert(fillers, temp_button)
            end

            if (#button.parent.children - #fillers) == 1 then
                button.parent.parent.visible = false
            else
                if #fillers == 9 then
                    for _, temp_button in pairs(fillers) do
                        temp_button.destroy()
                    end
                else
                    PlayersInventory.build_inventory_button{grid=button.parent}
                end

                button.destroy()
            end
        else
            if button.style.name == "filter_inventory_slot" then
                button.style = "inventory_slot"
                selected[from_player.name] = selected[from_player.name] - 1
            end

            if button.tags.inventory_type == "armor" then
                button.sprite = "utility/slot_icon_armor"
            elseif button.tags.inventory_type == "guns" then
                button.sprite = "utility/slot_icon_gun"
            elseif button.tags.inventory_type == "ammo" then
                button.sprite = "utility/slot_icon_ammo"
            end

            button.tooltip = nil
            button.ignored_by_interaction = true
        end

        local window = PlayersInventory.players_data[self_player.index].window
        local tab = window.players_inventory_tabs.tabs[window.players_inventory_tabs.selected_tab_index]
        local panel = tab.content.players.list[from_player.name]
        local take_selected_button = panel.content.buttons.players_inventory_take_selected_button
        take_selected_button.enabled = ((selected[from_player.name] or 0) > 0)
    end
end

function PlayersInventory.move_items(from_inventory, to_inventory, items)
    if not to_inventory.can_insert(items) then
        return false
    end

    local name = items.name
    local count = items.count
    local inserted = to_inventory.insert(items)

    if inserted < count then
        items.count = inserted
    end

    from_inventory.remove(items)

    if from_inventory.get_item_count(name) == 0 then
        return true
    end

    return (inserted == count)
end



-- Utility functions

function PlayersInventory.is_favorite(self_index, player_index)
    local favorites = global.players_inventory_filters[self_index].favorites

    if not favorites or #favorites == 0 then
        return false
    end

    for index = 1, #favorites do
        if favorites[index] == player_index then
            return true
        end
    end

    return false
end

function PlayersInventory.is_muted(player_index)
    for i = 1, #global.players_inventory_muted do
        if global.players_inventory_muted[i] == player_index then
            return true
        end
    end

    return false
end

function PlayersInventory.is_banned(player_index)
    for i = 1, #global.players_inventory_banned do
        if global.players_inventory_banned[i] == player_index then
            return true
        end
    end

    return false
end

function PlayersInventory.favorite(self_index, player_index)
    local favorites = global.players_inventory_filters[self_index].favorites
    table.insert(favorites, player_index)
    table.sort(favorites)
end

function PlayersInventory.unfavorite(self_index, player_index)
    PlayersInventory.remove(global.players_inventory_filters[self_index].favorites, player_index)
end

function PlayersInventory.warn(target_player, reason)
    local warnings_count = global.players_inventory_warnings[target_player.index] or 0
    warnings_count = warnings_count + 1

    global.players_inventory_warnings[target_player.index] = warnings_count

    if target_player.connected then
        local counts = {"первое", "второе", "третье"}
        target_player.print("Вам вынесено "..counts[warnings_count].." предупреждение:")
        target_player.print(reason)
    end

    return warnings_count
end

function PlayersInventory.mute(target_player)
    game.mute_player(target_player)
    table.insert(global.players_inventory_muted, target_player.index)
    table.sort(global.players_inventory_muted)
end

function PlayersInventory.unmute(target_player)
    game.unmute_player(target_player)
    PlayersInventory.remove(global.players_inventory_muted, target_player.index)
end

function PlayersInventory.ban(target_player, reason)
    game.ban_player(target_player, reason)
    table.insert(global.players_inventory_banned, target_player.index)
    table.sort(global.players_inventory_banned)
end

function PlayersInventory.unban(target_player)
    game.unban_player(target_player)
    PlayersInventory.remove(global.players_inventory_banned, target_player.index)
end

function PlayersInventory.remove(list, item)
    for index = 1, #list do
        if list[index] == item then
            table.remove(list, index)
            return
        end
    end
end






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

function PlayersInventory.on_init()
    global.players_inventory_warnings = global.players_inventory_warnings or {}
    global.players_inventory_muted = global.players_inventory_muted or {}
    global.players_inventory_banned = global.players_inventory_banned or {}
    global.players_inventory_filters = global.players_inventory_filters or {}
end

function PlayersInventory.on_configuration_changed(data)
    PlayersInventory.on_init()
    
    for _, player in pairs(game.players) do
        local player_filters = global.players_inventory_filters[player.index]

        player_filters = player_filters or {}
        player_filters.favorites = player_filters.favorites or {}
        player_filters.tab_index = player_filters.tab_index or 1
        player_filters.role_index = player_filters.role_index or 1

        PlayersInventory.create_toggle_button(player)
    end

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


-- Main window actions --

function PlayersInventory.on_toggle_players_inventory_window(event)
    local player_index = event.player_index
    local player_data = PlayersInventory.players_data[player_index]

    if player_data and player_data.accept_prompt_window then
        player_data.accept_prompt_window.bring_to_front()
        player_data.accept_prompt_window.players_inventory_reason_textbox.focus()
        return
    end

    if player_data and player_data.window then
        player_data.window.destroy()
        PlayersInventory.players_data[player_index] = nil

        if in_debug and PlayersInventory.debug then
            PlayersInventory.debug.destroy()
        end

        return
    end

    local window = PlayersInventory.build_players_inventory_window(game.players[player_index])

    PlayersInventory.settingup_and_fill_current_tab(player_index)

    window.force_auto_center()

    if in_debug then
        PlayersInventory.debug = game.players[player_index].gui.left.add{type="scroll-pane"}
        PlayersInventory.debug.style.width = 300
        PlayersInventory.debug.style.height = 600
    end
end

function PlayersInventory.on_close_players_inventory_window(event)
    local player_data = PlayersInventory.players_data[event.player_index]

    if player_data and player_data.accept_prompt_window then
        player_data.accept_prompt_window.bring_to_front()
        player_data.accept_prompt_window.players_inventory_reason_textbox.focus()
        return
    end

    if player_data and player_data.window then
        player_data.window.destroy()
        PlayersInventory.players_data[event.player_index] = nil

        if in_debug and PlayersInventory.debug then
            PlayersInventory.debug.destroy()
        end
    end
end


-- Filters actions --

function PlayersInventory.on_gui_selected_tab_changed(event)
    if not event.element.valid then
        return
    end

    if event.element.name ~= "players_inventory_tabs" then
        return
    end

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

    if event.element.name == "players_inventory_role" then
        local player_filters = global.players_inventory_filters[event.player_index]
        player_filters.role_index = event.element.selected_index
        PlayersInventory.settingup_and_fill_current_tab(event.player_index)
    end
end

function PlayersInventory.on_search(event)
    if not event.element.valid then
        return
    end

    if event.element.name == "players_inventory_search" then
        PlayersInventory.settingup_and_fill_current_tab(event.player_index, true)
    end
end

function PlayersInventory.on_clear_search(event)
    event.element.parent.players_inventory_search.text = ""
    event.element.parent.players_inventory_search.focus()
    event.element.parent.parent.players.visible = false
    event.element.parent.parent.placeholder.visible = true

    PlayersInventory.player_data[event.player_index].selected = nil
end

function PlayersInventory.on_expand_panel(event)
    local self_player = game.players[event.player_index]
    local player_data = PlayersInventory.players_data[event.player_index]
    local button = event.element
    local target_player = game.players[button.tags.player_index]
    local panel = button.parent.parent

    if panel.content.visible then
        button.sprite = "utility/expand"
        button.hovered_sprite = "utility/expand_dark"
        button.clicked_sprite = "utility/expand_dark"

        if player_data.selected then
            player_data.selected[panel.get_index_in_parent()] = nil
            panel.content.buttons.players_inventory_take_selected_button.enabled = false
        end
    else
        button.sprite = "utility/collapse"
        button.hovered_sprite = "utility/collapse_dark"
        button.clicked_sprite = "utility/collapse_dark"

        PlayersInventory.fill_inventories_grids(panel.content.inventories, self_player, target_player)
        panel.parent.scroll_to_element(panel)
    end

    panel.content.visible = not panel.content.visible
end


-- Common player actions

function PlayersInventory.on_follow_player(event)
    local character = game.players[event.element.tags.player_index].character

    if not character then
        return
    end

    PlayersInventory.players_data[event.player_index].window.destroy()
    game.players[event.player_index].zoom_to_world(character.position, 1.0, character)
end

function PlayersInventory.on_favorite_click(event)
    local element = event.element

    if PlayersInventory.is_favorite(event.player_index, element.tags.player_index) then
        PlayersInventory.unfavorite(event.player_index, element.tags.player_index)

        local window = PlayersInventory.players_data[event.player_index].window
        local tab_index = window.players_inventory_tabs.selected_tab_index

        if tab_index == 6 then
            target_player = game.players[element.tags.player_index]

            if PlayersInventory.players_data[event.player_index].selected then
                PlayersInventory.players_data[event.player_index].selected[target_player.name] = nil
            end

            local tab_content = window.players_inventory_tabs.tabs[tab_index].content
            tab_content.players.list[target_player.name].destroy()
            
            if #tab_content.players.list.children > 0 then
                tab_content.players.count.caption = {
                    "players-inventory.caption-count", #tab_content.players.list.children
                }
            else
                tab_content.players.visible = false
                tab_content.placeholder.visible = true
            end
        else
            element.sprite = "players_inventory_favorite_white"
            element.hovered_sprite = "players_inventory_favorite_black"
            element.clicked_sprite = "players_inventory_favorite_black"
            element.tooltip = {"players-inventory.tooltip-favorite"}
        end
    else
        PlayersInventory.favorite(event.player_index, element.tags.player_index)
        element.sprite = "players_inventory_unfavorite_white"
        element.hovered_sprite = "players_inventory_unfavorite_black"
        element.clicked_sprite = "players_inventory_unfavorite_black"
        element.tooltip = {"players-inventory.tooltip-unfavorite"}
    end
end


-- Punishment buttons actions -- 

function PlayersInventory.on_mute_click(event)
    local target_player = game.players[event.element.tags.player_index]
    local muted = global.players_inventory_muted
    local element = event.element
    local window = PlayersInventory.players_data[event.player_index].window
    local tabs = window.players_inventory_tabs
    local tab_content = window.players_inventory_tabs.tabs[tabs.selected_tab_index].content

    if PlayersInventory.is_muted(target_player.index) then
        PlayersInventory.unmute(target_player)

        if tabs.selected_tab_index == 4 then
            if PlayersInventory.players_data[event.player_index].selected then
                PlayersInventory.players_data[event.player_index].selected[target_player.name] = nil
            end

            tab_content.players.list[target_player.name].destroy()
            
            if #tab_content.players.list.children > 0 then
                tab_content.players.count.caption = {
                    "players-inventory.caption-count", #tab_content.players.list.children
                }
            else
                tab_content.players.visible = false
                tab_content.placeholder.visible = true
            end
        else
            tab_content.players.list[target_player.name].header.muted.visible = false

            element.sprite = "players_inventory_mute_white"
            element.hovered_sprite = "players_inventory_mute_black"
            element.clicked_sprite = "players_inventory_mute_black"
            element.tooltip = {"players-inventory.tooltip-mute"}
        end
    else
        PlayersInventory.mute(target_player)

        tab_content.players.list[target_player.name].header.muted.visible = true
        
        element.sprite = "players_inventory_unmute_white"
        element.hovered_sprite = "players_inventory_unmute_black"
        element.clicked_sprite = "players_inventory_unmute_black"
        element.tooltip = {"players-inventory.tooltip-unmute"}
    end
end

function PlayersInventory.on_ban_click(event)
    local element = event.element
    local target_player = game.players[element.tags.player_index]

    if PlayersInventory.is_banned(target_player.index) then
        PlayersInventory.unban(target_player)

        local window = PlayersInventory.players_data[event.player_index].window
        local tab_index = window.players_inventory_tabs.selected_tab_index

        if tab_index == 5 then
            if PlayersInventory.players_data[event.player_index].selected then
                PlayersInventory.players_data[event.player_index].selected[target_player.name] = nil
            end

            local tab_content = window.players_inventory_tabs.tabs[tab_index].content
            tab_content.players.list[target_player.name].destroy()
            
            if #tab_content.players.list.children > 0 then
                tab_content.players.count.caption = {
                    "players-inventory.caption-count", #tab_content.players.list.children
                }
            else
                tab_content.players.visible = false
                tab_content.placeholder.visible = true
            end
        else
            element.sprite = "players_inventory_ban_white"
            element.hovered_sprite = "players_inventory_ban_black"
            element.clicked_sprite = "players_inventory_ban_black"
            element.tooltip = {"players-inventory.tooltip-ban"}
        end
    else
        PlayersInventory.on_punish_player(event)
    end
end

function PlayersInventory.on_punish_player(event)
    local self_player = game.players[event.player_index]
    PlayersInventory.build_accept_prompt_window(self_player, event.element.tags)
end


-- Punishment window actions --

function PlayersInventory.on_punishment_accept(event)
    local tags = event.element.tags
    local target_player = game.players[tags.player_index]
    local player_data = PlayersInventory.players_data[event.player_index]
    local reason = player_data.accept_prompt_window.players_inventory_reason_textbox.text

    player_data.accept_prompt_window.destroy()
    player_data.accept_prompt_window = nil

    PlayersInventory[tags.action.."_player"](event.player_index, target_player, reason)
end

function PlayersInventory.on_punishment_closecancel(event)
    PlayersInventory.players_data[event.player_index].accept_prompt_window.destroy()
    PlayersInventory.players_data[event.player_index].accept_prompt_window = nil
end


-- Inventory items --

function PlayersInventory.on_inventory_item_click(event)
    local self_player = game.players[event.player_index]
    local button = event.element

    if event.button == 2 then
        if event.shift and self_player.admin then
            PlayersInventory.take_items(self_player, button, true)
        elseif event.control and self_player.admin then
            PlayersInventory.take_items(self_player, button)
        elseif button.tags.inventory_type == "armor" then
            local target_player = game.players[button.tags.player_index]
            self_player.print("[armor="..target_player.name.."]")
        end
    elseif event.button == 4 and self_player.admin then
        local target_player = game.players[button.tags.player_index]

        if not PlayersInventory.players_data[self_player.index].selected then
            PlayersInventory.players_data[self_player.index].selected = {}
        end

        local selected = PlayersInventory.players_data[self_player.index].selected
        selected[target_player.name] = selected[target_player.name] or 0

        if button.style.name == "inventory_slot" then
            button.style = "filter_inventory_slot"
            selected[target_player.name] = selected[target_player.name] + 1
        else
            button.style = "inventory_slot"
            selected[target_player.name] = selected[target_player.name] - 1
        end

        local tabs = PlayersInventory.players_data[self_player.index].window.players_inventory_tabs
        local panel = tabs.tabs[tabs.selected_tab_index].content.players.list[target_player.name]
        panel.content.buttons.players_inventory_take_selected_button.enabled = (selected[target_player.name] > 0)
    end
end

function PlayersInventory.on_take_selected_click(event)
    local from_player = game.players[event.element.tags.player_index]
    local main_inventory = from_player.get_inventory(defines.inventory.character_main)
    local armor_inventory = from_player.get_inventory(defines.inventory.character_armor)
    local guns_inventory = from_player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = from_player.get_inventory(defines.inventory.character_ammo)
    local trash_inventory = from_player.get_inventory(defines.inventory.character_trash)

    local to_player = game.players[event.player_index]
    local to_inventory = to_player.get_main_inventory()

    local window = game.players[event.player_index].gui.screen["players-inventory-window"]
    local panel = window["main-flow"].children[to_player.name]["content"]
    local take_button = panel["buttons"]["take-player-inventory-button"]
    local buttons = panel["inventories"]
    local main_buttons = buttons["main-inventory"]["grid"]
    local ammunition_buttons = buttons["ammunition-inventory"]["grid"]
    local trash_buttons = buttons["trash-inventory"]["grid"]


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
    global.selected_items_count[to_player.index][to_player.name] = 0

    -- TODO: Сделать перестройку только того инвентаря, из которого были изъяты предметы
    PlayersInventory.fill_inventories_grids(buttons, to_player, from_player)
end


-- GUI clicks dispatcher --

function PlayersInventory.on_gui_click(event)
    if not event.element.valid then
        return
    end

    local element_name = event.element.name

    if PlayersInventory.players_inventory_gui_click_events[element_name] then
        PlayersInventory.players_inventory_gui_click_events[element_name](event)
    elseif string.match(element_name, "players_inventory_take_item_button_") then
        PlayersInventory.on_inventory_item_click(event)
    end
end
-- local profiler = game.create_profiler()
-- profiler.stop()
-- local label = PlayersInventory.debug.add{type="label"}
-- label.caption = profiler

PlayersInventory.players_inventory_gui_click_events = {
    ["players_inventory_toggle_window"] = PlayersInventory.on_toggle_players_inventory_window,
    ["players_inventory_close_window_button"] = PlayersInventory.on_close_players_inventory_window,

    ["players_inventory_clear_search"] = PlayersInventory.on_clear_search,

    ["players_inventory_expand_button"] = PlayersInventory.on_expand_panel,

    ["players_inventory_follow_button"] = PlayersInventory.on_follow_player,
    ["players_inventory_favorite_button"] = PlayersInventory.on_favorite_click,

    ["players_inventory_warn_button"] = PlayersInventory.on_punish_player,
    ["players_inventory_mute_button"] = PlayersInventory.on_mute_click,
    ["players_inventory_kick_button"] = PlayersInventory.on_punish_player,
    ["players_inventory_ban_button"] = PlayersInventory.on_ban_click,

    ["players_inventory_accept_punishment_button"] = PlayersInventory.on_punishment_accept,
    ["players_inventory_cancel_punishment_button"] = PlayersInventory.on_punishment_closecancel,
    ["players_inventory_close_accept_prompt_window_button"] = PlayersInventory.on_punishment_closecancel,

    ["players_inventory_take_selected"] = PlayersInventory.on_take_selected_click
}


-- Utility functions ---------------------------------------------------------------------------------------------------

function print(str)
    game.print(str)
end

function pprint(obj, types)
    if type(obj) ~= "table" then
        print("ths not table")
    end

    if table_size(obj) == 0 then
        print("{}")
        return
    end

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
    [defines.events.on_player_demoted] = PlayersInventory.on_close_players_inventory_window,

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
