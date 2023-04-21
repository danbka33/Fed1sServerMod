local mod_gui = require("__core__/lualib/mod-gui")
local Informatron = {
    name_root = "informatron",
    name_title_flow = "titlebar",
    name_time_label = "game-time",
    name_main_flow = "main-flow",
    name_menu_frame = "menu-frame",
    name_menu_pane = "menu-pane",

    name_content_container = "content-container",
    name_content_subheader = "content-subheader",
    name_content_path = "content-path",
    name_content_title = "content-title",
    name_content_flow = "content-flow",
    name_content_pane = "content-pane",

    content_width = 940,

    name_event = "informatron",
    name_lua_shortcut = "informatron",
    name_setting_overhead_button = "informatron-show-overhead-button",
    show_message_on_center = "informatron-show-message-on-center",

    name_overhead_button = "informatron_overhead",
    name_overhead_admin_text = "fed1s_admin_text",


    action_close_button = "close-gui"
}

Informatron.path_menu_pane = {
    Informatron.name_main_flow,
    Informatron.name_menu_frame,
    Informatron.name_menu_pane
}
Informatron.path_content_subheader = {
    Informatron.name_main_flow,
    Informatron.name_content_container,
    Informatron.name_content_subheader,
}
Informatron.path_content_pane = {
    Informatron.name_main_flow,
    Informatron.name_content_container,
    Informatron.name_content_pane
}

---Safely traverses the given path to obtain a `LuaGuiElement`.
---@param parent LuaGuiElement Parent element to begin traversal from
---@param path string[] Array of names of elements to traverse
---@return LuaGuiElement? element
local function _get_gui_element(parent, path)
    local element = parent

    for _, level in pairs(path) do
        if element[level] then
            element = element[level]
        else
            return
        end
    end

    return element
end

---Gets (and if necessary makes) a `PlayerData` table for the given player in `global`.
---@param player_index uint Player index
function Informatron.get_make_playerdata(player_index)
    global.playerdata = global.playerdata or {}
    global.playerdata[player_index] = global.playerdata[player_index] or {}
    return global.playerdata[player_index]
end

function Informatron.update_overhead_texts(player)
    local gui = player.gui.center



    local playerData = Informatron.get_make_playerdata(player.index)

    local adminText = gui[Informatron.name_overhead_admin_text]

    if not player.mod_settings[Informatron.show_message_on_center].value then
        if adminText then
            adminText.destroy()
        end
        return
    end

    if gui and playerData and playerData.role then
        local isManager = player.permission_group.name == "Manager"
        local isAdmin = player.permission_group.name == "Admin"
        local playerRole = playerData.role

        if not adminText then
            gui.add {
                type = "flow",
                direction = "vertical",
                name = Informatron.name_overhead_admin_text
            }
            adminText = gui[Informatron.name_overhead_admin_text]
            adminText.style.top_margin = 200;
            adminText.ignored_by_interaction = true
        end

        for _, name in pairs(adminText.children_names) do
            adminText[name].destroy()
        end

        for key, message in pairs(Informatron.get_make_admin_texts()) do
            if not (player.name == message.playerName) and ((isAdmin) or (message.admin) or (message.manager and isManager) or (message.manager and message.role == playerRole)) then
                adminText.add {
                    type = "label",
                    name = Informatron.name_overhead_admin_text .. "_" .. key,
                    caption = { "Fed1sServerMod.admin_text", "[img=utility.notification] " .. message.message .. " [img=utility.notification]" }
                }
                adminText[Informatron.name_overhead_admin_text .. "_" .. key].style.font = "adminFont"
                --adminText[Informatron.name_overhead_admin_text .. "_" .. key].style.content_width = 940
                adminText[Informatron.name_overhead_admin_text .. "_" .. key].style.single_line = false

                local textColor = { r = 1, g = 1, b = 0 }
                if (message.manager) then
                    textColor = { r = 0, g = 1, b = 0 }
                end
                adminText[Informatron.name_overhead_admin_text .. "_" .. key].style.font_color = textColor

            end
        end

    end
end


