-- Copyright (c) 2023 Ajick


---@class WindowFilters
---@field section string
---@field role uint
---@field online uint
---@field player string
---@field item string
---@field favorites uint[]

---@class PlayerInventoryContent
---@field player LuaPlayer
---@field item_count uint

---@class FilterControls
---@field roles_caption LuaGuiElement
---@field roles LuaGuiElement
---@field online_caption LuaGuiElement
---@field online LuaGuiElement
---@field search_player LuaGuiElement
---@field clear_search_player LuaGuiElement
---@field search_item LuaGuiElement
---@field search_item_label LuaGuiElement


local ConfirmWindow = require("scripts.players_inventory.confirm_window")


---@class MainWindow
---@field menu_items LuaGuiElement[]
---@field filter_controls FilterControls[]
---@field section table
---@field role_filters LocalisedString[]
---@field online_filters LocalisedString[]
local MainWindow = {
    menu_items = {},
    filter_controls = {},
    zoom_factor = 1.047
}

MainWindow.sections = {
    all = "all",
    favorites = "favorites",
    warned = "warned",
    muted = "muted",
    banned = "banned",
    find_player = "find_player",
    find_items = "find_items"
}

MainWindow.role_filters = {
    {"players-inventory.caption-all-players"},
    {"players-inventory.caption-admins"},
    {"players-inventory.caption-managers"},
    {"players-inventory.caption-warriors"},
    {"players-inventory.caption-defenders"},
    {"players-inventory.caption-builders"},
    {"players-inventory.caption-undecided"}
}

MainWindow.online_filters = {
    {"players-inventory.caption-all-players"},
    {"players-inventory.caption-online"},
    {"players-inventory.caption-offline"}
}


-- GUI functions --

-- Opens or closes the window
---@param player_index uint
function MainWindow.toggle(player_index)
    local window = MainWindow.get(player_index)

    if window and window.valid then
        MainWindow.close(player_index)
        return
    end

    window = MainWindow.create(player_index)

    if not window then
        return
    end

    window.force_auto_center()

    MainWindow.setup_menu(player_index)
    MainWindow.setup_filters(player_index)
    MainWindow.fill_list(player_index)
end

-- Returns a top frame of the window
---@param player_index uint
---@return LuaGuiElement?
function MainWindow.get(player_index)
    local player = game.get_player(player_index)

    if not player then
        return
    end

    return player.gui.screen.players_inventory_main_window
end

