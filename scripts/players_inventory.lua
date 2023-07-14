-- Copyright (c) 2023 Ajick


local mod_gui = require("__core__/lualib/mod-gui")


-- Constans and variables ----------------------------------------------------------------------------------------------

local in_debug = false
local in_single = false

local PlayersInventory = {}
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
PlayersInventory.selected_counts = {}


-- Interface functions -------------------------------------------------------------------------------------------------

-- Toggle button --

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
    local player_filters = PlayersInventory.get_player_filters(player.index)

    if not player_filters then
        log("PlayersInventory.build_players_inventory_window: Filters is gone!")
        return
    end

    local window = player.gui.screen.add{type="frame", name="players_inventory_window", direction="vertical"}
    window.style.width = 900
    window.style.maximal_height = 950


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


    -- Tabed pane --

    local tabbed_pane = window.add{type="tabbed-pane", name="players_inventory_tabs"}
    tabbed_pane.style.top_margin = 10

    for _, tab_name in pairs{"online", "offline", "warnings", "muted", "banned", "favorites", "search"} do
        PlayersInventory.create_tab(tabbed_pane, tab_name, player_filters)
    end

    tabbed_pane.selected_tab_index = player_filters.tab_index


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

function PlayersInventory.get_current_tab(player_index)
    local player = game.players[player_index]

    if not player.gui.screen.players_inventory_window
    or not player.gui.screen.players_inventory_window.valid
    then
        log("PlayersInventory.get_current_tab: Window is gone!")
        return
    end

    local tabbed_pane = player.gui.screen.players_inventory_window.players_inventory_tabs

    return tabbed_pane.tabs[tabbed_pane.selected_tab_index].content
end


-- Current tab --