---Makes or destroys the overhead button depending on player setting.
---@param player LuaPlayer Player
function Informatron.update_overhead_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow then
        return
    end

    local button = button_flow[Informatron.name_overhead_button]

    if player.mod_settings[Informatron.name_setting_overhead_button].value then
        if not button then
            button_flow.add {
                type = "sprite-button",
                name = Informatron.name_overhead_button,
                sprite = "virtual-signal/informatron"
            }
        end
    elseif button then
        button.destroy()
    end
end

---Gets the Informatron GUI of a given player, if open.
---@param player LuaPlayer
---@return LuaGuiElement? root
function Informatron.get(player)
    return player.gui.screen[Informatron.name_root]
end

---Opens the Informatron GUI for a given player.
---@param player LuaPlayer Player to open GUI for
---@param target_page any
function Informatron.open(player, target_page)
    if Informatron.get(player) then
        Informatron.close(player)
    end

    local player_index = player.index

    local root = player.gui.screen.add {
        type = "frame",
        direction = "vertical",
        name = Informatron.name_root,
        style = "informatron_root_frame"
    }

    -- Check in case another mod destroyed the GUI upon setting `player.opened`
    root.force_auto_center()
    player.opened = root
    if not root.valid then
        return
    end

    do
        -- Titlebar
        local titlebar = root.add {
            type = "flow",
            name = Informatron.name_title_flow,
            direction = "horizontal",
            style = "informatron_titlebar_flow"
        }
        titlebar.drag_target = root
        titlebar.add { -- Title
            type = "label",
            caption = { "informatron.window_title_label" },
            ignored_by_interaction = true,
            style = "frame_title"
        }
        titlebar.add {
            type = "empty-widget",
            ignored_by_interaction = true,
            style = "informatron_drag_handle"
        }
        titlebar.add {
            type = "label",
            name = Informatron.name_time_label,
            style = "informatron_time_label",
            caption = { "Fed1sServerMod.discord_link" }
        }
        titlebar.add { -- Close button
            type = "sprite-button",
            sprite = "utility/close_white",
            hovered_sprite = "utility/close_black",
            clicked_sprite = "utility/close_black",
            tags = { root = Informatron.name_root, action = Informatron.action_close_button },
            style = "close_button"
        }
    end

    local main_flow = root.add {
        type = "flow",
        name = Informatron.name_main_flow,
        direction = "horizontal",
        style = "informatron_main_flow"
    }

    -- Content
    local content_container = main_flow.add {
        type = "frame",
        name = Informatron.name_content_container,
        direction = "vertical",
        style = "informatron_content_frame"
    }

    content_container.add {
        type = "scroll-pane",
        name = Informatron.name_content_pane,
        style = "informatron_content_scroll_pane"
    }

    if target_page and target_page.interface and remote.interfaces[target_page.interface] then
        Informatron.display(player, target_page.interface, target_page.page_name)
    else
        local last_page = Informatron.get_make_playerdata(player.index).last_page
        if last_page and last_page.interface and remote.interfaces[last_page.interface] then
            Informatron.display(player, last_page.interface, last_page.page_name)
        else
            Informatron.display(player, "informatron", "informatron")
        end
    end
end

---Opens/closes Informatron depending on its existing state.
---@param player LuaPlayer Player
function Informatron.toggle(player)
    local root = Informatron.get(player)

    if root then
        Informatron.close(player)
    else
        Informatron.open(player)
    end
end

---Displays a given interface/page_name.
---@param player LuaPlayer Player
---@param interface string Name of interface
---@param page_name string Page name
function Informatron.display(player, interface, page_name)
    local root = Informatron.get(player) --[[@as LuaGuiElement]]
    local content = _get_gui_element(root, Informatron.path_content_pane) --[[@as LuaGuiElement]]
    local player_index = player.index

    content.clear()
    if remote.interfaces[interface]["informatron_page_content"] then
        remote.call(interface, "informatron_page_content",
                { player_index = player_index, page_name = page_name, element = content })
    end

    -- Make sure all direct descendents are squashable
    for _, child in pairs(content.children) do
        child.style.horizontally_squashable = true
        child.style.maximal_width = Informatron.content_width - 52
        if child.type == "label" then
            child.style.single_line = false
        end
    end

    content.scroll_to_top()

    Informatron.get_make_playerdata(player_index).last_page = {
        interface = interface,
        page_name = page_name
    }