-- Creates the window
---@param player_index uint
---@return LuaGuiElement?
function MainWindow.create(player_index)
    local player = game.get_player(player_index)

    if not player then
        return
    end

    ---@type WindowFilters
    local window_filters = MainWindow.get_window_filters(player_index)


    -- Window layout --

    -- Main frame
    local window = player.gui.screen.add{
        type = "frame",
        name = "players_inventory_main_window",
        direction = "vertical"
    }
    window.style.width = 1200
    window.style.height = 900

    -- Header
    local titlebar = window.add{type="flow", direction="horizontal"}
    titlebar.drag_target = window

    -- Inner frame
    local main_inner_frame = window.add{
        type = "frame",
        name = "inner_frame",
        direction = "vertical",
        style = "inside_deep_frame"
    }

    -- Settings pannel
    local settings_panel = main_inner_frame.add{
        type = "frame",
        name = "settings_pane",
        direction = "horizontal",
        style = "quick_bar_window_frame"
    }
    settings_panel.style.padding = 5

    -- Main content area
    local main_area = main_inner_frame.add{
        type = "frame",
        name = "content",
        direction = "horizontal"
    }
    main_area.style.top_padding = 10

    -- Menu pannel (left)
    local menu = main_area.add{type="frame", name="menu", direction="vertical"}
    menu.style.vertically_stretchable = true
    menu.style.width = 230
    menu.style.padding = 10

    -- Player list pannel
    local players = main_area.add{type="flow", name="players", direction="vertical"}


    -- Header --

    -- Title
    titlebar.add{
        type = "label",
        caption = {"players-inventory.caption"},
        ignored_by_interaction = true,
        style = "frame_title"
    }

    -- Draggable spacer to the right
    local titlebar_spacer = titlebar.add{
        type = "empty-widget",
        ignored_by_interaction = true,
        style = "draggable_space"
    }
    titlebar_spacer.style.horizontally_stretchable = true
    titlebar_spacer.style.height = 24
    titlebar_spacer.style.left_margin = 5
    titlebar_spacer.style.right_margin = 5

    -- Close button
    titlebar.add{
        type = "sprite-button",
        name = "players_inventory_close_window_button",
        sprite = "utility/close_white",
        hovered_sprite = "utility/close_black",
        clicked_sprite = "utility/close_black",
        style = "frame_action_button"
    }


    -- Settings panel --

    -- Spacer to the right
    local settings_spacer = settings_panel.add{type="empty-widget", ignored_by_interaction=true}
    settings_spacer.style.horizontally_stretchable = true

    -- Whitelist checkbox
    local wlist_bot_connected

    if PlayersInventory.wlist_bot_connected then
        wlist_bot_connected = {"players-inventory.tooltip-bot-connected"}
    else
        wlist_bot_connected = {"players-inventory.tooltip-bot-disconnected"}
    end

    local whitelist = settings_panel.add{
        type = "checkbox",
        name = "players_inventory_whitelist_checkbox",
        caption = {"players-inventory.caption-whitelist"},
        tooltip = wlist_bot_connected,
        state = global.wlist_state,
        enabled = (player.admin and PlayersInventory.wlist_bot_connected)
    }

    -- Friendly fire checkbox
    local friendly_fire = settings_panel.add{
        type = "checkbox",
        name = "players_inventory_friendly_fire_checkbox",
        caption = {"players-inventory.caption-friendly-fire"},
        state = game.forces['player'].friendly_fire,
        enabled = player.admin
    }


    -- Menu --

    local menu_items = {}

    -- All players
    menu_items[MainWindow.sections.all] = menu.add{
        type = "label",
        name = "players_inventory_menu_all",
        caption = {"players-inventory.caption-all-players"},
        tags = {section=MainWindow.sections.all},
    }
    -- raise_hover_events = true

    -- Favorites
    menu_items[MainWindow.sections.favorites] = menu.add{
        type = "label",
        name = "players_inventory_menu_favorites",
        caption = {"players-inventory.caption-favorites"},
        tags = {section=MainWindow.sections.favorites},
    }
    -- raise_hover_events = true

    -- Warned
    menu_items[MainWindow.sections.warned] = menu.add {
        type = "label",
        name = "players_inventory_menu_warned",
        caption = {"players-inventory.caption-warned"},
        tags = {section=MainWindow.sections.warned},
    }
    -- raise_hover_events = true

    -- Muted
    menu_items[MainWindow.sections.muted] = menu.add{
        type = "label",
        name = "players_inventory_menu_muted",
        caption = {"players-inventory.caption-muted"},
        tags = {section=MainWindow.sections.muted},
    }
    -- raise_hover_events = true

    -- Banned
    menu_items[MainWindow.sections.banned] = menu.add {
        type = "label",
        name = "players_inventory_menu_banned",
        caption = {"players-inventory.caption-banned"},
        tags = {section=MainWindow.sections.banned},
    }
    -- raise_hover_events = true

    -- Find player
    menu_items[MainWindow.sections.find_player] = menu.add {
        type = "label",
        name = "players_inventory_menu_find_player",
        caption = {"players-inventory.caption-find-player"},
        tags = {section=MainWindow.sections.find_player},
    }
    -- raise_hover_events = true

    -- Find items
    menu_items[MainWindow.sections.find_items] = menu.add {
        type = "label",
        name = "players_inventory_menu_find_items",
        caption = {"players-inventory.caption-find-items"},
        tags = {section=MainWindow.sections.find_items},
    }
    -- raise_hover_events = true

    MainWindow.menu_items[player_index] = menu_items


    -- Filters --

    local filter_controls = {}

    -- Filters container
    local filters_container = players.add{type="frame", name="filters", direction="horizontal", style="inside_deep_frame"}
    filters_container.style.horizontally_stretchable = true
    filters_container.style.padding = 10

    -- Roles label
    filter_controls.roles_caption = filters_container.add{type="label", caption={"players-inventory.label-role"}}
    filter_controls.roles_caption.style.top_margin = 2
    filter_controls.roles_caption.style.left_margin = 5

    -- Roles
    filter_controls.roles = filters_container.add{type="drop-down", name="players_inventory_roles_dropdown", items=MainWindow.role_filters}
    filter_controls.roles.style.left_margin = 2
    filter_controls.roles.selected_index = window_filters.role

    -- Online statsus label
    filter_controls.online_caption = filters_container.add{type="label", caption={"players-inventory.caption-status"}}
    filter_controls.online_caption.style.top_margin = 2
    filter_controls.online_caption.style.left_margin = 10

    -- Online statsus
    filter_controls.online = filters_container.add{type="drop-down", name="players_inventory_online_dropdown", items=MainWindow.online_filters}
    filter_controls.online.style.left_margin = 2
    filter_controls.online.selected_index = window_filters.online

    -- Player search field
    filter_controls.search_player = filters_container.add{type="textfield", name="players_inventory_player_textfield"}
    filter_controls.search_player.style.left_margin = 5
    filter_controls.search_player.text = window_filters.player

    -- Clear search field button
    filter_controls.clear_search_player = filters_container.add{
        type = "sprite-button",
        name = "players_inventory_clear_find_player_button",
        sprite = "utility/reset_white",
        hovered_sprite = "utility/reset",
        clicked_sprite = "utility/reset",
        style = "frame_action_button",
        tooltip = {"players-inventory.tooltip-clear-textfield"}
    }
    filter_controls.clear_search_player.style.top_margin = 3

    -- Item search button
    filter_controls.search_item = filters_container.add{
        type = "choose-elem-button",
        name = "players_inventory_select_item_button",
        style = "frame_action_button",
        elem_type="item"
    }
    filter_controls.search_item.style.top_margin = 2
    filter_controls.search_item.style.left_margin = 5
    filter_controls.search_item.style.size = 35

    -- Item search label
    filter_controls.search_item_label = filters_container.add{type="label", name="item_label"}
    filter_controls.search_item_label.style.top_margin = 8
    filter_controls.search_item_label.style.left_margin = 2

    MainWindow.filter_controls[player_index] = filter_controls

    -- Spacer to the right
    local filters_spacer = filters_container.add{type="empty-widget", ignored_by_interaction=true}
    filters_spacer.style.horizontally_stretchable = true

    -- Refresh button
    local refresh_list = filters_container.add{
        type = "sprite-button",
        name = "players_inventory_refresh_list_button",
        sprite = "utility/reset_white",
        hovered_sprite = "utility/reset",
        clicked_sprite = "utility/reset",
        style = "frame_action_button",
        tooltip = {"players-inventory.tooltip-refresh-list"}
    }
    refresh_list.style.top_margin = 2


    -- Players list --

    local list = players.add{type="scroll-pane", name="list", direction="vertical", vertical_scroll_policy="always"}
    list.style.horizontally_stretchable = true
    list.style.vertically_stretchable = true


    -- Placeholder --

    -- Placeholder outer container
    local placeholder_outer = players.add{
        type = "frame",
        name = "placeholder",
        direction = "vertical",
        style = "inside_deep_frame"
    }
    placeholder_outer.style.horizontally_stretchable = true
    placeholder_outer.style.vertically_stretchable = true

    -- Placeholder inner container
    local placeholder_inner = placeholder_outer.add{type="flow", direction="vertical"}
    placeholder_inner.style.horizontally_stretchable = true
    placeholder_inner.style.vertically_stretchable = true
    placeholder_inner.style.horizontal_align = "center"
    placeholder_inner.style.vertical_align = "center"

    -- Ghost picture
    placeholder_inner.add{type="sprite", sprite="utility/ghost_time_to_live_modifier_icon"}

    -- Placeholder text
    placeholder_inner.add{type="label", caption={"players-inventory.caption-empty"}, style="inventory_label"}


    -- Players counter --

    -- Counter container
    local count = players.add{type="frame", name="count", direction="horizontal", style="inside_deep_frame"}
    count.style.horizontally_stretchable = true
    count.style.padding = 5

    -- Counter label
    local label = count.add{type="label", name="count_label", style="subheader_caption_label", caption="0 игроков"}


    -- Return --

    return window
end

-- Setups menu items
---@param player_index uint
function MainWindow.setup_menu(player_index)
    if not player_index then
        return
    end

    local menu_items = MainWindow.menu_items[player_index]

    if not menu_items then
        return
    end

    local filters = MainWindow.get_window_filters(player_index)

    for _, menu_item in pairs(menu_items) do
        if menu_item.tags.section ~= filters.section then
            menu_item.style = "players_inventory_menu_item"
        else
            menu_item.style = "players_inventory_menu_current_item"
        end
    end
end

