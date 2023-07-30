local mod_gui = require("__core__/lualib/mod-gui")
local ServerMod = {
    name_root = "server_mod",
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

    name_event = "server_mod",
    name_lua_shortcut = "server_mod",
    name_setting_overhead_button = "server_mod-show-overhead-button",

    name_overhead_button = "server_mod_overhead",

    action_close_button = "close-gui"
}

ServerMod.path_menu_pane = {
    ServerMod.name_main_flow,
    ServerMod.name_menu_frame,
    ServerMod.name_menu_pane
}
ServerMod.path_content_subheader = {
    ServerMod.name_main_flow,
    ServerMod.name_content_container,
    ServerMod.name_content_subheader,
}
ServerMod.path_content_pane = {
    ServerMod.name_main_flow,
    ServerMod.name_content_container,
    ServerMod.name_content_pane
}

ServerMod.roles = {
    warrior = "warrior",
    defender = "defender",
    builder = "builder"
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
function ServerMod.get_make_playerdata(player_index)
    global.playerdata = global.playerdata or {}
    global.playerdata[player_index] = global.playerdata[player_index] or {}
    return global.playerdata[player_index]
end

---Sets player role
---@param player LuaPlayer
---@param player string, member of ServerMod.roles
function ServerMod.set_role(player_index, role)
    if not player_index then
        return
    end

    if not ServerMod.roles[role] then
        return
    end

    local playerData = ServerMod.get_make_playerdata(player_index)
    
    if not playerData.applied then
        playerData.applied = true
    end

    playerData.role = role
end

---Makes or destroys the overhead button depending on player setting.
---@param player LuaPlayer Player
function ServerMod.update_overhead_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    if not button_flow then
        return
    end

    if button_flow["informatron_overhead"] then
        button_flow["informatron_overhead"].destroy()
    end

    local button = button_flow[ServerMod.name_overhead_button]

    if player.mod_settings[ServerMod.name_setting_overhead_button].value then
        if not button then
            button_flow.add {
                type = "sprite-button",
                name = ServerMod.name_overhead_button,
                sprite = "virtual-signal/server_mod"
            }
        end
    elseif button then
        button.destroy()
    end
end

---Gets the ServerMod GUI of a given player, if open.
---@param player LuaPlayer
---@return LuaGuiElement? root
function ServerMod.get(player)
    return player.gui.screen[ServerMod.name_root]
end

---Opens the ServerMod GUI for a given player.
---@param player LuaPlayer Player to open GUI for
---@param target_page any
function ServerMod.open(player, target_page)
    if ServerMod.get(player) then
        ServerMod.close(player)
    end

    local player_index = player.index

    local root = player.gui.screen.add {
        type = "frame",
        direction = "vertical",
        name = ServerMod.name_root,
        style = "server_mod_root_frame"
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
            name = ServerMod.name_title_flow,
            direction = "horizontal",
            style = "server_mod_titlebar_flow"
        }
        titlebar.drag_target = root
        titlebar.add { -- Title
            type = "label",
            caption = { "server_mod.window_title_label" },
            ignored_by_interaction = true,
            style = "frame_title"
        }
        titlebar.add {
            type = "empty-widget",
            ignored_by_interaction = true,
            style = "server_mod_drag_handle"
        }

        local playerData = ServerMod.get_make_playerdata(player.index)
        if playerData.applied then
            titlebar.add { -- Close button
                type = "sprite-button",
                sprite = "utility/close_white",
                hovered_sprite = "utility/close_black",
                clicked_sprite = "utility/close_black",
                tags = { root = ServerMod.name_root, action = ServerMod.action_close_button },
                style = "close_button"
            }
        end
    end

    local main_flow = root.add {
        type = "flow",
        name = ServerMod.name_main_flow,
        direction = "horizontal",
        style = "server_mod_main_flow"
    }

    -- Content
    local content_container = main_flow.add {
        type = "frame",
        name = ServerMod.name_content_container,
        direction = "vertical",
        style = "server_mod_content_frame"
    }

    content_container.add {
        type = "scroll-pane",
        name = ServerMod.name_content_pane,
        style = "server_mod_content_scroll_pane"
    }

    if target_page and target_page.interface and remote.interfaces[target_page.interface] then
        ServerMod.display(player, target_page.interface, target_page.page_name)
    else
        local last_page = ServerMod.get_make_playerdata(player.index).last_page
        
        if last_page and last_page.interface and remote.interfaces[last_page.interface] then
            ServerMod.display(player, last_page.interface, last_page.page_name)
        else
            ServerMod.display(player, "server_mod", "server_mod")
        end
    end
end

---Opens/closes ServerMod depending on its existing state.
---@param player LuaPlayer Player
function ServerMod.toggle(player)
    local root = ServerMod.get(player)

    if root then
        ServerMod.close(player)
    else
        ServerMod.open(player)
    end
end

---Displays a given interface/page_name.
---@param player LuaPlayer Player
---@param interface string Name of interface
---@param page_name string Page name
function ServerMod.display(player, interface, page_name)
    local root = ServerMod.get(player) --[[@as LuaGuiElement]]
    local content = _get_gui_element(root, ServerMod.path_content_pane) --[[@as LuaGuiElement]]
    local player_index = player.index

    content.clear()
    if remote.interfaces[interface]["server_mod_page_content"] then
        remote.call(interface, "server_mod_page_content",
                { player_index = player_index, page_name = page_name, element = content })
    end

    -- Make sure all direct descendents are squashable
    for _, child in pairs(content.children) do
        child.style.horizontally_squashable = true
        child.style.maximal_width = ServerMod.content_width - 52
        if child.type == "label" then
            child.style.single_line = false
        end
    end

    content.scroll_to_top()

    ServerMod.get_make_playerdata(player_index).last_page = {
        interface = interface,
        page_name = page_name
    }
end

---Updates the ServerMod GUI of a given player
---@param player LuaPlayer Player
---@param tick uint Game tick
function ServerMod.update(player, tick)
    local root = ServerMod.get(player)

    if not root then
        return
    end

    local player_index = player.index
    local last_page = ServerMod.get_make_playerdata(player_index).last_page

    if not (last_page and last_page.interface and last_page.page_name) then
        return
    end

    local interface = last_page.interface
    local page_name = last_page.page_name
    local content = _get_gui_element(root, ServerMod.path_content_pane) --[[@as LuaGuiElement]]

    if remote.interfaces[interface]["server_mod_page_content_update"] then
        remote.call(interface, "server_mod_page_content_update",
                { player_index = player_index, page_name = page_name, element = content })
    end

    for _, child in pairs(content.children) do
        child.style.horizontally_squashable = true
        child.style.maximal_width = ServerMod.content_width - 52
        if child.type == "label" then
            child.style.single_line = false
        end
    end
end

---Closes the server_mod GUI for the given player
function ServerMod.close(player)
    local root = ServerMod.get(player)

    if root then
        root.destroy()
    end
end

---Initializes server_mod.
function ServerMod.on_init()
    -- In case mod is being added mid-game
    for _, player in pairs(game.players) do
        ServerMod.update_overhead_button(player)
        Permissions.set_group(player, Permissions.groups.pick_role)
        ServerMod.open(player)
    end
end

---Handles mod changes.
function ServerMod.on_configuration_changed()
    for _, player in pairs(game.players) do
        -- Refresh overhead buttons
        ServerMod.update_overhead_button(player)

        -- If a player had ServerMod open, close/reopen it to refresh its contents
        local root = ServerMod.get(player)

        if root then
            ServerMod.close(player)
            ServerMod.open(player)
        end
    end
end

---Handles changes to the overhead button setting.
---@param event EventData.on_runtime_mod_setting_changed Event data
function ServerMod.on_runtime_mod_setting_changed(event)
    if event.player_index and event.setting == ServerMod.name_setting_overhead_button then
        ServerMod.update_overhead_button(game.get_player(event.player_index) --[[@as LuaPlayer]])
    end
end

---Handles new player creation.
---@param event EventData.on_player_created Event data
function ServerMod.on_player_created(event)
    local player = game.get_player(event.player_index)

    if not ServerMod.created then
        ServerMod.created = {}
    end

    ServerMod.created[player.index] = true

    ServerMod.update_overhead_button(player)

    if not game.is_multiplayer() and player.admin then
        Permissions.set_group(player, Permissions.groups.admin)
        return
    end

    Permissions.set_group(player, Permissions.groups.pick_role)
    PlayerColor.apply_player_color(player)
    ServerMod.open(player)
end

function ServerMod.on_player_joined_game(event)
    if ServerMod.created and ServerMod.created[event.player_index] then
        ServerMod.created[event.player_index] = nil
        return
    end

    local player = game.get_player(event.player_index)

    ServerMod.update_overhead_button(player)

    if not game.is_multiplayer() and player.admin
    and not Permissions.in_group(player, Permissions.groups.admin)
    then
        Permissions.set_group(player, Permissions.groups.admin)
        return
    end

    local playerData = ServerMod.get_make_playerdata(player.index)

    if not playerData.applied then
        Permissions.set_group(player, Permissions.groups.pick_role)
        PlayerColor.apply_player_color(player)
        ServerMod.open(player)
        return
    end

    if player.admin and not Permissions.in_group(player, Permissions.groups.admin) then
        Permissions.set_group(player, Permissions.groups.admin)
        PlayerColor.apply_player_color(player)
    elseif playerData.manager and not Permissions.in_group(player, Permissions.groups.manager) then
        Permissions.set_group(player, Permissions.groups.manager)
        PlayerColor.apply_player_color(player)
    elseif not Permissions.in_group(player, Permissions.groups.default) then
        Permissions.set_group(player, Permissions.groups.default)
        PlayerColor.apply_player_color(player)
    end

end

function ServerMod.on_player_promoted(event)
    local player = game.players[event.player_index]
    local playerData = ServerMod.get_make_playerdata(player.index)

    if not playerData.applied then
        return
    end

    game.permissions.get_group(Permissions.groups.admin).add_player(player)
    PlayerColor.apply_player_color(player)
end

function ServerMod.on_player_demoted(event)
    local player = game.players[event.player_index]
    local playerData = ServerMod.get_make_playerdata(player.index)

    if not playerData.applied then
        return
    end

    if playerData.manager and not Permissions.in_group(player, Permissions.groups.manager) then
        Permissions.set_group(player, Permissions.groups.manager)
    else
        Permissions.set_group(player, Permissions.groups.default)
    end

    PlayerColor.apply_player_color(player)
end

---Calls update functions every second.
---@param event NthTickEventData Event data
function ServerMod.on_nth_tick_60(event)
    -- for _, player in pairs(game.connected_players) do
    --     local playerData = ServerMod.get_make_playerdata(player.index)

    --     if not playerData.applied then
    --         local root = ServerMod.get(player)

    --         if not root then
    --             ServerMod.open(player)
    --         end
    --     end

    --     -- ServerMod.update(player, event.tick)
    -- end
end

---Handles gui clicks, including for the overhead button.
---@param event EventData.on_gui_click Event data
function ServerMod.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    if event.element.name == ServerMod.name_overhead_button then
        local playerData = ServerMod.get_make_playerdata(player.index)

        if playerData.applied then
            ServerMod.toggle(player --[[@as LuaPlayer]])
        end

        return
    end

    if event.element.name == "fed1s_warrior" then
        local playerData = ServerMod.get_make_playerdata(player.index)

        if player.admin and not Permissions.in_group(player, Permissions.groups.admin) then
            Permissions.set_group(player, Permissions.groups.admin)
        elseif playerData.manager and not Permissions.in_group(player, Permissions.groups.manager) then
            Permissions.set_group(player, Permissions.groups.manager)
        elseif not Permissions.in_group(player, Permissions.groups.default) then
            Permissions.set_group(player, Permissions.groups.default)
        end

        ServerMod.set_role(player.index, ServerMod.roles.warrior)
        PlayerColor.apply_player_color(player)
        ServerMod.close(player)

        return
    elseif event.element.name == "fed1s_defender" then
        local playerData = ServerMod.get_make_playerdata(player.index)

        if player.admin and not Permissions.in_group(player, Permissions.groups.admin) then
            Permissions.set_group(player, Permissions.groups.admin)
        elseif playerData.manager and not Permissions.in_group(player, Permissions.groups.manager) then
            Permissions.set_group(player, Permissions.groups.manager)
        elseif not Permissions.in_group(player, Permissions.groups.default) then
            Permissions.set_group(player, Permissions.groups.default)
        end

        ServerMod.set_role(player.index, ServerMod.roles.defender)
        PlayerColor.apply_player_color(player)
        ServerMod.close(player)

        return
    elseif event.element.name == "fed1s_builder" then
        local playerData = ServerMod.get_make_playerdata(player.index)

        if player.admin and not Permissions.in_group(player, Permissions.groups.admin) then
            Permissions.set_group(player, Permissions.groups.admin)
        elseif playerData.manager and not Permissions.in_group(player, Permissions.groups.manager) then
            Permissions.set_group(player, Permissions.groups.manager)
        elseif not Permissions.in_group(player, Permissions.groups.default) then
            Permissions.set_group(player, Permissions.groups.default)
        end

        ServerMod.set_role(player.index, ServerMod.roles.builder)
        PlayerColor.apply_player_color(player)
        ServerMod.close(player)

        return
    end

    if event.element.tags.root ~= "server_mod" then
        return
    end

    local tags = event.element.tags
    local action = tags.action

    if action == ServerMod.action_close_button then
        ServerMod.close(player)
    elseif action == ServerMod.action_menu_button then
        ServerMod.display(
                player,
                tags.interface --[[@as string]],
                tags.page_name --[[@as string]]
        )
    end
end

---Closes the Informtron GUI when the player uses `E` or `Esc`.
---@param event EventData.on_gui_closed Event data
function ServerMod.on_gui_closed(event)
    if not event.player_index then
        return
    end

    if event.gui_type ~= defines.gui_type.custom then
        return
    end

    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == ServerMod.name_root then
        local playerData = ServerMod.get_make_playerdata(event.player_index)

        if not playerData.applied then
            return
        end

        ServerMod.close(game.get_player(event.player_index))
    end
end

local event_handlers = {}
event_handlers.on_init = ServerMod.on_init
event_handlers.on_nth_tick = {[60] = ServerMod.on_nth_tick_60}
event_handlers.on_configuration_changed = ServerMod.on_configuration_changed
event_handlers.events = {
    [defines.events.on_runtime_mod_setting_changed] = ServerMod.on_runtime_mod_setting_changed,
    [defines.events.on_player_created] = ServerMod.on_player_created,
    [defines.events.on_player_joined_game] = ServerMod.on_player_joined_game,
    [defines.events.on_player_promoted] = ServerMod.on_player_promoted,
    [defines.events.on_player_demoted] = ServerMod.on_player_demoted,
    [defines.events.on_gui_closed] = ServerMod.on_gui_closed,
    [defines.events.on_gui_click] = ServerMod.on_gui_click
}
EventHandler.add_lib(event_handlers)


commands.add_command("reinit", "", function(event)
    if not event.player_index then
        return
    end
    
    if not game.players[event.player_index].admin then
        return
    end

    for _, group in pairs(game.permissions.groups) do
        for _, permission in pairs(defines.input_action) do
            group.set_allows_action(permission, true)
        end
    end

    Permissions.create_groups_and_apply_permissions()

    for _, player in pairs(game.players) do
        local player_data = ServerMod.get_make_playerdata(player.index)

        if player.admin and not Permissions.in_group(player, Permissions.groups.admin) then
            Permissions.set_group(player, Permissions.groups.admin)
        elseif Permissions.in_group(player, Permissions.groups.manager) then
            player_data.manager = true
        end

        if not player_data.applied then
            Permissions.set_group(player, Permissions.groups.pick_role)
        end

        PlayerColor.apply_player_color(player)
    end
end)


return ServerMod
