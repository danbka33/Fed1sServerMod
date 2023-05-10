-- Copyright (c) 2023 Ajick


local event_handler = require("__core__/lualib/event_handler")
local mod_gui = require("__core__/lualib/mod-gui")

local get_make_playerdata = require("__Fed1sServerMod__/scripts/server_mod").get_make_playerdata




-- Constans and variables ---------------------------------------------------------------------------------------------
local in_debug = false


local PlayersInventory = {}

PlayersInventory.filter_roles = {"warrior", "defender", "builder"} -- , "service"
PlayersInventory.inventories = {
	main = defines.inventory.character_main,
	armor = defines.inventory.character_armor,
	guns = defines.inventory.character_guns,
	ammo = defines.inventory.character_ammo,
	trash = defines.inventory.character_trash
}


-- Metods -------------------------------------------------------------------------------------------------------------

function PlayersInventory.manage_players_inventory_gui_buttons()
	for _, player in pairs(game.players) do
		PlayersInventory.manage_players_inventory_gui_button(player)
	end
end

function PlayersInventory.manage_players_inventory_gui_button(player)
	local gui_flow = mod_gui.get_button_flow(player)
	local gui_button = gui_flow["toggle-players-inventory-window-button"]

	if gui_button then
		gui_button.destroy()
	end

	if not player.admin then
		return
	end

	gui_flow.add{
		type = "sprite-button",
		sprite = "utility/slot_icon_armor",
		hovered_sprite = "utility/slot_icon_armor_black",
		clicked_sprite = "utility/slot_icon_armor_black",
		name = "toggle-players-inventory-window-button",
		tooltip = {"players-inventory.caption"}
	}
end


function PlayersInventory.build_players_inventory_window(player)
	local window = player.gui.screen.add{type="frame", name="players-inventory-window", direction="vertical"}
	window.style.maximal_height = 800


	-- Header ---------------------------------------------------------------------------------------------------------

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


	-- Filters --------------------------------------------------------------------------------------------------------

	local filter_flow = window.add{type="flow", name="filters-flow", direction="horizontal"}
	filter_flow.style.top_margin = 3

	filter_flow.add{
		type = "switch",
		name = "filter-connected",
		allow_none_state = true,
		switch_state = "left",
		left_label_caption = {"players-inventory.caption-online"},
		right_label_caption = {"players-inventory.caption-offline"}
	}
	
	local roles = {
		{"players-inventory.caption-all"},
		{"players-inventory.caption-warriors"},
		{"players-inventory.caption-defenders"},
		{"players-inventory.caprion-builders"}
	} -- , {"players-inventory.caption-service"}
	local filter_roles = filter_flow.add{type="drop-down", name="filter-role", items=roles, selected_index=1}
	filter_roles.style.left_margin = 10
	filter_roles.style.top_margin = -3

	local spacer = filter_flow.add{type="empty-widget", ignored_by_interaction=true}
	spacer.style.horizontally_stretchable = "on"

	local search_icon = filter_flow.add{type = "sprite", sprite = "utility/search_white"}
	search_icon.style.top_margin = 3

	local search_field = filter_flow.add{type="textfield", name="filter-search"}
	search_field.style.width = 125
	search_field.style.top_margin = -4
	
	
	-- Empty placeholder ----------------------------------------------------------------------------------------------

	local empty_flow = window.add{type="flow", name="empty-flow", direction="vertical"}
	empty_flow.style.width = 468
	empty_flow.style.height = 150
	empty_flow.style.horizontal_align = "center"
	empty_flow.style.vertical_align = "center"
	empty_flow.visible = false

	empty_flow.add{type="sprite", sprite="utility/ghost_time_to_live_modifier_icon"}
	empty_flow.add{type="label", caption={"players-inventory.caption-empty"}, style="inventory_label"}

	
	-- Players list ---------------------------------------------------------------------------------------------------

	local main_flow = window.add{type="scroll-pane", name="main-flow", direction="vertical"}
	main_flow.style.top_margin = 3


	-- List count -----------------------------------------------------------------------------------------------------

	local count_flow = window.add{type="flow", name="count-flow", direction="horizontal"}
	count_flow.style.top_margin = 5

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
		if not in_debug and player.admin then
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

		if not in_debug then
			PlayersInventory.build_player_inventory_panel(window, player)
		else
			for i=1, 15 do
				PlayersInventory.build_player_inventory_panel(window, player)
			end
		end

		count = count + 1

		::continue::
	end

	local is_empty = (count == 0)

	if not is_empty then
		window["count-flow"]["count"].caption = {"players-inventory.caption-count", count}
		global.selected_indices = {}
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


	-- Header ---------------------------------------------------------------------------------------------------------

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

	header.add{type="label", caption=player.name, style="subheader_caption_label"} -- subheader_label

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


	-- Content --------------------------------------------------------------------------------------------------------

	local content = panel.add{type="flow", name="content", direction="vertical"}
	content.visible = false

	local inventories = content.add{type="flow", name="inventories", direction="vertical"}
	inventories.style.horizontally_stretchable = "on"
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


	-- Buttons --------------------------------------------------------------------------------------------------------

	local buttons = content.add{type="flow", name="buttons", direction="horizontal"}
	buttons.style.top_margin = 18

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
		enabled = false,
		tags = {player_index=player.index, panel=panel.get_index_in_parent()}
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