end

---Updates the Informatron GUI of a given player
---@param player LuaPlayer Player
---@param tick uint Game tick
function Informatron.update(player, tick)
    local root = Informatron.get(player)
    if not root then
        return
    end

    local player_index = player.index
    local last_page = Informatron.get_make_playerdata(player_index).last_page
    if not (last_page and last_page.interface and last_page.page_name) then
        return
    end

    local interface = last_page.interface
    local page_name = last_page.page_name
    local content = _get_gui_element(root, Informatron.path_content_pane) --[[@as LuaGuiElement]]

    if remote.interfaces[interface]["informatron_page_content_update"] then
        remote.call(interface, "informatron_page_content_update",
                { player_index = player_index, page_name = page_name, element = content })
    end

    for _, child in pairs(content.children) do
        child.style.horizontally_squashable = true
        child.style.maximal_width = Informatron.content_width - 52
        if child.type == "label" then
            child.style.single_line = false
        end
    end
end

---Closes the informatron GUI for the given player
function Informatron.close(player)
    local root = Informatron.get(player)
    if root then
        root.destroy()
    end
end

function Informatron.get_make_admin_texts()
    if not global.adminTexts then
        global.adminTexts = {}
    end

    return global.adminTexts
end

---Initializes informatron.
function Informatron.on_init()
    global.open_informatron_check = true

    global.adminTexts = {}
    Stats.init()

    -- In case mod is being added mid-game
    for _, player in pairs(game.players) do
        Stats.update_overhead_stat(player)
        Informatron.update_overhead_button(player)
        Informatron.update_overhead_texts(player)
    end
end
--script.on_init(Informatron.on_init)

---Handles mod changes.
function Informatron.on_configuration_changed()
    for _, player in pairs(game.players) do
        -- Destroy old Informatron windows if they're open
        if player.gui.center["informatron_main"] then
            player.gui.center["informatron_main"].destroy()
        end
        if player.gui.screen["informatron_main"] then
            player.gui.screen["informatron_main"].destroy()
        end

        -- Refresh overhead buttons
        Informatron.update_overhead_button(player)
        Stats.update_overhead_stat(player)

        -- If a player had Informatron open, close/reopen it to refresh its contents
        local root = Informatron.get(player)
        if root then
            Informatron.close(player)
            Informatron.open(player)
        end
    end
end
script.on_configuration_changed(Informatron.on_configuration_changed)

