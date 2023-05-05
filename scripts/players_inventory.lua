-- Copyright (c) 2023 Ajick

local event_handler = require("__core__/lualib/event_handler")
local mod_gui = require("__core__/lualib/mod-gui")

local get_make_playerdata = require("__Fed1sServerMod__/scripts/server_mod").get_make_playerdata


local PlayersInventory = {}


PlayersInventory.filter_items = {
	"blueprint",
	"blueprint-book",
	"upgrade-planner",
	"deconstruction-planner",
	"car",
	"tank",
	"spidertron",
	"spidertron-remote",
	"pistol",
	"submachine-gun",
	"shotgun",
	"combat-shotgun",
	"rocket-launcher",
	"flamethrower",
	"light-armor",
	"heavy-armor",
	"modular-armor",
	"power-armor",
	"power-armor-mk2"
}

PlayersInventory.filter_roles = {"warrior", "defender", "builder"} -- , "service"


function PlayersInventory.add_players_inventory_gui_button(player)
	local gui_flow = mod_gui.get_button_flow(player)
	local gui_button = gui_flow["toggle-players-inventory-window-button"]

	if not player.admin then
		if gui_button then
			gui_button.destroy()
		end

		return
	end

	if gui_button then
		return
	end

	gui_flow.add{
		type = "sprite-button",
		sprite = "utility/slot_icon_armor_black",
		name = "toggle-players-inventory-window-button",
		tooltip = {"players-inventory.caption"}
	}
end

function PlayersInventory.manage_players_inventory_gui_button()
	for _, player in pairs(game.players) do
		PlayersInventory.add_players_inventory_gui_button(player)
	end
end

function PlayersInventory.build_players_inventory_window(player)
	local window = player.gui.screen.add{type="frame", name="players-inventory-window", direction="vertical"}
	window.style.maximal_height = 800


	-- Header --------------------------------------------------------------------------------------------------------------
	local titlebar = window.add{type="flow", direction="horizontal"}
	titlebar.drag_target = window

	titlebar.add{type="label", caption={"players-inventory.caption"}, ignored_by_interaction=true, style="frame_title"}

	local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
	spacer.style.horizontally_stretchable = "on"
	spacer.style.height = 24
	spacer.style.left_margin = 4
	spacer.style.right_margin=4
	
	titlebar.add{
		type = "sprite-button",
		name = "close-players-inventory-window-button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button"
	}


	-- Filters -------------------------------------------------------------------------------------------------------------
	local filter_flow = window.add{type="flow", name="filters-flow", direction="horizontal"}
	filter_flow.style.top_margin = 3

	filter_flow.add{
		type = "switch",
		name = "filter-connected",
		allow_none_state = true,
		switch_state = "left",
		left_label_caption={"players-inventory.caption-online"},
		right_label_caption={"players-inventory.caption-offline"}
	}
	
	local roles = {
		{"players-inventory.caption-all"},
		{"players-inventory.caption-warriors"},
		{"players-inventory.caption-defenders"},
		{"players-inventory.caprion-builders"}
	}
	-- {"players-inventory.caption-service"}

	local filter_roles = filter_flow.add{type="drop-down", name="filter-role", items=roles, selected_index=1}
	filter_roles.style.left_margin = 10
	filter_roles.style.top_margin = -3


	local spacer = filter_flow.add{type="empty-widget", ignored_by_interaction=true}
	spacer.style.horizontally_stretchable = "on"

	local search_icon = filter_flow.add{
		type = "sprite",
		sprite = "utility/search_white"
	}
	search_icon.style.top_margin = 3

	local search_field = filter_flow.add{type="textfield", name="filter-search"}
	search_field.style.width = 125
	search_field.style.top_margin = -4
	
	
	-- Empty placeholder ---------------------------------------------------------------------------------------------------
	local empty_flow = window.add{type="flow", name="empty-flow", direction="vertical"}
	empty_flow.style.width = 468
	empty_flow.style.height = 150
	empty_flow.style.horizontal_align = "center"
	empty_flow.style.vertical_align = "center"
	empty_flow.visible = false

	empty_flow.add{type="sprite", sprite="utility/ghost_time_to_live_modifier_icon"}
	empty_flow.add{type="label", caption={"players-inventory.caption-empty"}, style="inventory_label"}

	
	-- Players list --------------------------------------------------------------------------------------------------------
	local main_flow = window.add{type="scroll-pane", name="main-flow", direction="vertical"}
	main_flow.style.top_margin = 3

	local count_flow = window.add{type="flow", name="count-flow", direction="horizontal"}
	count_flow.style.top_margin = 5
	count_flow.visible = false

	local count = count_flow.add{type="label", name="count", style="subheader_caption_label"}
	count.style.left_margin = -8

	return window