-- Setups search filters
---@param player_index uint
function MainWindow.setup_filters(player_index)
    if not player_index then
        return
    end

    local filter_controls = MainWindow.filter_controls[player_index]

    if not filter_controls then
        return
    end

    local parent = filter_controls.roles.parent

    local filters = MainWindow.get_window_filters(player_index)

    local show_filters = (
        filters.section == MainWindow.sections.all
        or filters.section == MainWindow.sections.find_player
        or filters.section == MainWindow.sections.find_items
    )

    parent.visible = show_filters

    if not show_filters then
        return
    end

    local is_section_all = (filters.section == MainWindow.sections.all)
    local is_section_find_player = (filters.section == MainWindow.sections.find_player)
    local is_section_find_items = (filters.section == MainWindow.sections.find_items)

    filter_controls.roles_caption.visible = is_section_all
    filter_controls.roles.visible = is_section_all
    filter_controls.roles.selected_index = filters.role

    filter_controls.online_caption.visible = is_section_all
    filter_controls.online.visible = is_section_all
    filter_controls.online.selected_index = filters.online

    filter_controls.search_player.visible = is_section_find_player
    filter_controls.search_player.text = filters.player
    filter_controls.clear_search_player.visible = is_section_find_player
    filter_controls.clear_search_player.enabled = (filters.player ~= "")

    filter_controls.search_item.visible = is_section_find_items
    filter_controls.search_item_label.visible = is_section_find_items

    if is_section_find_player then
        filter_controls.search_player.focus()
    elseif is_section_find_items then
        if filters.item == "" then
            filter_controls.search_item_label.caption = {"players-inventory.label-select-item"}
        else
            filter_controls.search_item.elem_value = filters.item
            filter_controls.search_item_label.caption = {
                "?",
                {"entity-name."..filters.item},
                {"item-name."..filters.item},
                {"equipment-name."..filters.item}
            }
        end
    end
end