---Handles changes to the overhead button setting.
---@param event EventData.on_runtime_mod_setting_changed Event data
function Informatron.on_runtime_mod_setting_changed(event)
    if event.player_index and event.setting == Informatron.name_setting_overhead_button then
        Informatron.update_overhead_button(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
    if event.player_index and event.setting == Informatron.show_message_on_center then
        Informatron.update_overhead_texts(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
    if event.player_index and event.setting == Stats.show_stats then
        Stats.update_overhead_stat(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
end
script.on_event(defines.events.on_runtime_mod_setting_changed,
        Informatron.on_runtime_mod_setting_changed)

---Handles new player creation.
---@param event EventData.on_player_created Event data
function Informatron.on_player_created(event)
    Informatron.update_overhead_button(game.get_player(event.player_index) --[[@as LuaPlayer]])
    Informatron.update_overhead_texts(game.get_player(event.player_index)) --[[@as LuaPlayer]]
    Stats.update_overhead_stat(game.get_player(event.player_index)) --[[@as LuaPlayer]]
    global.open_informatron_check = true -- triggers a check in `on_nth_tick_60`

    local playerData = Informatron.get_make_playerdata(event.player_index)
    playerData.applied = false
    playerData.role = 'default'
end
--script.on_event(defines.events.on_player_created, Informatron.on_player_created)

---Calls update functions every second.
---@param event NthTickEventData Event data
function Informatron.on_nth_tick_60(event)

    if Informatron.get_make_admin_texts() then
        for key, value in pairs(Informatron.get_make_admin_texts()) do
            if event.tick > (value.tick + 60 * 15) then
                Informatron.get_make_admin_texts()[key] = nil

                for _, player in pairs(game.players) do
                    Informatron.update_overhead_texts(player)
                end
            end
        end
    end

    if global.open_informatron_check and event.tick >= 1200 then
        for _, player in pairs(game.connected_players) do
            local playerdata = Informatron.get_make_playerdata(player.index)
            if not playerdata.applied then
                Informatron.open(player)
            end
        end
        global.open_informatron_check = nil
    end

    for _, player in pairs(game.connected_players) do
        local playerdata = Informatron.get_make_playerdata(player.index)
        if not playerdata.applied then
            game.permissions.get_group("PickRole").add_player(player)
            local root = Informatron.get(player)

            if not root then
                Informatron.open(player)
            end
        end
    end

    for _, player in pairs(game.connected_players) do
        Stats.update_overhead_stat(player)
        Informatron.update(player, event.tick)
    end
end

---Handles gui clicks, including for the overhead button.
---@param event EventData.on_gui_click Event data
function Informatron.on_gui_click(event)
    if event.element.name == Informatron.name_overhead_button then
        Informatron.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
        return
    end
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    if event.element.name == "fed1s_warrior" then
        local playerData = Informatron.get_make_playerdata(event.player_index)
        if not playerData.applied then
            game.permissions.get_group("Default").add_player(player)
        end

        playerData.applied = true
        playerData.role = "warrior"
        Informatron.close(player)
        apply_player_color(event.player_index)

        return
    elseif event.element.name == "fed1s_defender" then
        local playerData = Informatron.get_make_playerdata(event.player_index)
        if not playerData.applied then
            game.permissions.get_group("Default").add_player(player)
        end
        playerData.applied = true
        playerData.role = "defender"
        Informatron.close(player)
        apply_player_color(event.player_index)

        return
    elseif event.element.name == "fed1s_builder" then
        local playerData = Informatron.get_make_playerdata(event.player_index)
        if not playerData.applied then
            game.permissions.get_group("Default").add_player(player)
        end
        playerData.applied = true
        playerData.role = "builder"
        Informatron.close(player)
        apply_player_color(event.player_index)
        return
    elseif event.element.name == "fed1s_service" then
        local playerData = Informatron.get_make_playerdata(event.player_index)
        if not playerData.applied then
            game.permissions.get_group("Default").add_player(player)
        end
        playerData.applied = true
        playerData.role = "service"
        Informatron.close(player)
        apply_player_color(event.player_index)
        return
    end

    game.print(event.element.name);

    if event.element.tags.root ~= "informatron" then
        return
    end

    local tags = event.element.tags
    local action = tags.action

    if action == Informatron.action_close_button then
        Informatron.close(player)
    elseif action == Informatron.action_menu_button then
        Informatron.display(
                player,
                tags.interface --[[@as string]],
                tags.page_name --[[@as string]]
        )
    end


end
--script.on_event(defines.events.on_gui_click, Informatron.on_gui_click)

---Closes the Informtron GUI when the player uses `E` or `Esc`.
---@param event EventData.on_gui_closed Event data
function Informatron.on_gui_closed(event)
    if event.element and event.element.name == Informatron.name_root then
        Informatron.close(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
end
script.on_event(defines.events.on_gui_closed, Informatron.on_gui_closed)

---Handles the keyboard shortcut for Informatron being used.
---@param event EventData.CustomInputEvent Event data
function Informatron.on_keyboard_shortcut(event)
    Informatron.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
end
script.on_event(Informatron.name_event, Informatron.on_keyboard_shortcut)

---Handles the lua shortcut getting clicked.
---@param event EventData.on_lua_shortcut Event data
function Informatron.on_lua_shortcut(event)
    if event.prototype_name == Informatron.name_lua_shortcut then
        Informatron.toggle(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
end
script.on_event(defines.events.on_lua_shortcut, Informatron.on_lua_shortcut)

return Informatron