function PlayersInventory.build_player_inventory_flow(parent, name, caption)
	local inventory_flow = parent.add{type = "flow", name = name, direction = "vertical"}
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
	local content = inventory.get_contents()
	local inventory_type = inventory.index

	grid.clear()


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

	for name, amount in pairs(content) do
		PlayersInventory.build_inventory_button(grid, tags, "item/"..name, inventory_type, amount)
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

function PlayersInventory.build_ammunition_inventory(inventory_flow, player)
	local armor_inventory = player.get_inventory(defines.inventory.character_armor)
	local guns_inventory = player.get_inventory(defines.inventory.character_guns)
	local ammo_inventory = player.get_inventory(defines.inventory.character_ammo)

	local grid = inventory_flow["grid"]
	grid.clear()


	-- Armor ----------------------------------------------------------------------------------------------------------
	if not armor_inventory.is_empty() then
		local tags = {
			player_index = armor_inventory.player_owner.index,
			inventory_type = "armor",
			panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
		}
		PlayersInventory.build_inventory_button(grid, tags, "item/"..armor_inventory[1].name, "armor")
	else
		PlayersInventory.build_inventory_button(grid, nil, "utility/slot_icon_armor")
	end


	-- Guns -----------------------------------------------------------------------------------------------------------
	for i = 1, #guns_inventory do 
		local item = guns_inventory[i]

		if item.valid_for_read then
			local tags = {
				player_index = guns_inventory.player_owner.index,
				inventory_type = "guns",
				panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
			}
			PlayersInventory.build_inventory_button(grid, tags, "item/"..item.name, "gun")
		else
			PlayersInventory.build_inventory_button(grid, nil, "utility/slot_icon_gun")
		end
	end


	-- Fillers --------------------------------------------------------------------------------------------------------
	for i = 1, 7 do
		local filler = grid.add{type="empty-widget"}
		filler.style.width = 40
	end


	-- Ammo -----------------------------------------------------------------------------------------------------------
	for i = 1, #ammo_inventory do
		local item = ammo_inventory[i]

		if item.valid_for_read then
			local tags = {
				player_index = ammo_inventory.player_owner.index,
				inventory_type = "ammo",
				panel_index = inventory_flow.parent.parent.parent.get_index_in_parent()
			}
			PlayersInventory.build_inventory_button(grid, tags, "item/"..item.name, "ammo", item.count)
		else
			PlayersInventory.build_inventory_button(grid, nil, "utility/slot_icon_ammo")
		end
	end
end

function PlayersInventory.build_inventory_button(parent, tags, sprite, inventory_type, amount)
	local index = #parent.children + 1

	local button = parent.add{
		type = "sprite-button",
		name = "inventory-item-"..index,
		style = "inventory_slot",
		tooltip = {"players-inventory.tooltip-inventory-button"}
	}

	if tags then button.tags = tags end
	if sprite then button.sprite = sprite end
	if amount then button.number = amount end

	if inventory_type then
		button.ignored_by_interaction = false
	else
		button.ignored_by_interaction = true
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