end

function PlayersInventory.build_players_inventory_list(window)
	local players_list = window["main-flow"]
	local filters = window["filters-flow"]
	local connected_state = filters["filter-connected"].switch_state
	local role_index = filters["filter-role"].selected_index
	local search_name = string.lower(filters["filter-search"].text)
	local count = 0

	for _, panel in pairs(players_list.children) do
		panel.destroy()
	end

	for _, player in pairs(game.players) do
		if player.admin then
			goto continue
		end

		if connected_state
		and (connected_state == "left" and not player.connected)
		or (connected_state == "right" and player.connected) then
			goto continue
		end

		local playerdata = get_make_playerdata(player.index)

		if role_index ~= 1 and playerdata.role ~= PlayersInventory.filter_roles[role_index-1] then
			goto continue
		end

		if search_name and not string.find(string.lower(player.name), search_name) then
			goto continue
		end

		for i=1, 15 do
			PlayersInventory.build_player_inventory_panel(window, player)
		end

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

function PlayersInventory.build_player_inventory_panel(window, player)
	local panel = window["main-flow"].add{
		type = "frame",
		direction = "vertical",
		tags = {player_index=player.index}
	}
	panel.style.padding = 8


	local header = panel.add{type="flow"}
	header.style.width = 448

	header.add{
		type = "sprite-button",
		name = "expand-player-inventory-button",
		sprite = "utility/expand",
		hovered_sprite = "utility/expand_dark",
		clicked_sprite = "utility/expand_dark",
		style = "frame_action_button"
	}

	header.add{type="label", caption=player.name, style="subheader_caption_label"}

	local playerdata = get_make_playerdata(player.index)

	if playerdata.applied then
		header.add{type="label", caption={"players-inventory.label-"..playerdata.role}}
	end

	if player.permission_group.name == "Manager" then
		header.add{type="label", caption={"players-inventory.label-manager"}}
	end

	if player.connected then
		header.add{type="label", caption={"players-inventory.label-online"}}
	else
		header.add{type="label", caption={"players-inventory.label-offline"}}
	end

	-- player.last_online

	local content = panel.add{type="flow", name="content", direction="vertical"}
	content.visible = false

	local resources = content.add{type="table", name="resources", column_count=10}
	resources.style.top_margin = 8
	resources.style.left_margin = 2
	resources.style.padding = 2


	PlayersInventory.build_player_inventory_grid(resources, player)

	-- get_inventory(inventory)
	-- defines.inventory.character_guns
	-- defines.inventory.character_ammo
	-- defines.inventory.character_armor
	-- defines.inventory.character_vehicle
	-- defines.inventory.character_trash


	local buttons = content.add{type="flow", direction="horizontal"}
	buttons.style.top_margin = 8

	buttons.add{
		type = "button",
		name = "follow-player-button",
		caption = {"players-inventory.caption-follow"},
		tags = {player_index=player.index}
	}
	buttons.add{
		type = "button",
		name = "grab-player-inventory-button",
		caption = {"players-inventory.caption-grab"},
		tags = {player_index=player.index}
	}
	buttons.add{
		type = "button",
		name = "kick-player-button",
		caption = {"players-inventory.caption-kick"},
		tags = {player_index=player.index, action="kick", panel=panel.get_index_in_parent()}
	}
	buttons.add{
		type = "button",
		name = "ban-player-button",
		caption = {"players-inventory.caption-ban"},
		tags = {player_index=player.index, action="ban", panel=panel.get_index_in_parent()}
	}
