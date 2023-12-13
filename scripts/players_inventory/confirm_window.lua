-- Copyright (c) 2023 Ajick



local ConfirmWindow = {
    params = {}
}

ConfirmWindow.actions = {
    warn = "warn",
    kick = "kick",
    ban = "ban"
}


-- Creates confirm window
---@param player LuaPlayer
---@param target_player LuaPlayer
---@param element LuaGuiElement
---@param action string
---@param handler function
---@param warnings string[]?
function ConfirmWindow.create(player, target_player, element, action, handler, warnings)
    if not player or not target_player or not element or not action or not handler then
        return
    end

    if not ConfirmWindow.actions[action] then
        return
    end

    ConfirmWindow.params[player.index] = {
        target_player = target_player,
        element = element,
        handler = handler
    }

    if player.gui.screen.players_inventory_confirm_window then
        player.gui.screen.players_inventory_confirm_window.destroy()
    end

    local window = player.gui.screen.add{
        type = "frame",
        name = "players_inventory_confirm_window",
        direction = "vertical"
    }

    -- Header --

    local titlebar = window.add{type="flow", direction="horizontal"}
    titlebar.drag_target = window

    titlebar.add{
        type = "label",
        caption = {"players-inventory.caption-action-"..action, target_player.name},
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
        name = "players_inventory_close_confirm_window_button",
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

    if action == ConfirmWindow.actions.warn then
        ---@diagnostic disable-next-line: param-type-mismatch
        local tooltip = PlayersInventory.get_warn_tooltip(warnings)

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
        caption = {"players-inventory.tooltip-"..action}
    }

    buttons.add{
        type = "button",
        name = "players_inventory_cancel_punishment_button",
        caption = {"players-inventory.caption-cancel"}
    }

    window.force_auto_center()
    reason_textbox.focus()
end

-- Returns confirm window
---@param player_index uint
function ConfirmWindow.get(player_index)
    if not player_index then
        return
    end

    local player = game.get_player(player_index)

    if not player then
        return
    end

    return player.gui.screen.players_inventory_confirm_window
end


-- Global on click event handler
---@param event Event
function ConfirmWindow.on_gui_click(event)
    if not event or not event.player_index then
        return
    end

    local element = event.element

    if not element or not element.valid then
        return
    end

    local window = ConfirmWindow.get(event.player_index)

    if not window or not window.valid then
        return
    end

    if element.name ~= "players_inventory_close_confirm_window_button"
    and element.name ~= "players_inventory_cancel_punishment_button"
    and element.name ~= "players_inventory_accept_punishment_button"
    then
        return
    end

    if element.name == "players_inventory_accept_punishment_button" then
        local params = ConfirmWindow.params[event.player_index]

        if not params then
            return
        end

        params.handler(params.target_player, params.element, window.players_inventory_reason_textbox.text)
    end

    ConfirmWindow.close(event.player_index)
end

-- Closes window
---@param player_index uint
function ConfirmWindow.close(player_index)
    if not player_index then
        return
    end

    local window = ConfirmWindow.get(player_index)

    if not window or not window.valid then
        return
    end

    window.destroy()
    ConfirmWindow.params[player_index] = nil
end


-- Global event handlers setup --

local event_handlers = {}
event_handlers.events = {
    [defines.events.on_gui_click] = ConfirmWindow.on_gui_click
}
EventHandler.add_lib(event_handlers)


-- Return --

return ConfirmWindow