function PlayersInventory.grab_common_inventory(from_inventory, to_inventory, filters)
	local player = to_inventory.player_owner

	if in_debug then
		player = from_inventory.player_owner
	end

	for i = 1, #from_inventory do
		local stack = from_inventory[i]

		if not stack.valid_for_read then
			goto continue
		end

		if not PlayersInventory.selected(stack.name, filters) then
			goto continue
		end

		if not to_inventory.can_insert(stack) then
			player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
			return false
		end

		to_inventory.insert(stack)
		from_inventory.remove(stack)

		::continue::
	end

	return true
end

function PlayersInventory.grab_ammunition_inventory(from_inventories, to_inventory, filters)
	local armor_inventory = from_inventories[1]
	local guns_inventory = from_inventories[2]
	local ammo_inventory = from_inventories[3]

	local player = to_inventory.player_owner

	if in_debug then
		player = armor_inventory.player_owner
	end


	local stack = armor_inventory[1]

	if stack.valid_for_read
	and PlayersInventory.match_and_selected(filters.children[1], stack.name) then
		if not to_inventory.can_insert(stack) then
			player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
			return
		end

		to_inventory.insert(stack)
		armor_inventory.remove(stack)
	end


	for i = 1, #guns_inventory do
		local stack = guns_inventory[i]

		if stack.valid_for_read
		and PlayersInventory.match_and_selected(filters.children[i+1], stack.name) then
			if not to_inventory.can_insert(stack) then
				player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
				return
			end

			to_inventory.insert(stack)
			guns_inventory.remove(stack)
		end
	end


	for i = 1, #ammo_inventory do
		local stack = ammo_inventory[i]

		if stack.valid_for_read
		and PlayersInventory.match_and_selected(filters.children[i+11], stack.name) then
			if not to_inventory.can_insert(stack) then
				player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
				return
			end

			to_inventory.insert(stack)
			ammo_inventory.remove(stack)
		end
	end
end

function PlayersInventory.take_slot(player, button, one_stack)
	local one_stack = one_stack or false
	local inventory_type = PlayersInventory.inventories[button.tags.inventory_type]
	local from_inventory = game.players[button.tags.player_index].get_inventory(inventory_type)
	local to_inventory = player.get_main_inventory()

	if in_debug then
		local chests = player.surface.find_entities_filtered{radius=5, name="steel-chest"}

		if #to_inventory == 0 then
			print("Поставь сундук!")
			return
		end

		to_inventory = chests[1].get_inventory(defines.inventory.chest)
	end

	for i = 1, #from_inventory do
		local stack = from_inventory[i]

		if not stack.valid_for_read then
			goto continue
		end

		local item_name = string.gsub(stack.name, "%-", "%%-")

		if not string.match(button.sprite, item_name) then
			goto continue
		end

		if not to_inventory.can_insert(stack) then
			player.print({"players-inventory.message-inventory-full"}, { 1, 0, 0, 1 })
			break
		end

		to_inventory.insert(stack)
		from_inventory.remove(stack)

		if one_stack then
			break
		end

		::continue::
	end

	global.selected_indices[button.tags.panel_index] = 0
	button.parent.parent.parent.parent["buttons"]["grab-player-inventory-button"].enabled = false
	PlayersInventory.build_player_inventories(button.parent.parent.parent, player)
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


-- Events -------------------------------------------------------------------------------------------------------------

function PlayersInventory.on_player_state_change(event)
	local player = game.players[event.player_index]
	PlayersInventory.manage_players_inventory_gui_button(player)
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

	local window = PlayersInventory.build_players_inventory_window(player)
	PlayersInventory.build_players_inventory_list(window)

	window.force_auto_center()
end

function PlayersInventory.on_close_players_inventory_window_button_click(event)
	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
	global.selected_indices = nil
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
	local player = game.players[event.player_index]
	local button = event.element
	local content = button.parent.parent["content"]
	local inventory_index = button.parent.parent.get_index_in_parent()

	if content.visible then
		button.sprite = "utility/expand"
		button.hovered_sprite = "utility/expand_dark"
		button.clicked_sprite = "utility/expand_dark"

		global.selected_indices[inventory_index] = nil
	else
		button.sprite = "utility/collapse"
		button.hovered_sprite = "utility/collapse_dark"
		button.clicked_sprite = "utility/collapse_dark"

		global.selected_indices[inventory_index] = 0

		PlayersInventory.build_player_inventories(content["inventories"], player)
		button.parent.parent.parent.scroll_to_element(button.parent.parent)
	end

	content.visible = not content.visible
end