-- Fills list of players
---@param player_index uint
function MainWindow.fill_list(player_index)
    if not player_index then
        return
    end

    local main_window = MainWindow.get(player_index)

    if not main_window or not main_window.valid then
        return
    end

    local players_list = main_window.inner_frame.content.players.list
    local placeholder = main_window.inner_frame.content.players.placeholder
    local players_count = main_window.inner_frame.content.players.count

    local filters = MainWindow.get_window_filters(player_index)
    local players = MainWindow.get_filtered_players(filters)

    local has_players = (#players > 0)

    players_list.visible = has_players
    placeholder.visible = not has_players
    players_count.visible = has_players

    if not has_players then
        return
    end

    ---@diagnostic disable-next-line: need-check-nil
    players_list.clear()

    if filters.section ~= MainWindow.sections.find_items then
        ---@diagnostic disable-next-line: need-check-nil
        players_count.count_label.caption = {"players-inventory.caption-count", #players}
    else
        local total_count = 0

        for _, player in pairs(players) do
            total_count = total_count + player.item_count
        end

        local total_players

        if total_count > 1 then
            total_players = {"players-inventory.caption-players-many"}
        else
            total_players = {"players-inventory.caption-players-one"}
        end

        ---@diagnostic disable-next-line: need-check-nil
        players_count.count_label.caption = {
            "players-inventory.caption-found",
            total_count,
            filters.item,
            #players,
            total_players
        }
    end

    for _, player in pairs(players) do
        ---@diagnostic disable-next-line: param-type-mismatch
        MainWindow.add_player(players_list, player, filters)
    end

    ---@diagnostic disable-next-line: need-check-nil
    players_list.scroll_to_top()
end

-- Adds player bar into players list
---@param list LuaGuiElement
---@param player LuaPlayer|PlayerInventoryContent
---@param filters WindowFilters
function MainWindow.add_player(list, player, filters)
    if not list or not list.valid then
        return
    end

    if not player then
        return
    end

    local self_player = game.get_player(list.player_index)

    if not self_player then
        return
    end

    local self_playerdata = ServerMod.get_make_playerdata(self_player.index)
    local is_self_admin = self_player.admin
    local is_self_manager = self_playerdata.manager or false

    local item_count = 0

    if filters.section == MainWindow.sections.find_items then
        item_count = player.item_count
        player = player.player
    end

    local status = ""

    if player.connected then
        status = "online"
    else
        status = "offline"
    end

    local playerdata = ServerMod.get_make_playerdata(player.index)
    local is_self = player.index == self_player.index
    local is_admin = player.admin
    local is_manager = playerdata.manager or false
    local warnings = PlayersInventory.get_warnings(player.index)
    local is_muted = PlayersInventory.is_muted(player.index)
    local is_banned = PlayersInventory.is_banned(player.index)

    local tags = {player_index=player.index}


    -- Frame --

    local player_bar = list.add{type="frame", name=player.name, direction="horizontal"}
    player_bar.style.vertically_stretchable = false
    player_bar.style.padding = 5


    -- Header --

    -- Open inventory button
    if is_self_admin or is_self_manager then
        player_bar.add{
            type = "sprite-button",
            name = "players_inventory_open_inventory_button",
            sprite = "utility/slot_icon_armor",
            hovered_sprite = "utility/slot_icon_armor_black",
            clicked_sprite = "utility/slot_icon_armor_black",
            style = "frame_action_button",
            tags = tags,
            tooltip = {"players-inventory.tooltip-open-inventory"},
            enabled = (not is_self)
        }
    end

    --Fix permission button
    if (is_self_admin or is_self_manager)
    and (
        (is_admin and not Permissions.in_group(player, Permissions.groups.admin))
        or
        (not is_admin and is_manager and not Permissions.in_group(player, Permissions.groups.manager))
    )
    then
        player_bar.add{
            type = "sprite-button",
            name = "players_inventory_fix_permossions_button",
            sprite = "utility/reset_white",
            hovered_sprite = "utility/reset",
            clicked_sprite = "utility/reset",
            style = "frame_action_button",
            tags = tags,
            tooltip = {"players-inventory.tooltip-fix-permissions"}
        }
    end

    -- Player name
    player_bar.add{type="label", caption=player.name, style="subheader_caption_label"}


    -- Badges --

    -- Admin badge
    local admin_badge = player_bar.add{
        type="label", name="admin", caption={"players-inventory.label-admin-badge"},
        visible=is_admin
    }
    admin_badge.style.font_color = {1, 1, 0, 1}

    -- Manager badge
    local manager_badge = player_bar.add{
        type="label", name="manager", caption={"players-inventory.label-manager-badge"},
        visible=is_manager
    }
    manager_badge.style.font_color = {0, 1, 0, 1}

    -- Role badge
    local role_badge = player_bar.add{
        type="label", name="role",
        caption={"players-inventory.label-"..(playerdata.role or "undecided").."-badge"}
    }
    if playerdata.aplied then
        if playerdata.role == ServerMod.online.warrior then
            role_badge.style.font_color = {1, 0.5, 0, 1}
        elseif playerdata.role == ServerMod.roles.builder then
            role_badge.style.font_color = {0, 0.5, 0.5, 1}
        elseif playerdata.role == ServerMod.roles.defender then
            role_badge.style.font_color = {0, 0.5, 1, 1}
        end
    end

    -- Warnings badge
    player_bar.add{
        type="label", name="warned", caption={"players-inventory.label-warnings-badge", #warnings},
        tooltip=PlayersInventory.get_warn_tooltip(warnings),
        visible=(#warnings > 0)
    }

    -- Muted badge
    player_bar.add{
        type="label", name="muted", caption={"players-inventory.label-muted-badge"},
        visible=(filters.section ~= "muted" and is_muted)
    }

    -- Banned badge
    player_bar.add{
        type="label", name="banned", caption={"players-inventory.label-banned-badge"},
        tooltip={"players-inventory.tooltip-reason", (global.players_inventory.bans[player.index] or "")},
        visible=is_banned
    }

    -- Online/offline badge
    player_bar.add{type="label", name="connected", caption={"players-inventory.label-"..status.."-badge"}}


    -- Spacer --

    local spacer = player_bar.add{type="empty-widget", ignored_by_interaction=true}
    spacer.style.horizontally_stretchable = true


    -- Found items badge --

    if filters.section == MainWindow.sections.find_items then
        player_bar.add{
            type = "label",
            name = "found_items",
            caption = {"players-inventory.label-found-items", item_count, filters.item}
        }

        -- Vertical bar
        local line = player_bar.add{
            type="line", direction="vertical",
            visible=(not is_self)
        }
        line.style.left_margin = 5
        line.style.right_margin = 5
        line.style.height = 25
    end


    -- Buttons --

    if is_self then
        return
    end

    -- Follow button
    player_bar.add{
        type = "sprite-button",
        name = "players_inventory_follow_button",
        sprite = "utility/search_white",
        hovered_sprite = "utility/search_black",
        clicked_sprite = "utility/search_black",
        tooltip = {"players-inventory.tooltip-follow"},
        style = "frame_action_button",
        tags = tags,
        visible = player.connected
    }

    -- Favorite button
    do
        local sprite, altered_sprite, tooltip

        if MainWindow.is_favorite(self_player.index, player.index) then
            sprite = "players_inventory_unfavorite_white"
            altered_sprite = "players_inventory_unfavorite_black"
            tooltip = {"players-inventory.tooltip-unfavorite"}
        else
            sprite = "players_inventory_favorite_white"
            altered_sprite = "players_inventory_favorite_black"
            tooltip = {"players-inventory.tooltip-favorite"}
        end

        player_bar.add{
            type = "sprite-button",
            name = "players_inventory_toggle_favorite_button",
            sprite = sprite,
            hovered_sprite = altered_sprite,
            clicked_sprite = altered_sprite,
            tooltip = tooltip,
            style = "frame_action_button",
            tags = tags
        }
    end

    if is_self_admin then
        -- Vertical bar
        local line = player_bar.add{type="line", direction="vertical"}
        line.style.left_margin = 5
        line.style.right_margin = 5
        line.style.height = 25

        -- Set admin button
        do
            local sprite, altered_sprite, tooltip

            if is_admin then
                sprite = "players_inventory_unset_admin_white"
                altered_sprite = "players_inventory_unset_admin_black"
                tooltip = {"players-inventory.tooltip-unset-admin"}
            else
                sprite = "players_inventory_set_admin_white"
                altered_sprite = "players_inventory_set_admin_black"
                tooltip = {"players-inventory.tooltip-set-admin"}
            end

            player_bar.add{
                type = "sprite-button",
                name = "players_inventory_toggle_admin_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = tags,
            }
        end

        -- Set manager button
        do
            local sprite, altered_sprite, tooltip

            if is_manager then
                sprite = "players_inventory_unset_manager_white"
                altered_sprite = "players_inventory_unset_manager_black"
                tooltip = {"players-inventory.tooltip-unset-manager"}
            else
                sprite = "players_inventory_set_manager_white"
                altered_sprite = "players_inventory_set_manager_black"
                tooltip = {"players-inventory.tooltip-set-manager"}
            end

            player_bar.add{
                type = "sprite-button",
                name = "players_inventory_toggle_manager_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = tags
            }
        end
    end

    if is_self_admin or is_self_manager then
        -- Vertical bar
        local line = player_bar.add{type="line", direction="vertical"}
        line.style.left_margin = 5
        line.style.right_margin = 5
        line.style.height = 25

        -- Warn button
        player_bar.add{
            type = "sprite-button",
            name = "players_inventory_warn_button",
            sprite = "players_inventory_warn_white",
            hovered_sprite = "players_inventory_warn_black",
            clicked_sprite = "players_inventory_warn_black",
            tooltip = {"players-inventory.tooltip-warn"},
            style = "frame_action_button",
            tags = tags
        }

        -- Mute button
        do
            local sprite, altered_sprite, tooltip

            if is_muted then
                sprite = "players_inventory_unmute_white"
                altered_sprite = "players_inventory_unmute_black"
                tooltip = {"players-inventory.tooltip-unmute"}
            else
                sprite = "players_inventory_mute_white"
                altered_sprite = "players_inventory_mute_black"
                tooltip = {"players-inventory.tooltip-mute"}
            end

            player_bar.add{
                type = "sprite-button",
                name = "players_inventory_toggle_mute_button",
                sprite = sprite,
                hovered_sprite = altered_sprite,
                clicked_sprite = altered_sprite,
                tooltip = tooltip,
                style = "frame_action_button",
                tags = tags
            }
        end

        -- Kick button
        if player.connected then
            player_bar.add{
                type = "sprite-button",
                name = "players_inventory_kick_button",
                sprite = "players_inventory_kick_white",
                hovered_sprite = "players_inventory_kick_black",
                clicked_sprite = "players_inventory_kick_black",
                tooltip = {"players-inventory.tooltip-kick"},
                style = "frame_action_button",
                tags = tags
            }
        end
    end

    -- Ban button
    if is_self_admin then
        local sprite, altered_sprite, tooltip

        if is_banned then
            sprite = "players_inventory_unban_white"
            altered_sprite = "players_inventory_unban_black"
            tooltip = {"players-inventory.tooltip-unban"}
        else
            sprite = "players_inventory_ban_white"
            altered_sprite = "players_inventory_ban_black"
            tooltip = {"players-inventory.tooltip-ban"}
        end

        player_bar.add{
            type = "sprite-button",
            name = "players_inventory_toggle_ban_button",
            sprite = sprite,
            hovered_sprite = altered_sprite,
            clicked_sprite = altered_sprite,
            tooltip = tooltip,
            style = "frame_action_button",
            tags = tags
        }
    end
end

-- Removes player frame from players list
---@param player_index uint
---@param target_index uint
function MainWindow.remove_player(player_index, target_index)
    if not player_index or not target_index then
        return
    end

    local player = game.get_player(target_index)

    if not player then
        return
    end

    local main_window = MainWindow.get(player_index)

    if not main_window or not main_window.valid then
        return
    end

    local players_list = main_window.inner_frame.content.players.list
    local placeholder = main_window.inner_frame.content.players.placeholder
    local players_count = main_window.inner_frame.content.players.count

    local player_frame = players_list[player.name] ---@diagnostic disable-line: need-check-nil

    if not player_frame then
        return
    end

    player_frame.destroy()

    local count = #players_list.children ---@diagnostic disable-line: need-check-nil

    if count > 0 then
        ---@diagnostic disable-next-line: need-check-nil
        players_count.count_label.caption = {"players-inventory.caption-count", count}
    else
        players_list.visible = false
        players_count.visible = false
        placeholder.visible = true
    end
end

-- Changes current section
---@param player_index uint
---@param section string
function MainWindow.change_section(player_index, section)
    if not player_index or not section then
        return
    end

    local filters = MainWindow.get_window_filters(player_index)
    filters.section = section

    MainWindow.setup_menu(player_index)
    MainWindow.setup_filters(player_index)
    MainWindow.fill_list(player_index)
end

-- Closes window
---@param player_index uint
function MainWindow.close(player_index)
    local window = MainWindow.get(player_index)

    if not window or not window.valid then
        return
    end

    window.destroy()
    MainWindow.menu_items[player_index] = nil
    MainWindow.filter_controls[player_index] = nil
end


-- Filter functions --

-- Returns window filters of a player
---@param player_index uint
---@return WindowFilters
function MainWindow.get_window_filters(player_index)
    if not global.players_inventory.window_filters then
        global.players_inventory.window_filters = {}
    end

    if not global.players_inventory.window_filters[player_index] then
        global.players_inventory.window_filters[player_index] = {
            section = "all",
            role = 1,
            online = 1,
            player = "",
            item = "",
            favorites = {}
        }
    end

    return global.players_inventory.window_filters[player_index]
end

-- Returns players passed by setuped filters
---@param filters WindowFilters
---@return LuaPlayer[]|PlayerInventoryContent[]
function MainWindow.get_filtered_players(filters)
    if not filters then
        return {}
    end

    local players

    if filters.section == MainWindow.sections.all then
        -- Filter by connection and role

        if filters.online == 2 then
            players = game.connected_players
        elseif filters.online == 3 then
            players = MainWindow.get_offline_players()
        else
            players = game.players
        end

        if filters.role ~= 1 then
            players = MainWindow.get_players_by_role(players, filters.role)
        end
    elseif filters.section == MainWindow.sections.favorites then
        -- Filter favorites

        if #filters.favorites > 0 then
            players = MainWindow.get_favorite_players(filters.favorites)
        else
            return {}
        end
    elseif filters.section == MainWindow.sections.warned then
        -- Filter warned

        if table_size(global.players_inventory.warnings) > 0 then
            players = MainWindow.get_warned_players()
        else
            return {}
        end
    elseif filters.section == MainWindow.sections.muted then
        -- Filter muted

        if table_size(global.players_inventory.mutes) > 0 then
            players = MainWindow.get_muted_players()
        else
            return {}
        end
    elseif filters.section == MainWindow.sections.banned then
        -- Filter banned

        if table_size(global.players_inventory.bans) > 0 then
            players = MainWindow.get_banned_players()
        else
            return {}
        end
    elseif filters.section == MainWindow.sections.find_player then
        -- Filter by_name

        if filters.player ~= "" then
            players = MainWindow.get_players_by_name(filters.player)
        else
            return {}
        end
    elseif filters.section == MainWindow.sections.find_items then
        -- Filter by items

        if filters.item ~= "" then
            players = MainWindow.get_players_by_items(filters.item)
        else
            return {}
        end
    end

    players = MainWindow.sort_players(players)

    return players
end

-- Returns offline players
---@return LuaPlayer[]
function MainWindow.get_offline_players()
    local players = {}

    for _, player in pairs(game.players) do
        if not player.connected then
            table.insert(players, player)
        end
    end

    return players
end

-- Returns players filtered by role
---@param players LuaPlayer[]
---@param role_index uint
---@return LuaPlayer[]
function MainWindow.get_players_by_role(players, role_index)
    local filtered_players = {}
    local role

    if role_index == 2 then
        for _, player in pairs(players) do
            if player.admin then
                table.insert(filtered_players, player)
            end
        end
    elseif role_index == 3 then
        for index, player in pairs(players) do
            local playerdata = ServerMod.get_make_playerdata(index)

            if playerdata.manager then
                table.insert(filtered_players, player)
            end
        end
    elseif role_index >= 4 and role_index <= 6 then
        for index, player in pairs(players) do
            local playerdata = ServerMod.get_make_playerdata(index)

            if playerdata.role == PlayersInventory.roles[role_index-3] then
                table.insert(filtered_players, player)
            end
        end
    elseif role_index == 7 then
        for index, player in pairs(players) do
            local playerdata = ServerMod.get_make_playerdata(index)

            if not playerdata.applied then
                table.insert(filtered_players, player)
            end
        end
    end

    return filtered_players
end

-- Returns favorite players
---@param favorites uint[]
---@return LuaPlayer[]
function MainWindow.get_favorite_players(favorites)
    local players = {}

    for _, player_index in pairs(favorites) do
        table.insert(players, game.get_player(player_index))
    end

    return players
end

-- Returns warned players
---@return LuaPlayer[]
function MainWindow.get_warned_players()
    local players = {}

    for player_index, _ in pairs(global.players_inventory.warnings) do
        table.insert(players, game.get_player(player_index))
    end

    return players
end

-- Returns muted players
---@return LuaPlayer[]
function MainWindow.get_muted_players()
    local players = {}

    for player_index, _ in pairs(global.players_inventory.mutes) do
        table.insert(players, game.get_player(player_index))
    end

    return players
end

-- Returns banned players
---@return LuaPlayer[]
function MainWindow.get_banned_players()
    local players = {}

    for player_index, _ in pairs(global.players_inventory.bans) do
        table.insert(players, game.get_player(player_index))
    end

    return players
end

-- Returns players filtered by name
---@param name string
---@return LuaPlayer[]
function MainWindow.get_players_by_name(name)
    local players = {}

    for _, player in pairs(game.players) do
        if string.match(string.lower(player.name), string.lower(name)) then
            table.insert(players, player)
        end
    end

    return players
end

-- Returns players filtered by items
---@param item string
---@return PlayerInventoryContent[]
function MainWindow.get_players_by_items(item)
    local players = {}

    for _, player in pairs(game.players) do
        local item_count = 0

        for inventory_name, inventory_index in pairs(PlayersInventory.inventories) do
            local inventory = player.get_inventory(inventory_index)

            if inventory and inventory.valid then
                item_count = item_count + inventory.get_item_count(item)
            end
        end

        if item_count > 0 then
            table.insert(players, {player=player, item_count=item_count})
        end
    end

    return players
end

-- Returns sorted player list
---@param players LuaPlayer[]|PlayerInventoryContent[]
---@return LuaPlayer[]|PlayerInventoryContent[]
function MainWindow.sort_players(players)
    if not players then
        return {}
    end

    if #players == 0 then
        return {}
    end

    local admins = {}
    local managers = {}
    local other = {}

    for _, player in pairs(players) do
        local temp_player

        if player.valid then
            temp_player = player
        else
            temp_player = player.player
        end

        local playerdata = ServerMod.get_make_playerdata(temp_player.index)

        if temp_player.admin then
            table.insert(admins, player)
        elseif playerdata.manager then
            table.insert(managers, player)
        else
            table.insert(other, player)
        end
    end

    local function get_name(player1, player2)
        return ((player1.name or player1.player.name) < (player2.name or player2.player.name))
    end

    table.sort(admins, get_name)
    table.sort(managers, get_name)
    table.sort(other, get_name)

    local sorted_players = {}

    for _, table_ in pairs({admins, managers, other}) do
        local len = #sorted_players

        for index, player in pairs(table_) do
            sorted_players[len+index] = player
        end
    end

    return sorted_players
end


-- Punishment handlers --

-- Warns a player by a reason
---@param target_player LuaPlayer
---@param element LuaGuiElement
---@param reason string
function MainWindow.warn(target_player, element, reason)
    if not target_player or not element then
        return
    end

    PlayersInventory.warn(target_player, reason)

    local warnings = PlayersInventory.get_warnings(target_player.index)

    element.parent.warned.visible = true
    element.parent.warned.caption = {"players-inventory.label-warnings-badge", #warnings}
    element.parent.warned.tooltip = PlayersInventory.get_warn_tooltip(warnings)
end

-- Kicks a player by a reason
---@param target_player LuaPlayer
---@param element LuaGuiElement
---@param reason string
function MainWindow.kick(target_player, element, reason)
    if not target_player or not element then
        return
    end

    game.kick_player(target_player, reason)

    local filters = MainWindow.get_window_filters(element.player_index)

    if filters.section == MainWindow.sections.all
    and filters.online == 2
    then
        ---@diagnostic disable-next-line: param-type-mismatch
        MainWindow.remove_player(element.player_index, element.tags.player_index)
    else
        element.parent.connected.caption = {"players-inventory.label-offline-badge"}
        element.visible = false

        if element.parent.players_inventory_follow_button then
            element.parent.players_inventory_follow_button.visible = false
        end
    end
end

-- Bans a player by a reason
---@param target_player LuaPlayer
---@param element LuaGuiElement
---@param reason string
function MainWindow.ban(target_player, element, reason)
    if not target_player or not element then
        return
    end

    PlayersInventory.ban(target_player, reason)

    local filters = MainWindow.get_window_filters(element.player_index)

    if filters.section == MainWindow.sections.all
    and filters.online == 2
    then
        ---@diagnostic disable-next-line: param-type-mismatch
        MainWindow.remove_player(element.player_index, element.tags.player_index)
    else
        element.sprite = "players_inventory_unban_white"
        element.hovered_sprite = "players_inventory_unban_black"
        element.clicked_sprite = "players_inventory_unban_black"
        element.tooltip = {"players-inventory.tooltip-unban"}

        element.parent.banned.visible = true
        element.parent.banned.tooltip = {"players-inventory.tooltip-reason", reason}
        element.parent.connected.caption = {"players-inventory.label-offline-badge"}

        if element.parent.players_inventory_follow_button then
            element.parent.players_inventory_follow_button.visible = false
        end

        if element.parent.players_inventory_kick_button then
            element.parent.players_inventory_kick_button.visible = false
        end
    end
end


-- Utility function --

-- Returns a favorite status a player
---@param self_index uint
---@param target_index uint
---@return boolean
function MainWindow.is_favorite(self_index, target_index)
    local favorites = MainWindow.get_window_filters(self_index).favorites

    if #favorites == 0 then
        return false
    end

    for _, player_index in pairs(favorites) do
        if player_index == target_index then
            return true
        end
    end

    return false
end

-- Adds a player to the favorites list
---@param self_index uint
---@param target_index uint
function MainWindow.favorite(self_index, target_index)
    local filters = MainWindow.get_window_filters(self_index)
    table.insert(filters.favorites, target_index)
end

-- Removes a player from the favorites list
---@param self_index uint
---@param target_index uint
function MainWindow.unfavorite(self_index, target_index)
    local filters = MainWindow.get_window_filters(self_index)

    if #filters.favorites == 0 then
        return
    end

    PlayersInventory.remove(filters.favorites, target_index)
end


-- MainWindow event handlers --

-- On toggle window event handler
---@param event Event
function MainWindow.on_toggle_main_window(event)
    if not event or not event.player_index then
        return
    end

    MainWindow.toggle(event.player_index)
end

-- On camera zoom in
---@param event Event
function MainWindow.on_camera_zoom_in(event)
    if not event or not event.player_index then
        return
    end

    local player = game.get_player(event.player_index)

    if not player then
        return
    end

    local frame = player.gui.screen.players_inventory_camera

    if not frame or not frame.valid then
        return
    end

    frame.camera.zoom = frame.camera.zoom * MainWindow.zoom_factor
end

-- On camera zoom out
---@param event Event
function MainWindow.on_camera_zoom_out(event)
    if not event or not event.player_index then
        return
    end

    local player = game.get_player(event.player_index)

    if not player then
        return
    end

    local frame = player.gui.screen.players_inventory_camera

    if not frame or not frame.valid then
        return
    end

    frame.camera.zoom = frame.camera.zoom / MainWindow.zoom_factor
end


-- Global event handlers --

-- On select item in dropdown
---@param event Event
function MainWindow.on_gui_selection_state_changed(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_roles_dropdown" then
        local filters = MainWindow.get_window_filters(event.player_index)
        filters.role = element.selected_index
        MainWindow.fill_list(event.player_index)
    elseif element.name == "players_inventory_online_dropdown" then
        local filters = MainWindow.get_window_filters(event.player_index)
        filters.online = element.selected_index
        MainWindow.fill_list(event.player_index)
    end
end

-- On type text in textfield
---@param event Event
function MainWindow.on_gui_text_changed(event)
    if not event or not event.player_index or not event.text then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_player_textfield" then
        local player_index = event.player_index

        ---@type FilterControls
        local filter_controls = MainWindow.filter_controls[player_index]

        if not filter_controls then
            return
        end

        local filters = MainWindow.get_window_filters(player_index)

        filter_controls.clear_search_player.enabled = (event.text ~= "")
        filters.player = string.lower(event.text)

        MainWindow.fill_list(player_index)
    end
end

-- On select item or clear in choose-elem-button
---@param event Event
function MainWindow.on_gui_elem_changed(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_select_item_button" then
        local player_index = event.player_index

        ---@type FilterControls
        local filter_controls = MainWindow.filter_controls[player_index]
        local filters = MainWindow.get_window_filters(player_index)

        if not filter_controls then
            return
        end

        ---@diagnostic disable-next-line: assign-type-mismatch
        filters.item = filter_controls.search_item.elem_value

        if not filters.item then
            filters.item = ""
            filter_controls.search_item_label.caption = {"players-inventory.label-select-item"}
        else
            filter_controls.search_item_label.caption = {
                "?",
                {"entity-name."..filters.item},
                {"item-name."..filters.item},
                {"equipment-name."..filters.item}
            }
        end

        MainWindow.fill_list(player_index)
    end
end

-- On checkbox/radiobutton state change
---@param event Event
function MainWindow.on_gui_checked_state_changed(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_friendly_fire_checkbox" then
        local player = game.get_player(event.player_index)

        if not player then
            return
        end

        player.force.friendly_fire = element.state
    elseif element.name == "players_inventory_whitelist_checkbox" then
        global.wlist_state = element.state
    end
end

-- On close follow player view
---@param event Event
function MainWindow.on_gui_closed(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_camera" then
        element.destroy()

        local player = game.get_player(event.player_index)

        if not player then
            return
        end

        player.zoom = 1.0
    end
end

-- Main handler of mouse clicks on GUI elements
---@param event Event
function MainWindow.on_gui_click(event)
    if not event or not event.player_index then
        return
    end

    if not event.element or not event.element.valid then
        return
    end

    local handler = MainWindow.on_gui_click_handlers[event.element.name]

    if handler then
        handler(event)
    elseif event.element.tags and event.element.tags.section then
        ---@diagnostic disable-next-line: param-type-mismatch
        MainWindow.change_section(event.player_index, event.element.tags.section)
    end
end


-- Button click event handlers --

-- On close window button click
---@param event Event
function MainWindow.on_close_button_click(event)
    if not event or not event.player_index then
        return
    end

    MainWindow.close(event.player_index)
end

-- On clear serach player field button click
---@param event Event
function MainWindow.on_clear_find_player_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if element.name == "players_inventory_clear_find_player_button" then
        local player_index = event.player_index

        ---@type FilterControls
        local filter_controls = MainWindow.filter_controls[player_index]

        if not filter_controls then
            return
        end

        local filters = MainWindow.get_window_filters(player_index)

        filter_controls.clear_search_player.enabled = false
        filter_controls.search_player.text = ""
        filters.player = ""

        MainWindow.fill_list(player_index)

        filter_controls.search_player.focus()
    end
end

-- On refresh players list button click
---@param event Event
function MainWindow.on_refresh_list_button_click(event)
    if not event or not event.player_index then
        return
    end

    MainWindow.fill_list(event.player_index)
end

-- On open players inventory button click
---@param event Event
function MainWindow.on_open_inventory_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    local self_player = game.get_player(event.player_index)

    if not self_player then
        return
    end

    self_player.opened = target_player
end

-- On fix player permissions button click
---@param event Event
function MainWindow.on_fix_permossions_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    local is_manager = ServerMod.get_make_playerdata(target_player.index).manager or false

    if target_player.admin and not Permissions.in_group(target_player, Permissions.groups.admin) then
        Permissions.set_group(target_player, Permissions.groups.admin)
    elseif is_manager and not Permissions.in_group(target_player, Permissions.groups.manager) then
        Permissions.set_group(target_player, Permissions.groups.manager)
    end

    element.visible = false
end

-- On follow button click
---@param event Event
function MainWindow.on_follow_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player or not target_player.character then
        return
    end

    local self_player = game.get_player(event.player_index)

    if not self_player then
        return
    end

    local frame = self_player.gui.screen.add{
        type = "frame",
        name = "players_inventory_camera",
        style = "invisible_frame"
    }
    local camera = frame.add{
        type = "camera",
        name = "camera",
        surface_index = target_player.surface_index,
        position = target_player.position,
        zoom = 1.0
    }
    camera.style.width = self_player.display_resolution.width
    camera.style.height = self_player.display_resolution.height
    camera.entity = target_player.character

    frame.force_auto_center()

    self_player.opened = frame
end

-- On toggle favorite button click
---@param event Event
function MainWindow.on_toggle_favorite_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid or not element.tags then
        return
    end

    ---@type uint
    local target_index = element.tags.player_index ---@diagnostic disable-line assign-type-mismatch

    if not target_index then
        return
    end

    local player_index = event.player_index

    if MainWindow.is_favorite(player_index, target_index) then
        MainWindow.unfavorite(player_index, target_index)

        local filters = MainWindow.get_window_filters(player_index)

        if not filters or filters.section ~= MainWindow.sections.favorites then
            element.sprite = "players_inventory_favorite_white"
            element.hovered_sprite = "players_inventory_favorite_black"
            element.clicked_sprite = "players_inventory_favorite_black"
            element.tooltip = {"players-inventory.tooltip-favorite"}
        else
            MainWindow.remove_player(player_index, target_index)
        end
    else
        MainWindow.favorite(player_index, target_index)

        element.sprite = "players_inventory_unfavorite_white"
        element.hovered_sprite = "players_inventory_unfavorite_black"
        element.clicked_sprite = "players_inventory_unfavorite_black"
        element.tooltip = {"players-inventory.tooltip-unfavorite"}
    end
end

-- On toggle admin button click
---@param event Event
function MainWindow.on_toggle_admin_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    if target_player.admin then
        target_player.admin = false

        local playerdata = ServerMod.get_make_playerdata(target_player.index)

        if playerdata.manager then
            Permissions.set_group(target_player, Permissions.groups.manager)
        else
            Permissions.set_group(target_player, Permissions.groups.default)
        end

        local window = MainWindow.get(target_player.index)

        if window then
            MainWindow.close(target_player.index)
        end

        local filters = MainWindow.get_window_filters(event.player_index)

        if filters.section == MainWindow.sections.all
        and filters.role == 2
        then
            MainWindow.remove_player(event.player_index, target_player.index)
        else
            element.sprite = "players_inventory_set_admin_white"
            element.hovered_sprite = "players_inventory_set_admin_black"
            element.clicked_sprite = "players_inventory_set_admin_black"
            element.tooltip = {"players-inventory.tooltip-set-admin"}

            element.parent.admin.visible = false
        end

        game.print({"players-inventory.message-no-more-admin", target_player.name})
    else
        target_player.admin = true
        Permissions.set_group(target_player, Permissions.groups.admin)

        element.sprite = "players_inventory_unset_admin_white"
        element.hovered_sprite = "players_inventory_unset_admin_black"
        element.clicked_sprite = "players_inventory_unset_admin_black"
        element.tooltip = {"players-inventory.tooltip-unset-admin"}

        element.parent.admin.visible = true

        game.print({"players-inventory.message-now-admin", target_player.name})
    end

    PlayerColor.apply_player_color(target_player)
end

-- On toggle manager button click
---@param event Event
function MainWindow.on_toggle_manager_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local playerdata = ServerMod.get_make_playerdata(element.tags.player_index)

    if playerdata.manager then
        playerdata.manager = false

        if not target_player.admin then
            Permissions.set_group(target_player, Permissions.groups.default)

            local window = MainWindow.get(target_player.index)

            if window then
                MainWindow.close(target_player.index)
            end
        end

        local filters = MainWindow.get_window_filters(event.player_index)

        if filters.section == MainWindow.sections.all
        and filters.role == 3
        then
            ---@diagnostic disable-next-line: param-type-mismatch
            MainWindow.remove_player(event.player_index, element.tags.player_index)
        else
            element.sprite = "players_inventory_set_manager_white"
            element.hovered_sprite = "players_inventory_set_manager_black"
            element.clicked_sprite = "players_inventory_set_manager_black"
            element.tooltip = {"players-inventory.tooltip-set-manager"}

            element.parent.manager.visible = false
        end

        game.print({"players-inventory.message-no-more-manager", target_player.name})
    else
        playerdata.manager = true

        if not target_player.admin then
            Permissions.set_group(target_player, Permissions.groups.manager)
        end

        element.sprite = "players_inventory_unset_manager_white"
        element.hovered_sprite = "players_inventory_unset_manager_black"
        element.clicked_sprite = "players_inventory_unset_manager_black"
        element.tooltip = {"players-inventory.tooltip-unset-manager"}

        element.parent.manager.visible = true

        game.print({"players-inventory.message-now-manager", target_player.name})
    end

    PlayerColor.apply_player_color(target_player)
end

-- On warn button click
---@param event Event
function MainWindow.on_warn_button_click(event)
    if not event or not event.player_index then
        return
    end

    local player = game.get_player(event.player_index)

    if not player then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    local warnings = PlayersInventory.get_warnings(target_player.index)

    ConfirmWindow.create(player, target_player, element, ConfirmWindow.actions.warn, MainWindow.warn, warnings)
end

-- On mute button click
---@param event Event
function MainWindow.on_toggle_mute_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    if PlayersInventory.is_muted(target_player.index) then
        PlayersInventory.unmute(target_player)

        local filters = MainWindow.get_window_filters(event.player_index)

        if filters.section == MainWindow.sections.muted then
            ---@diagnostic disable-next-line: param-type-mismatch
            MainWindow.remove_player(event.player_index, element.tags.player_index)
        else
            element.sprite = "players_inventory_mute_white"
            element.hovered_sprite = "players_inventory_mute_black"
            element.clicked_sprite = "players_inventory_mute_black"
            element.tooltip = {"players-inventory.tooltip-mute"}

            element.parent.muted.visible = false
        end
    else
        PlayersInventory.mute(target_player)

        element.sprite = "players_inventory_unmute_white"
        element.hovered_sprite = "players_inventory_unmute_black"
        element.clicked_sprite = "players_inventory_unmute_black"
        element.tooltip = {"players-inventory.tooltip-unmute"}

        element.parent.muted.visible = true
    end
end

-- On kick button click
---@param event Event
function MainWindow.on_kick_button_click(event)
    if not event or not event.player_index then
        return
    end

    local player = game.get_player(event.player_index)

    if not player then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    ConfirmWindow.create(player, target_player, element, ConfirmWindow.actions.kick, MainWindow.kick)
end

-- On ban button click
---@param event Event
function MainWindow.on_toggle_ban_button_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    if not element.tags or not element.tags.player_index then
        return
    end

    ---@diagnostic disable-next-line: param-type-mismatch
    local target_player = game.get_player(element.tags.player_index)

    if not target_player then
        return
    end

    if PlayersInventory.is_banned(target_player.index) then
        PlayersInventory.unban(target_player)

        local filters = MainWindow.get_window_filters(event.player_index)

        if filters.section == MainWindow.sections.banned then
            ---@diagnostic disable-next-line: param-type-mismatch
            MainWindow.remove_player(event.player_index, element.tags.player_index)
        else
            element.sprite = "players_inventory_ban_white"
            element.hovered_sprite = "players_inventory_ban_black"
            element.clicked_sprite = "players_inventory_ban_black"
            element.tooltip = {"players-inventory.tooltip-ban"}

            element.parent.banned.visible = false
        end
    else
        local player = game.get_player(event.player_index)

        if not player then
            return
        end

        ConfirmWindow.create(player, target_player, element, ConfirmWindow.actions.ban, MainWindow.ban)
    end
end


-- On GUI click event handlers setup --

MainWindow.on_gui_click_handlers = {
    ["players_inventory_close_window_button"] = MainWindow.on_close_button_click,
    ["players_inventory_clear_find_player_button"] = MainWindow.on_clear_find_player_button_click,
    ["players_inventory_refresh_list_button"] = MainWindow.on_refresh_list_button_click,
    ["players_inventory_open_inventory_button"] = MainWindow.on_open_inventory_button_click,
    ["players_inventory_fix_permossions_button"] = MainWindow.on_fix_permossions_button_click,
    ["players_inventory_follow_button"] = MainWindow.on_follow_button_click,
    ["players_inventory_toggle_favorite_button"] = MainWindow.on_toggle_favorite_button_click,
    ["players_inventory_toggle_admin_button"] = MainWindow.on_toggle_admin_button_click,
    ["players_inventory_toggle_manager_button"] = MainWindow.on_toggle_manager_button_click,
    ["players_inventory_warn_button"] = MainWindow.on_warn_button_click,
    ["players_inventory_toggle_mute_button"] = MainWindow.on_toggle_mute_button_click,
    ["players_inventory_kick_button"] = MainWindow.on_kick_button_click,
    ["players_inventory_toggle_ban_button"] = MainWindow.on_toggle_ban_button_click
}


-- Global event handlers setup --

local event_handlers = {}
event_handlers.events = {
    ["on-toggle-players-inventory-window"] = MainWindow.on_toggle_main_window,
    ["on-camera-zoom-in"] = MainWindow.on_camera_zoom_in,
    ["on-camera-zoom-out"] = MainWindow.on_camera_zoom_out,
    [defines.events.on_gui_selection_state_changed] = MainWindow.on_gui_selection_state_changed,
    [defines.events.on_gui_text_changed] = MainWindow.on_gui_text_changed,
    [defines.events.on_gui_elem_changed] = MainWindow.on_gui_elem_changed,
    [defines.events.on_gui_checked_state_changed] = MainWindow.on_gui_checked_state_changed,
    [defines.events.on_gui_closed] = MainWindow.on_gui_closed,
    [defines.events.on_gui_click] = MainWindow.on_gui_click
}
EventHandler.add_lib(event_handlers)


-- /wlist-state
-- > 0|1

-- /bot-state on|off

-- /voice-in канал ник,

-- Return --

return MainWindow