end

function PlayersInventory.build_player_inventory_grid(panel, player)
	local inventory = player.get_main_inventory().get_contents()

	panel.clear()

	for name, amount in pairs(inventory) do
		if not PlayersInventory.filter(name) then
			panel.add{
				type = "sprite-button",
				sprite = "item/" .. name,
				number = amount,
				ignored_by_interaction = true
			}
		end
	end

	local cells_count = #panel.children

	if cells_count > 0 then
		if cells_count % 10 > 0 then
			for _ = 1, 10 - cells_count % 10 do
				panel.add{type="sprite-button", ignored_by_interaction=true}
			end
		end
	else
		for _ = 1, 10 do
			panel.add{type="sprite-button", ignored_by_interaction=true}
		end
	end
end

function PlayersInventory.build_kickban_accept_window(player_index, action, panel)
	local player = game.players[player_index]

	local window = player.gui.screen.add{type="frame", name="kickban-accept-window", direction="vertical"}


	-- Header --------------------------------------------------------------------------------------------------------------
	local titlebar = window.add{type="flow", direction="horizontal"}
	titlebar.drag_target = window

	titlebar.add{
		type="label",
		caption={"players-inventory.caption-action", {"players-inventory.caption-"..action}, player.name},
		ignored_by_interaction=true,
		style="frame_title"
	}

	local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
	spacer.style.horizontally_stretchable = "on"
	spacer.style.height = 24
	spacer.style.left_margin = 4
	spacer.style.right_margin=4
	
	titlebar.add{
		type = "sprite-button",
		name = "close-kickban-accept-window-button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button"
	}


	-- Reason ---------------------------------------------------------------------------------------------------
	window.add{type="label", caption={"players-inventory.caption-reason"}, style="inventory_label"}

	local reason_textbox = window.add{type="text-box", name="reason-textbox", text="Пшёл вон!"}
	reason_textbox.style.width = 350
	reason_textbox.style.height = 100

	
	-- Buttons --------------------------------------------------------------------------------------------------------
	local buttons = window.add{type="flow", direction="horizontal"}
	buttons.style.horizontally_stretchable = "on"
	buttons.style.top_margin = 5
	buttons.style.horizontal_align = "right"

	buttons.add{
		type = "button",
		name = "accept-kickban-button",
		caption = {"players-inventory.caption-"..action},
		tags = {player_index=player_index, action=action, panel=panel}
	}
	buttons.add{
		type = "button",
		name = "cancel-kickban-button",
		caption = {"players-inventory.caption-cancel"}
	}

	return window
end


function PlayersInventory.filter(item_name)
	for _, filter_item in pairs(PlayersInventory.filter_items) do
		if item_name == filter_item then
			return true
		end
	end

	return false
end


function PlayersInventory.on_player_state_change(event)
	local player = game.players[event.player_index]
	PlayersInventory.add_players_inventory_gui_button(player)
end

function PlayersInventory.on_toggle_players_inventory_window(event)
	local player = game.get_player(event.player_index)

	if not player.admin then
		return
	end

	for _, child_element in pairs(player.gui.screen.children) do
		if child_element.name == "players-inventory-window" then
			child_element.destroy()
			return
		end
	end

	-- if player.admin then
	-- 	game.permissions.get_group("Admin").add_player(player)
	-- end

	-- if player.permission_group.name == "Manager" then
	-- 	game.permissions.get_group("Admin").add_player(player)
	-- else
	-- 	game.permissions.get_group("Manager").add_player(player)
	-- end

	local window = PlayersInventory.build_players_inventory_window(player)
	PlayersInventory.build_players_inventory_list(window)


	window.force_auto_center()
end

function PlayersInventory.on_close_players_inventory_window_button_click(event)
	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
end