function PlayersInventory.on_inventory_button_click(event)
	local button = event.element

	if event.button == 2 then
		local player = game.players[event.player_index]

		if event.shift then
			PlayersInventory.take_slot(player, button, true)
		elseif event.control then
			PlayersInventory.take_slot(player, button)
		end
	elseif event.button == 4 then
		local panel = button.parent.parent.parent.parent.parent
		local panel_index = panel.get_index_in_parent()

		if button.style.name == "inventory_slot" then
			button.style = "filter_inventory_slot"
			global.selected_indices[panel_index] = global.selected_indices[panel_index] + 1
		else
			button.style = "inventory_slot"
			global.selected_indices[panel_index] = global.selected_indices[panel_index] - 1
		end

		panel["content"]["buttons"]["grab-player-inventory-button"].enabled = global.selected_indices[panel_index] > 0
	end
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
	local main_inventory = from_player.get_inventory(defines.inventory.character_main)
	local armor_inventory = from_player.get_inventory(defines.inventory.character_armor)
	local guns_inventory = from_player.get_inventory(defines.inventory.character_guns)
	local ammo_inventory = from_player.get_inventory(defines.inventory.character_ammo)
	local trash_inventory = from_player.get_inventory(defines.inventory.character_trash)

	local window = game.players[event.player_index].gui.screen["players-inventory-window"]
	local panel = window["main-flow"].children[event.element.tags.panel]["content"]
	local grab_button = panel["buttons"]["grab-player-inventory-button"]
	local buttons = panel["inventories"]
	local main_buttons = buttons["main-inventory"]["grid"]
	local ammunition_buttons = buttons["ammunition-inventory"]["grid"]
	local trash_buttons = buttons["trash-inventory"]["grid"]

	local to_player = game.players[event.player_index]
	local to_inventory = to_player.get_main_inventory()

	if in_debug then
		local chests = to_player.surface.find_entities_filtered{radius=5, name="steel-chest"}

		if #to_inventory == 0 then
			print("Поставь сундук!")
			return
		end

		to_inventory = chests[1].get_inventory(defines.inventory.chest)
	end

	if not PlayersInventory.grab_common_inventory(main_inventory, to_inventory, main_buttons) then
		goto exit
	end

	if not PlayersInventory.grab_common_inventory(trash_inventory, to_inventory, trash_buttons) then
		goto exit
	end

	PlayersInventory.grab_ammunition_inventory(
		{armor_inventory, guns_inventory, ammo_inventory},
		to_inventory,
		ammunition_buttons
	)

	::exit::

	global.selected_indices[event.element.tags.panel] = 0
	grab_button.enabled = false
	PlayersInventory.build_player_inventories(buttons, to_player)
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

    local element_name = event.element.name

	if in_(element_name, PlayersInventory.players_inventory_gui_click_events, true) then
		PlayersInventory.players_inventory_gui_click_events[element_name](event)
	elseif string.match(element_name, "inventory%-item%-") then
		PlayersInventory.on_inventory_button_click(event)
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



-- Utility functions --------------------------------------------------------------------------------------------------

function in_(what, where, is_obj)
	is_obj = is_obj or false

	for i, k in pairs(where) do
		if is_obj then
			if what == i then 
				return true
			end
		else
			if what == k then 
				return true
			end
		end
	end

	return false
end

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



--[[
	
	TODO:

	— [done] Сделать окно подтверждения для киков и банов
	— [done] Сделать надписи после ников: [онлайн] [группа] [руководитель]
	— [done] Сделать итоговую строку с количеством результатов
	— [done] Сделать подгрузку инвентарей по запросу
	— [done] Cделать вывод содержимого оружейных слотов, слота брони и мусорных слотов
	— [done] Сделать раскулачивание мусорных слотов
	— [done] Сделать возможность забрать предметы по отоборажающимся кнопкам (shift+click - стак, ctrl+click - всё)
	— [done] Сделать настройку фильтров для кнопки Раскулачить (right click)
	— Сделать фильтры по предметам с галочкой чёрный/белый список
	— Сделать возможность забрать всё из основного и мусорных инвентарей по нажатию на пустом слоте
	— Сделать галочки отображения инвентарей
	— Перевести весь мод на __core__/lualib/event_handler
	— [not achievable] Сделать фильтр мутов/банов

--]]



return PlayersInventory