function PlayersInventory.settingup_and_fill_current_tab(player_index, in_search)
    local player_filters = PlayersInventory.get_player_filters(player_index)
    if not player_filters then
        PlayersInventory.emergency_exit(player_index, "settingup_and_fill_current_tab", "player_filters")
        return
    end

    local warnings = PlayersInventory.get("warnings")
    if not warnings then
        PlayersInventory.emergency_exit(player_index, "settingup_and_fill_current_tab", "warnings")
        return
    end

    local muted = PlayersInventory.get("muted")
    if not muted then
        PlayersInventory.emergency_exit(player_index, "settingup_and_fill_current_tab", "muted")
        return
    end

    local banned = PlayersInventory.get("banned")
    if not banned then
        PlayersInventory.emergency_exit(player_index, "settingup_and_fill_current_tab", "banned")
        return
    end

    local current_tab = PlayersInventory.get_current_tab(player_index)
    if not current_tab then
        PlayersInventory.emergency_exit(player_index, "settingup_and_fill_current_tab", "current_tab")
        return
    end

    if current_tab.name == "favorites" and #player_filters.favorites == 0
    or current_tab.name == "warnings" and  #warnings == 0
    or current_tab.name == "muted" and #muted == 0
    or current_tab.name == "banned" and table_size(banned) == 0
    then
        current_tab.players.visible = false
        current_tab.placeholder.visible = true
        return
    elseif current_tab.name == "search" then
        current_tab.filters.players_inventory_search.focus()

        if in_search and string.len(current_tab.filters.players_inventory_search.text) == 0 then
            current_tab.players.visible = false
            current_tab.placeholder.visible = true
            return
        elseif not in_search then
            current_tab.players.visible = (#current_tab.players.list.children > 0)
            current_tab.placeholder.visible = (#current_tab.players.list.children == 0)
            return
        end
    elseif current_tab.name == "online" or current_tab.name == "offline" then
        current_tab.filters.players_inventory_role.selected_index = player_filters.role_index
    end

    local players_list = current_tab.players.list

    players_list.clear()

    if current_tab.name == "online" or current_tab.name == "offline" then
        local online = (current_tab.name == "online")

        if current_tab.filters.players_inventory_role.selected_index > 1 then
            local role = PlayersInventory.roles[current_tab.filters.players_inventory_role.selected_index - 1]
            PlayersInventory.fill_players_list_by_role(players_list, online, role)
        else
            PlayersInventory.fill_players_list_by_role(players_list, online)
        end
    elseif current_tab.name == "warnings" then
        PlayersInventory.fill_players_list_by_warnings(players_list)
    elseif current_tab.name == "muted" then
        PlayersInventory.fill_players_list_by_filter(players_list, muted)
    elseif current_tab.name == "banned" then
        PlayersInventory.fill_players_list_by_banned(players_list, banned)
    elseif current_tab.name == "favorites" then
        PlayersInventory.fill_players_list_by_filter(players_list, player_filters.favorites)
    elseif current_tab.name == "search" then
        PlayersInventory.fill_players_list_by_name(
            players_list, string.lower(current_tab.filters.players_inventory_search.text)
        )
    end

    -- Я ЗАЕБАЛСЯ!!!!!!!!!!!!!!!!!
    if not players_list.valid then
        return
    end

    local count = #players_list.children

    if count > 0 then
        current_tab.players.count.caption = {"players-inventory.caption-count", count}
        current_tab.players.list.scroll_to_top()
    end

    current_tab.players.visible = (count > 0)
    current_tab.placeholder.visible = (count == 0)
end

function PlayersInventory.fill_players_list_by_role(players_list, online, role)
    for player_index, player in pairs(game.players) do
        if not players_list.valid then
            return
        end

        if player_index == players_list.player_index or player.connected ~= online then
            goto continue
        end

        if role then
            local playerdata = ServerMod.get_make_playerdata(player_index)

            if not playerdata.applied or playerdata.applied and playerdata.role ~= role then
                goto continue
            end
        end

        PlayersInventory.build_player_inventory_panel(players_list, player)

        ::continue::
    end
end

function PlayersInventory.fill_players_list_by_filter(players_list, filtered_players)
    for _, player_index in pairs(filtered_players) do
        if not players_list.valid then
            return
        end

        PlayersInventory.build_player_inventory_panel(players_list, game.players[player_index])
    end
end

function PlayersInventory.fill_players_list_by_warnings(players_list)
    local warnings = PlayersInventory.get("warnings")

    if not warnings then
        PlayersInventory.emergency_exit(players_list.player_index, "fill_players_list_by_warnings", "warnings")
        return
    end

    for player_index, _ in pairs(warnings) do
        if not players_list.valid then
            return
        end

        PlayersInventory.build_player_inventory_panel(players_list, game.players[player_index])
    end
end

function PlayersInventory.fill_players_list_by_banned(players_list, filtered_players)
    for player_index, _ in pairs(filtered_players) do
        if not players_list.valid then
            return
        end

        PlayersInventory.build_player_inventory_panel(players_list, game.players[player_index])
    end
end

function PlayersInventory.fill_players_list_by_name(players_list, name)
    for _, player in pairs(game.players) do
        if not players_list.valid then
            return
        end

        if player.index ~= players_list.player_index and string.match(string.lower(player.name), name) then
            PlayersInventory.build_player_inventory_panel(players_list, player)
        end
    end
end

function PlayersInventory.build_player_inventory_panel(players_list, target_player)
    local self_player = game.players[players_list.player_index]

    local current_tab = PlayersInventory.get_current_tab(self_player.index)
    if not current_tab then
        PlayersInventory.emergency_exit(self_player.index, "build_player_inventory_panel", "current_tab")
        return
    end

    local player_filters = PlayersInventory.get_player_filters(self_player.index)
    if not player_filters then
        PlayersInventory.emergency_exit(self_player.index, "build_player_inventory_panel", "player_filters")
        return
    end

    local warnings = PlayersInventory.get("warnings")
    if not warnings then
        PlayersInventory.emergency_exit(self_player.index, "build_player_inventory_panel", "warnings")
        return
    end
    warnings = warnings[target_player.index] or {}


    local muted = PlayersInventory.is_muted(target_player.index)
    local banned = PlayersInventory.is_banned(target_player.index)
    local tab_name = current_tab.name


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

    if (tab_name == "online" or tab_name == "offline") and player_filters.role_index == 1
    or tab_name ~= "online" and tab_name ~= "offline"
    then
        local playerdata = ServerMod.get_make_playerdata(target_player.index)

        if playerdata.applied then
            header.add{type="label", name="role", caption={"players-inventory.label-"..playerdata.role.."-badge"}}
        else
            header.add{type="label", name="role", caption={"players-inventory.label-undecided-badge"}}
        end
    end

    header.add{
        type="label", name="warnings", caption={"players-inventory.label-warnings-badge", #warnings},
        visible=(#warnings > 0), tooltip=PlayersInventory.get_warn_tooltip(warnings)
    }

    header.add{
        type="label", name="muted", caption={"players-inventory.label-muted-badge"},
        visible=(tab_name ~= "muted" and muted)
    }

    header.add{
        type="label", name="banned", caption={"players-inventory.label-banned-badge"},
        visible=banned,
        tooltip={"players-inventory.tooltip-reason", PlayersInventory.get_player_ban_reason(target_player.index)}
    }

    if tab_name ~= "online" and tab_name ~= "offline" and tab_name ~= "banned" then
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
        tags = {player_index=target_player.index},
        visible = target_player.connected
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

        do
            local sprite, altered_sprite, tooltip

            if target_player.permission_group.name == "Manager" then
                sprite = "players_inventory_demote_white"
                altered_sprite = "players_inventory_demote_black"
                tooltip = {"players-inventory.tooltip-demote"}
            else
                sprite = "players_inventory_promote_white"
                altered_sprite = "players_inventory_promote_black"
                tooltip = {"players-inventory.tooltip-promote"}
            end

            header.add{
                type = "sprite-button",
                name = "players_inventory_promotion_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = {player_index=target_player.index}
            }
        end

        line = header.add{type="line", direction="vertical", visible=self_player.admin}
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

        header.add{
            type = "sprite-button",
            name = "players_inventory_kick_button",
            sprite = "players_inventory_kick_white",
            hovered_sprite = "players_inventory_kick_black",
            clicked_sprite = "players_inventory_kick_black",
            tooltip = {"players-inventory.tooltip-kick"},
            style = "frame_action_button",
            tags = {player_index=target_player.index, action="kick"},
            visible = target_player.connected
        }

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

    local trash_inventory = inventories.add{type="flow", name="give", direction="vertical", visible=self_player.admin}
    trash_inventory.style.top_margin = 12
    trash_inventory.add{type="label", caption={"players-inventory.label-give"}, style="heading_2_label"}
    local give_button = trash_inventory.add{
        type = "sprite-button",
        name = "players_inventory_give_button",
        style = "inventory_slot",
        tags = {player_index=target_player.index}
    }
    give_button.style.width = 435
    give_button.style.height = 85

    line = content.add{type="line", direction="horizontal"}
    line.style.top_margin = 12

    local filler = content.add{type="empty-widget", visible=(not self_player.admin)}
    filler.style.height = 12


    -- Buttons --

    local buttons = content.add{type="flow", name="buttons", direction="horizontal", visible=self_player.admin}
    buttons.style.padding = 8

    spacer = buttons.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true

    buttons.add{
        type = "button",
        name = "players_inventory_take_selected_button",
        caption = {"players-inventory.caption-button-take-selected"},
        enabled = false,
        tags = {player_index=target_player.index}
    }
end

function PlayersInventory.remove_panel(current_tab, self_index, target_index)
    target_player = game.players[target_index]

    current_tab.players.list[target_player.name].destroy()
    
    if #current_tab.players.list.children > 0 then
        if PlayersInventory.selected_counts then
            local selected_counts = PlayersInventory.selected_counts[self_index]

            if selected_counts and selected_counts[target_player.name] then
                selected_counts[target_player.name] = nil
            end
        end

        current_tab.players.count.caption = {
            "players-inventory.caption-count", #current_tab.players.list.children
        }
    else
        if PlayersInventory.selected_counts then
            PlayersInventory.selected_counts[self_index] = nil
        end

        current_tab.players.visible = false
        current_tab.placeholder.visible = true
    end
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
    if not inventory or inventory.is_empty() then
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
        local show_armor = (armor_name ~= "light-armor" and armor_name ~= "heavy-armor")

        local tags = {
            player_index = armor_inventory.player_owner.index,
            inventory_type = "armor",
            item_name = armor_name,
            show_armor = show_armor
        }

        PlayersInventory.build_inventory_button{
            grid=grid, sprite="item/"..armor_name, tags=tags, admin=self_player.admin
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
    -- INFO: It's very slow when set tooltip like `button.tooltip = str` against `add{tooltip=str}`

    local tooltip

    if params.admin and params.tags then
        if params.tags.inventory_type == "armor" then
            if params.tags.show_armor then
                tooltip = {
                    "",
                    {"players-inventory.tooltip-button-armor-show-only"},
                    "\n",
                    {"players-inventory.tooltip-button-armor"}
                }
            else
                tooltip = {"players-inventory.tooltip-button-armor"}
            end
        elseif params.tags.inventory_type == "guns" then
            tooltip = {"players-inventory.tooltip-button-weapon"}
        elseif params.tags.inventory_type == "ammo" then
            tooltip = {"players-inventory.tooltip-button-ammo"}
        else
            tooltip = {"players-inventory.tooltip-button-items"}
        end
    elseif params.tags and params.tags.show_armor then
        tooltip = {"players-inventory.tooltip-button-armor-show-only"}
    end

    local button = params.grid.add{
        type = "sprite-button",
        name = "players_inventory_take_item_button_" .. params.grid.tags.counter,
        sprite = params.sprite,
        tooltip = tooltip,
        ignored_by_interaction = (not params.tags or not params.admin and not params.tags.show_armor),
        tags = params.tags,
        style = "inventory_slot"
    }

    if params.amount then
        button.number = params.amount
    end

    local tags = {counter=(params.grid.tags.counter + 1)}
    params.grid.tags = tags
end


-- Punishments --

function PlayersInventory.build_accept_prompt_window(self_player, tags)
    if self_player.gui.screen.players_inventory_accept_prompt_window then
        self_player.gui.screen.players_inventory_accept_prompt_window.destroy()
    end


    local target_player = game.players[tags.player_index]
    local window = self_player.gui.screen.add{
        type="frame", name="players_inventory_accept_prompt_window", direction="vertical"
    }


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

    local warnings = PlayersInventory.get_player_warnings(target_player.index)

    if not warnings then
        PlayersInventory.emergency_exit(self_player.index, "build_accept_prompt_window", "warnings")
        return
    end

    local tooltip

    if #warnings > 0 then
        tooltip = PlayersInventory.get_warn_tooltip(warnings)
    end

    if tags.action == "warn" then
        local warn_info = window.add{
            type = "label",
            caption = {"players-inventory.label-warnings-info", #warnings},
            tooltip = tooltip
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
    local warnings = PlayersInventory.warn(target_player, reason)

    if not warnings then
        PlayersInventory.emergency_exit(self_index, "warn_player", "warnings")
        return
    end

    local current_tab = PlayersInventory.get_current_tab(self_index)

    if not current_tab then
        PlayersInventory.emergency_exit(self_index, "warn_player", "current_tab")
        return
    end

    local panel = current_tab.players.list[target_player.name]

    panel.header.warnings.caption = {"players-inventory.label-warnings-badge", #warnings}
    panel.header.warnings.tooltip = PlayersInventory.get_warn_tooltip(warnings)
    panel.header.warnings.visible = true
end

function PlayersInventory.kick_player(self_index, target_player, reason)
    game.kick_player(target_player, reason)

    local current_tab = PlayersInventory.get_current_tab(self_index)

    if not current_tab then
        PlayersInventory.emergency_exit(self_index, "kick_player", "current_tab")
        return
    end
    
    if current_tab.name == "online" then
        PlayersInventory.remove_panel(current_tab, self_index, target_player.index)
    else
        local header = current_tab.players.list[target_player.name].header

        if header.connection.visible then
            header.connection.caption = {"players-inventory.label-offline-badge"}
        end

        header.players_inventory_follow_button.visible = false
        header.players_inventory_kick_button.visible = false
    end
end

function PlayersInventory.ban_player(self_index, target_player, reason)
    PlayersInventory.ban(target_player, reason)

    local current_tab = PlayersInventory.get_current_tab(self_index)

    if not current_tab then
        PlayersInventory.emergency_exit(self_index, "ban_player", "current_tab")
        return
    end
    
    if current_tab.name == "online" then
        PlayersInventory.remove_panel(current_tab, self_index, target_player.index)
    else
        local header = current_tab.players.list[target_player.name].header

        if header.connection and header.connection.visible then
            header.connection.caption = {"players-inventory.label-offline-badge"}
        end

        header.banned.visible = true
        header.banned.tooltip = reason

        header.players_inventory_follow_button.visible = false
        header.players_inventory_kick_button.visible = false

        header.players_inventory_ban_button.sprite = "players_inventory_unban_white"
        header.players_inventory_ban_button.hovered_sprite = "players_inventory_unban_black"
        header.players_inventory_ban_button.clicked_sprite = "players_inventory_unban_black"
        header.players_inventory_ban_button.tooltip = {"players-inventory.tooltip-unban"}
    end
end


-- Inventory utility function --

function PlayersInventory.take_common_inventory(from_inventory, to_inventory, parent)
    if not from_inventory then
        return true
    end

    local self_player = to_inventory.player_owner
    local fits_all = true

    for _, button in pairs(parent.grid.children) do
        if not button.valid then
            return
        end

        if button.style.name ~= "filter_inventory_slot" then
            goto continue
        end

        fits_all = PlayersInventory.move_items(from_inventory, to_inventory, button.tags.item_name)

        if fits_all then
            button.destroy()
            PlayersInventory.decrise_selected(self_player.index, from_inventory.player_owner.index)
        else
            button.number = from_inventory.get_item_count(button.tags.item_name)
            break
        end

        ::continue::
    end

    local buttons, fillers = {}, {}

    for _, button in pairs(parent.grid.children) do
        if button.sprite ~= "" then
            table.insert(buttons, button)
        else
            table.insert(fillers, button)
        end    
    end

    if #buttons > 0 then
        local fillers_count = 10 - #buttons % 10

        if fillers_count == 0 or fillers_count == 10 then
            for _, filler in pairs(fillers) do
                filler.destroy()
            end
        elseif #fillers < fillers_count then
            local index = fillers_count - #fillers

            while index > 0 do
                PlayersInventory.build_inventory_button{grid=parent.grid}
                index = index - 1
            end
        elseif #fillers > fillers_count then
            local index = #fillers

            while index > fillers_count do
                fillers[index].destroy()
                index = index - 1
            end
        end
    else
        parent.visible = false
    end

    return fits_all
end

function PlayersInventory.take_amunition_inventories(from_inventories, to_inventory, parent)
    local to_player = to_inventory.player_owner
    local from_player = from_inventories[1].player_owner
    

    -- Armor ----------------------------------------------------------------------------------------------------------

    if parent.grid.children[1].style.name == "filter_inventory_slot" then
        local item_name = parent.grid.children[1].tags.item_name

        if not PlayersInventory.move_items(from_inventories[1], to_inventory, item_name) then
            return
        end

        PlayersInventory.decrise_selected(to_player.index, from_player.index)
        parent.grid.children[1].style = "inventory_slot"
        parent.grid.children[1].sprite = "utility/slot_icon_armor"
        parent.grid.children[1].ignored_by_interaction = true
    end


    -- Guns -----------------------------------------------------------------------------------------------------------

    for index = 2, 4 do
        if parent.grid.children[index].style.name == "filter_inventory_slot" then
            local item_name = parent.grid.children[index].tags.item_name

            if not PlayersInventory.move_items(from_inventories[2], to_inventory, item_name) then
                return
            end

            PlayersInventory.decrise_selected(to_player.index, from_player.index)
            parent.grid.children[index].style = "inventory_slot"
            parent.grid.children[index].sprite = "utility/slot_icon_gun"
            parent.grid.children[index].ignored_by_interaction = true
        end
    end


    -- Ammo -----------------------------------------------------------------------------------------------------------

    for index = 12, 14 do
        if parent.grid.children[index].style.name == "filter_inventory_slot" then
            local item_name = parent.grid.children[index].tags.item_name

            if not PlayersInventory.move_items(from_inventories[3], to_inventory, item_name) then
                return
            end

            PlayersInventory.decrise_selected(to_player.index, from_player.index)
            parent.grid.children[index].style = "inventory_slot"
            parent.grid.children[index].sprite = "utility/slot_icon_ammo"
            parent.grid.children[index].number = nil
            parent.grid.children[index].ignored_by_interaction = true
        end
    end
end

function PlayersInventory.take_items(self_player, button, one_stack)
    local inventory_type = PlayersInventory.inventories[button.tags.inventory_type]
    local from_player = game.players[button.tags.player_index]
    local from_inventory = from_player.get_inventory(inventory_type)
    local self_inventory = self_player.get_main_inventory()
    local fits_all = PlayersInventory.move_items(from_inventory, self_inventory, button.tags.item_name, one_stack)

    if not fits_all then
        if button.tags.inventory_type ~= "armor" and button.tags.inventory_type ~= "guns" then
            button.number = from_inventory.get_item_count(button.tags.item_name)
        end
    else
        self_player.play_sound{path="utility/inventory_move"}

        if button.tags.inventory_type == "main" or button.tags.inventory_type == "trash" then
            local count = from_inventory.get_item_count(button.tags.item_name)

            if count > 0 then
                button.number = count
                return
            end

            if button.style.name == "filter_inventory_slot" then
                PlayersInventory.decrise_selected(self_player.index, from_player.index)
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
                PlayersInventory.decrise_selected(self_player.index, from_player.index)
                button.style = "inventory_slot"
            end

            if button.tags.inventory_type == "armor" then
                button.sprite = "utility/slot_icon_armor"
            elseif button.tags.inventory_type == "guns" then
                button.sprite = "utility/slot_icon_gun"
            elseif button.tags.inventory_type == "ammo" then
                button.sprite = "utility/slot_icon_ammo"
                button.number = nil
            end

            button.tooltip = nil
            button.ignored_by_interaction = true
        end
    end
end

function PlayersInventory.give_items(self_player, to_player)
    local current_tab = PlayersInventory.get_current_tab(self_player.index)

    if not current_tab then
        PlayersInventory.emergency_exit(self_player.index, "give_items", "current_tab")
        return
    end

    local to_inventory = to_player.get_main_inventory()
    local stack = self_player.cursor_stack

    if not to_inventory.can_insert(stack) then
        self_player.play_sound{path="utility/cannot_build"}
        self_player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
        return
    end

    local item_name = stack.name
    local count = stack.count
    local inserted = to_inventory.insert(stack)

    if inserted < count then
        stack.count = count - inserted

        if not to_inventory.can_insert(stack) then
            self_player.play_sound{path="utility/cannot_build"}
            self_player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
        else
            inserted = inserted + to_inventory.insert(stack)
            stack.count = count - inserted
        end
    end

    if inserted == count then
        stack.clear()
        self_player.clear_cursor()
        self_player.play_sound{path="utility/inventory_move"}
    end

    local grid = current_tab.players.list[to_player.name].content.inventories.main.grid

    local new = true
    local filler_index = 0

    for index, button in pairs(grid.children) do
        if button.tags.item_name == item_name then
            button.number = button.number + inserted
            new = false
        elseif button.sprite == "" then
            filler_index = index
            break
        end
    end

    if new then
        local tags = {
            player_index = to_player.index,
            inventory_type = "main",
            item_name = item_name
        }

        PlayersInventory.build_inventory_button{
            grid=grid, sprite="item/"..item_name, tags=tags, amount=count, admin=self_player.admin
        }

        if filler_index > 0 then
            grid.swap_children(#grid.children, filler_index)
            grid.children[#grid.children].destroy()
        else
            for _ = 1, 9 do
                PlayersInventory.build_inventory_button{grid=grid}
            end

            grid.parent.visible = true
        end
    end
end

function PlayersInventory.move_items(from_inventory, to_inventory, item_name, one_stack)
    local items

    if one_stack then
        items, _ = from_inventory.find_item_stack(item_name)
    else
        items = {name=item_name, count=from_inventory.get_item_count(item_name)}
    end

    if not items or items.count == 0 then
        to_inventory.player_owner.play_sound{path="utility/cannot_build"}
        to_inventory.player_owner.print({
            "players-inventory.message-no-items",
            from_inventory.player_owner.name,
            "[img=item."..item_name.."]",
            item_name
        })
        return true
    end

    if not to_inventory.can_insert(items) then
        to_inventory.player_owner.play_sound{path="utility/cannot_build"}
        to_inventory.player_owner.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
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

    if inserted < count then
        to_inventory.player_owner.play_sound{path="utility/cannot_build"}
        to_inventory.player_owner.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
    end

    return (inserted == count)
end



-- Utility functions

function PlayersInventory.get(name)
    if not global.players_inventory then
        log("PlayersInventory.get: global.players_inventory is gone.")
        return
    end

    if not global.players_inventory[name] then
        log("PlayersInventory.get: global.players_inventory."..name.." is gone.")
        return
    end

    return global.players_inventory[name]
end

function PlayersInventory.get_player_filters(player_index)
    local filters = PlayersInventory.get("filters")

    if not filters then
        log("PlayersInventory.get_player_filters: Filters is gone!")
        return
    end

    return filters[player_index]
end

function PlayersInventory.get_player_warnings(player_index)
    local warnings = PlayersInventory.get("warnings")

    if not warnings then
        log("PlayersInventory.get_player_warnings: Warnings is gone!")
        return
    end

    return warnings[player_index] or {}
end

function PlayersInventory.get_player_ban_reason(player_index)
    local banned = PlayersInventory.get("banned")

    if not banned then
        log("PlayersInventory.get_player_warnings: Warnings is gone!")
        return
    end

    return banned[player_index]
end

function PlayersInventory.is_favorite(self_index, target_index)
    local player_filters = PlayersInventory.get_player_filters(self_index)

    if not player_filters then
        log("PlayersInventory.is_favorite: player_filters is gone!")
        return false
    end

    if not player_filters.favorites then
        log("PlayersInventory.is_favorite: player_filters.favorites is gone!")
        return false
    end

    for _, player_index in pairs(player_filters.favorites) do
        if player_index == target_index then
            return true
        end
    end

    return false
end

function PlayersInventory.is_muted(target_index)
    local muted = PlayersInventory.get("muted")

    if not muted then
        log("PlayersInventory.is_muted: Mutes is gone!")
        return false
    end

    for _, player_index in pairs(muted) do
        if player_index == target_index then
            return true
        end
    end

    return false
end

function PlayersInventory.is_banned(player_index)
    local banned = PlayersInventory.get("banned")

    if not banned then
        log("PlayersInventory.is_banned: Bans is gone!")
        return
    end

    if banned[player_index] then
        return true
    end

    return false
end

function PlayersInventory.favorite(self_index, player_index)
    local player_filters = PlayersInventory.get_player_filters(self_index)

    if not player_filters then
        log("PlayersInventory.favorite: player_filters is gone!")
        return
    end

    if not player_filters.favorites then
        log("PlayersInventory.favorite: player_filters.favorites is gone!")
        return
    end

    table.insert(player_filters.favorites, player_index)
end

function PlayersInventory.unfavorite(self_index, target_index)
    local player_filters = PlayersInventory.get_player_filters(self_index)

    if not player_filters then
        log("PlayersInventory.unfavorite: player_filters is gone!")
        return
    end

    if not player_filters.favorites then
        log("PlayersInventory.unfavorite: player_filters.favorites is gone!")
        return
    end

    PlayersInventory.remove(player_filters.favorites, target_index)
end

function PlayersInventory.warn(target_player, reason)
    local warnings = PlayersInventory.get("warnings")

    if not warnings then
        log("PlayersInventory.warn: Warnings is gone!")
        return
    end

    if not warnings[target_player.index] then
        warnings[target_player.index] = {}
    end

    local player_warnings = warnings[target_player.index]
    table.insert(player_warnings, reason)

    game.print({"players-inventory.message-warning", target_player.name, #player_warnings, reason})

    return player_warnings
end

function PlayersInventory.mute(target_player)
    game.mute_player(target_player)

    local muted = PlayersInventory.get("muted")

    if not muted then
        log("PlayersInventory.mute: Mutes is gone!")
        return
    end

    table.insert(muted, target_player.index)
end

function PlayersInventory.unmute(target_player)
    game.unmute_player(target_player)

    local muted = PlayersInventory.get("muted")

    if not muted then
        log("PlayersInventory.unmute: Mutes is gone!")
        return
    end

    PlayersInventory.remove(muted, target_player.index)
end

function PlayersInventory.ban(target_player, reason)
    game.ban_player(target_player, reason)

    local banned = PlayersInventory.get("banned")

    if not banned then
        log("PlayersInventory.ban: Bans is gone!")
        return
    end

    banned[target_player.index] = reason
end

function PlayersInventory.unban(target_player)
    game.unban_player(target_player)

    local banned = PlayersInventory.get("banned")

    if not banned then
        log("PlayersInventory.unban: Bans is gone!")
        return
    end

    banned[target_player.index] = nil
end


function PlayersInventory.incrise_selected(self_index, target_index)
    local target_player = game.players[target_index]

    if not PlayersInventory.selected_counts then
        PlayersInventory.emergency_exit(self_index, "incrise_selected", "PlayersInventory.selected_counts")
        return
    end

    if not PlayersInventory.selected_counts[self_index] then
        PlayersInventory.selected_counts[self_index] = {}
    end

    local selected_counts = PlayersInventory.selected_counts[self_index]
    local selected_count = selected_counts[target_player.name] or 0
    selected_counts[target_player.name] = selected_count + 1

    local current_tab = PlayersInventory.get_current_tab(self_index)
    if not current_tab then
        PlayersInventory.emergency_exit(self_index, "incrise_selected", "current_tab")
        return
    end

    local buttons = current_tab.players.list[target_player.name].content.buttons
    buttons.players_inventory_take_selected_button.enabled = true
end

function PlayersInventory.decrise_selected(self_index, target_index)
    local target_player = game.players[target_index]

    if not PlayersInventory.selected_counts then
        PlayersInventory.emergency_exit(self_index, "decrise_selected", "PlayersInventory.selected_counts")
        return
    end

    if not PlayersInventory.selected_counts[self_index] then
        PlayersInventory.emergency_exit(self_index, "decrise_selected", "PlayersInventory.selected_counts[self_index]")
        return
    end

    local selected_counts = PlayersInventory.selected_counts[self_index]
    local selected_count = selected_counts[target_player.name] - 1
    selected_counts[target_player.name] = selected_count

    local current_tab = PlayersInventory.get_current_tab(self_index)
    if not current_tab then
        PlayersInventory.emergency_exit(self_index, "decrise_selected", "current_tab")
        return
    end

    local buttons = current_tab.players.list[target_player.name].content.buttons
    buttons.players_inventory_take_selected_button.enabled = (selected_count > 0)
end

function PlayersInventory.get_warn_tooltip(warnings)
    local tooltip = {"", {"players-inventory.tooltip-warnings"}}

    for index, warning in pairs(warnings) do
        table.insert(tooltip, "\n" .. index .. ". " .. warning)
    end

    return tooltip
end


function PlayersInventory.split_version(str)
    local start_index = 1, end_index, major, minor, build
    
    end_index = string.find(str, ".", start_index, true)
    major = tonumber(string.sub(str, start_index, end_index))

    start_index = end_index + 1
    end_index = string.find(str, ".", start_index, true)
    minor = tonumber(string.sub(str, start_index, end_index))

    start_index = end_index + 1
    end_index = string.find(str, ".", start_index, true)
    build = tonumber(string.sub(str, start_index, end_index))

    return major, minor, build
end

function PlayersInventory.remove(list, target_item)
    for index, item in pairs(list) do
        if item == target_item then
            list[index] = nil
            return
        end
    end
end

function PlayersInventory.emergency_exit(player_index, from_function, missed_name)
    local player = game.players[player_index]
    local main_window = player.gui.screen.players_inventory_window 
    local accept_window = player.gui.screen.players_inventory_accept_prompt_window

    if main_window and main_window.valid then
        main_window.destroy()
    end

    if accept_window
    and accept_window.valid
    then
        accept_window.destroy()
    end

    if PlayersInventory.selected_counts then
        PlayersInventory.selected_counts[player_index] = nil
    end

    log("PlayersInventory."..from_function..": Emergency exit! "..missed_name.." is gone!")
end



-- Events --------------------------------------------------------------------------------------------------------------

-- Configuration --

function PlayersInventory.on_init()
    global.players_inventory.warnings = {}
    global.players_inventory.muted = {}
    global.players_inventory.banned = {}
    global.players_inventory.filters = {}
end

function PlayersInventory.on_configuration_changed(data)
    if not data then
        return
    end

    if data.mod_changes
    and data.mod_changes["Fed1sServerMod"] then
        local major, minor, build = PlayersInventory.split_version(data.mod_changes["Fed1sServerMod"].old_version)

        if major <= 1 and minor <= 1 and build < 8 then
            global.players_inventory = {}
            global.players_inventory.filters = global.players_inventory_filters
            global.players_inventory.warnings = global.players_inventory_warnings
            global.players_inventory.muted = global.players_inventory_muted
            global.players_inventory.banned = global.players_inventory_banned
            
            global.players_inventory_filters = nil
            global.players_inventory_warnings = nil
            global.players_inventory_muted = nil
            global.players_inventory_banned = nil

            global.players_inventory.warnings[2] = {}
            table.insert(global.players_inventory.warnings[2], "МАЛО ПИЛ ВОДКИ НА ВЫХОДНЫХ!")
        end

        log({
            "",
            "Fed1sServerMod.PlayersInventory migrated to version ",
            data.mod_changes["Fed1sServerMod"].new_version,
            "."
        })
    end
end

function PlayersInventory.on_player_created(event)
    local filters = PlayersInventory.get("filters")

    if not filters then
        log("PlayersInventory.on_player_created: Filters is gone.")
        return
    end

    filters[event.player_index] = {favorites={}, tab_index=1, role_index=1}
    PlayersInventory.create_toggle_button(game.players[event.player_index])
end

function PlayersInventory.on_player_joined_game(event)
    local player = game.players[event.player_index]
    local screen = player.gui.screen

    if screen.players_inventory_accept_prompt_window then
        screen.players_inventory_accept_prompt_window.destroy()
    end

    if screen.players_inventory_window then
        screen.players_inventory_window.destroy()
    end
end


-- Main window actions --

function PlayersInventory.on_toggle_players_inventory_window(event)
    local player = game.players[event.player_index]
    local main_window = player.gui.screen.players_inventory_window
    local accept_window = player.gui.screen.players_inventory_accept_prompt_window

    if accept_window and accept_window.valid then
        accept_window.destroy()
    end

    if main_window and main_window.valid then
        PlayersInventory.selected_counts[player.index] = {}
        main_window.destroy()
        return
    end

    main_window = PlayersInventory.build_players_inventory_window(player)

    if not main_window then
        log("PlayersInventory.on_toggle_players_inventory_window: Window is gone!")
        return
    end

    PlayersInventory.settingup_and_fill_current_tab(player.index)

    if not main_window.valid then
        return
    end

    main_window.force_auto_center()
end

function PlayersInventory.on_close_players_inventory_window(event)
    local player = game.players[event.player_index]
    local main_window = player.gui.screen.players_inventory_window
    local accept_window = player.gui.screen.players_inventory_accept_prompt_window

    if accept_window and accept_window.valid then
        accept_window.destroy()
    end

    if main_window and main_window.valid then
        PlayersInventory.selected_counts[player.index] = {}
        main_window.destroy()
    end
end


-- Filters actions --

function PlayersInventory.on_gui_selected_tab_changed(event)
    local tabbed_pane = event.element

    if not tabbed_pane or not tabbed_pane.valid then
        return
    end

    if tabbed_pane.name ~= "players_inventory_tabs" then
        return
    end

    local player_filters = PlayersInventory.get_player_filters(event.player_index)

    if not player_filters then
        log("PlayersInventory.on_gui_selected_tab_changed: Filters is gone!")
        return
    end

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
    local roles = event.element

    if not roles or not roles.valid then
        return
    end

    if roles.name ~= "players_inventory_role" then
        return
    end

    local player_filters = PlayersInventory.get_player_filters(event.player_index)

    if not player_filters then
        log("PlayersInventory.on_change_filters: Filters is gone!")
        return
    end

    player_filters.role_index = roles.selected_index
    PlayersInventory.settingup_and_fill_current_tab(event.player_index)
end

function PlayersInventory.on_search(event)
    if not event.element or not event.element.valid then
        return
    end

    if event.element.name ~= "players_inventory_search" then
        return
    end

    PlayersInventory.settingup_and_fill_current_tab(event.player_index, true)
end

function PlayersInventory.on_clear_search(event)
    event.element.parent.players_inventory_search.text = ""
    event.element.parent.players_inventory_search.focus()
    event.element.parent.parent.players.visible = false
    event.element.parent.parent.placeholder.visible = true

    if PlayersInventory.selected_counts then
        PlayersInventory.selected_counts[event.player_index] = nil
    end
end

function PlayersInventory.on_toggle_expand_panel(event)
    local self_player = game.players[event.player_index]
    local button = event.element
    local target_player = game.players[button.tags.player_index]
    local panel = button.parent.parent

    if panel.content.visible then
        button.sprite = "utility/expand"
        button.hovered_sprite = "utility/expand_dark"
        button.clicked_sprite = "utility/expand_dark"

        panel.content.buttons.players_inventory_take_selected_button.enabled = false

        if PlayersInventory.selected_counts then
            PlayersInventory.selected_counts[event.player_index] = nil
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
    if not event.element or not event.element.valid or not event.element.tags then
        return
    end

    local player = game.players[event.player_index]
    local character = game.players[event.element.tags.player_index].character

    if not character then
        return
    end

    if player.gui.screen.players_inventory_window then
        player.gui.screen.players_inventory_window.destroy()
    end

    if PlayersInventory.selected_counts then
        PlayersInventory.selected_counts[event.player_index] = nil
    end

    game.players[event.player_index].zoom_to_world(character.position, 1.0, character)
end

function PlayersInventory.on_favorite_click(event)
    local element = event.element

    if not element.tags then
        return
    end

    if PlayersInventory.is_favorite(event.player_index, element.tags.player_index) then
        PlayersInventory.unfavorite(event.player_index, element.tags.player_index)

        local current_tab = PlayersInventory.get_current_tab(event.player_index)

        if current_tab.name == "favorites" and current_tab then
            PlayersInventory.remove_panel(current_tab, event.player_index, element.tags.player_index)
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


-- Promotion button actions --

function PlayersInventory.on_promotion_click(event)
    local element = event.element
    local target_player = game.players[element.tags.player_index]
    local current_tab = PlayersInventory.get_current_tab(event.player_index)
    local panel
    
    if current_tab then
        panel = current_tab.players.list[target_player.name]
    end

    if target_player.permission_group.name == "Manager" then
        target_player.permission_group = game.permissions.get_group("Default")

        element.sprite = "players_inventory_promote_white"
        element.hovered_sprite = "players_inventory_promote_black"
        element.clicked_sprite = "players_inventory_promote_black"
        element.tooltip = {"players-inventory.tooltip-promote"}
        
        if panel then
            panel.header.manager.visible = false
        end

        game.print({"players-inventory.message-demoted", target_player.name})
    else
        target_player.permission_group = game.permissions.get_group("Manager")

        element.sprite = "players_inventory_demote_white"
        element.hovered_sprite = "players_inventory_demote_black"
        element.clicked_sprite = "players_inventory_demote_black"
        element.tooltip = {"players-inventory.tooltip-demote"}
        
        if panel then
            panel.header.manager.visible = true
        end

        game.print({"players-inventory.message-promoted", target_player.name})
    end
end


-- Punishment buttons actions -- 

function PlayersInventory.on_mute_click(event)
    local element = event.element
    local target_player = game.players[element.tags.player_index]
    local current_tab = PlayersInventory.get_current_tab(event.player_index)

    if PlayersInventory.is_muted(target_player.index) then
        PlayersInventory.unmute(target_player)

        if current_tab.name == "muted" and current_tab then
            PlayersInventory.remove_panel(current_tab, event.player_index, target_player.index)
        else
            if current_tab then
                current_tab.players.list[target_player.name].header.muted.visible = false
            end

            element.sprite = "players_inventory_mute_white"
            element.hovered_sprite = "players_inventory_mute_black"
            element.clicked_sprite = "players_inventory_mute_black"
            element.tooltip = {"players-inventory.tooltip-mute"}
        end
    else
        PlayersInventory.mute(target_player)

        if current_tab then
            current_tab.players.list[target_player.name].header.muted.visible = true
        end
        
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

        local current_tab = PlayersInventory.get_current_tab(event.player_index)

        if current_tab.name == "banned" and current_tab then
            PlayersInventory.remove_panel(current_tab, event.player_index, target_player.index)
        else
            if current_tab then
                current_tab.players.list[target_player.name].header.banned.visible = false
            end

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
    local self_player = game.players[event.player_index]
    local window = self_player.gui.screen.players_inventory_accept_prompt_window
    local reason = ""

    if window then
        reason = window.players_inventory_reason_textbox.text
        window.destroy()
    end

    PlayersInventory[tags.action.."_player"](event.player_index, target_player, reason)
end

function PlayersInventory.on_punishment_closecancel(event)
    local self_player = game.players[event.player_index]
    local window = self_player.gui.screen.players_inventory_accept_prompt_window

    if window and window.valid then
        window.destroy()
    end
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
        elseif button.tags.inventory_type == "armor" and button.tags.show_armor then
            local target_player = game.players[button.tags.player_index]
            self_player.print("[armor="..target_player.name.."]")
        end
    elseif event.button == 4 and self_player.admin then
        local target_player = game.players[button.tags.player_index]

        if button.style.name == "inventory_slot" then
            button.style = "filter_inventory_slot"
            PlayersInventory.incrise_selected(self_player.index, button.tags.player_index)
        else
            button.style = "inventory_slot"
            PlayersInventory.decrise_selected(self_player.index, button.tags.player_index)
        end
    end
end

function PlayersInventory.on_give_button_click(event)
    local self_player = game.players[event.player_index]

    if self_player.is_cursor_empty() then
        return
    end

    if self_player.cursor_ghost then
        return
    end

    local to_player = game.players[event.element.tags.player_index]

    PlayersInventory.give_items(self_player, to_player)
end

function PlayersInventory.on_take_selected_click(event)
    local current_tab = PlayersInventory.get_current_tab(event.player_index)
    if not current_tab then
        log("PlayersInventory.on_take_selected_click: current_tab is gone!")
        return
    end

    local from_player = game.players[event.element.tags.player_index]

    local main_inventory = from_player.get_inventory(defines.inventory.character_main)
    local trash_inventory = from_player.get_inventory(defines.inventory.character_trash)
    local armor_inventory = from_player.get_inventory(defines.inventory.character_armor)
    local guns_inventory = from_player.get_inventory(defines.inventory.character_guns)
    local ammo_inventory = from_player.get_inventory(defines.inventory.character_ammo)

    local to_player = game.players[event.player_index]
    local to_inventory = to_player.get_main_inventory()

    local panel = current_tab.players.list[from_player.name]
    local main_parent = panel.content.inventories.main
    local ammunition_parent = panel.content.inventories.ammunition
    local trash_parent = panel.content.inventories.trash

    if not PlayersInventory.take_common_inventory(main_inventory, to_inventory, main_parent) then
        return
    end

    if not PlayersInventory.take_common_inventory(trash_inventory, to_inventory, trash_parent) then
        return
    end

    PlayersInventory.take_amunition_inventories(
        {armor_inventory, guns_inventory, ammo_inventory},
        to_inventory,
        ammunition_parent
    )
end


-- GUI clicks dispatcher --

function PlayersInventory.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    local element_name = event.element.name
    local player = game.players[event.player_index]
    local accept_window = player.gui.screen.players_inventory_accept_prompt_window

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

    ["players_inventory_expand_button"] = PlayersInventory.on_toggle_expand_panel,

    ["players_inventory_follow_button"] = PlayersInventory.on_follow_player,
    ["players_inventory_favorite_button"] = PlayersInventory.on_favorite_click,

    ["players_inventory_promotion_button"] = PlayersInventory.on_promotion_click,

    ["players_inventory_warn_button"] = PlayersInventory.on_punish_player,
    ["players_inventory_mute_button"] = PlayersInventory.on_mute_click,
    ["players_inventory_kick_button"] = PlayersInventory.on_punish_player,
    ["players_inventory_ban_button"] = PlayersInventory.on_ban_click,

    ["players_inventory_accept_punishment_button"] = PlayersInventory.on_punishment_accept,
    ["players_inventory_cancel_punishment_button"] = PlayersInventory.on_punishment_closecancel,
    ["players_inventory_close_accept_prompt_window_button"] = PlayersInventory.on_punishment_closecancel,

    ["players_inventory_give_button"] = PlayersInventory.on_give_button_click,
    ["players_inventory_take_selected_button"] = PlayersInventory.on_take_selected_click
}


-- Utility functions ---------------------------------------------------------------------------------------------------

function print(str)
    game.print(str)
end

function pprint(obj, types)
    if type(obj) ~= "table" then
        print(type(obj))
        return
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

function debug_add(caption)
    PlayersInventory.debug.add{type="label", caption=caption}
end

function debug_padd(obj, types)
    if type(obj) ~= "table" then
        debug_add(type(obj))
        return
    end

    if table_size(obj) == 0 then
        debug_add("{}")
        return
    end

    for i, k in pairs(obj) do
        if types then 
            debug_add(i .. " - " .. type(k))
        else
            debug_add(i .. " - " .. tostring(k))
        end
    end
end


-- Events dispatcher ---------------------------------------------------------------------------------------------------

local event_handlers = {}
event_handlers.on_init = PlayersInventory.on_init
event_handlers.on_configuration_changed = PlayersInventory.on_configuration_changed
event_handlers.events = {
    [defines.events.on_player_created] = PlayersInventory.on_player_created,
    [defines.events.on_player_joined_game] = PlayersInventory.on_player_joined_game,
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