function PlayersInventory.on_change_filters(event)
	if not event or not event.element or not event.element.valid then
        return
    end

    if event.element.name ~= "filter-connected"
    and event.element.name ~= "filter-role"
    and event.element.name ~= "filter-search" then
    	return
    end

	local window = game.players[event.player_index].gui.screen["players-inventory-window"]

	if not window then
		return
	end

	PlayersInventory.build_players_inventory_list(window)
end

function PlayersInventory.on_expand_player_inventory_button_click(event)
	local button = event.element
	local content = button.parent.parent["content"]

	if content.visible then
		button.sprite = "utility/expand"
		button.hovered_sprite = "utility/expand_dark"
		button.clicked_sprite = "utility/expand_dark"
	else
		button.sprite = "utility/collapse"
		button.hovered_sprite = "utility/collapse_dark"
		button.clicked_sprite = "utility/collapse_dark"
	end

	content.visible = not content.visible
end

function PlayersInventory.on_show_player_button_click(event)
	local character = game.players[event.element.tags.player_index].character

	if not character then
		return
	end

	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
	game.players[event.player_index].zoom_to_world(character.position, 1.0, character)
end

function PlayersInventory.on_grab_player_inventory_button_click(event)
	local from_player = game.players[event.element.tags.player_index]
	local from_inventory = from_player.get_main_inventory()
	local to_player = game.players[event.player_index]
	local to_inventory = to_player.get_main_inventory()

	for index = 1, #from_inventory do
		local stack = from_inventory[index]

		if stack.count > 0 and not PlayersInventory.filter(stack.name) then
			if to_inventory.can_insert(stack) then
				to_inventory.insert(stack)
				from_inventory.remove(stack)
			else
				to_player.print({"players-inventory.inventory-full"}, { 1, 0, 0, 1 })
				to_player.play_sound{path="utility/cannot_build"}
				break
			end
		end
	end

	local panel = event.element.parent.parent["resources"]
	PlayersInventory.build_player_inventory_grid(panel, from_player)
end

function PlayersInventory.on_kickban_buttons_click(event)
	local tags = event.element.tags
	local window = PlayersInventory.build_kickban_accept_window(tags.player_index, tags.action, tags.panel)
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

function PlayersInventory.on_players_inventory_gui_click(event)
	if not event or not event.element or not event.element.valid then
        return
    end

	for event_name, event_handler in pairs(PlayersInventory.players_inventory_gui_click_events) do
		if event_name == event.element.name then
			event_handler(event)
			break
		end
	end
end


PlayersInventory.players_inventory_gui_click_events = {
    ["toggle-players-inventory-window-button"] = PlayersInventory.on_toggle_players_inventory_window,
    ["close-players-inventory-window-button"] = PlayersInventory.on_close_players_inventory_window_button_click,
    ["follow-player-button"] = PlayersInventory.on_show_player_button_click,
    ["grab-player-inventory-button"] = PlayersInventory.on_grab_player_inventory_button_click,
    ["kick-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["ban-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["accept-kickban-button"] = PlayersInventory.on_kickban_accept_button_click,
    ["cancel-kickban-button"] = PlayersInventory.on_kickban_closecancel_buttons_click,
    ["close-kickban-accept-window-button"] = PlayersInventory.on_kickban_closecancel_buttons_click,
    ["expand-player-inventory-button"] = PlayersInventory.on_expand_player_inventory_button_click
}


function print(str)
	game.print(str)
end

function pprint(obj, value)
	for i, k in pairs(obj) do
		if value then 
			game.print(i .. " - " .. k)
		else
			game.print(i .. " - " .. type(k))
		end
	end
end

-- TODO:
-- 1. [done] Сделать подтверждайки для киков и банов
-- 2. [done] Сделать надписи после ников онлайн, группа, мут/бан
-- 3. [done] Сделать итоговую строку с количеством результатов
-- 4. [???] Сделать фильтр мутов/банов
-- 5. Возможно сделать вывод содержимого оружейных слотов и слота брони

return PlayersInventory
