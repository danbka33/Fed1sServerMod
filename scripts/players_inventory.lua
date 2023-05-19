-- Copyright (c) 2023 Ajick


local event_handler = require("__core__/lualib/event_handler")
local mod_gui = require("__core__/lualib/mod-gui")

-- Constans and variables ---------------------------------------------------------------------------------------------
local in_debug = false


local PlayersInventory = {}

PlayersInventory.roles = {"warrior", "defender", "builder"} -- , "service"
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
		PlayersInventory.manage_player_inventory_gui_button(player)
	end
end

function PlayersInventory.manage_player_inventory_gui_button(player)
	local gui_flow = mod_gui.get_button_flow(player)
	local gui_button = gui_flow["toggle-players-inventory-window-button"]

	if gui_button then
		gui_button.destroy()
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
	if not global.selected_items_count then
		global.selected_items_count = {}
	end

	global.selected_items_count[player.index] = {}

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
		{"players-inventory.caption-builders"}
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

		if player.index == self_player.index and not in_debug then 
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
	header.style.width = 448

	header.add{
		type = "sprite-button",
		name = "expand-player-inventory-button",
		sprite = "utility/expand",
		hovered_sprite = "utility/expand_dark",
		clicked_sprite = "utility/expand_dark",
		style = "frame_action_button",
		tags = {player_index=player.index}
	}

	header.add{type="label", caption=player.name, style="subheader_caption_label"}

	local playerdata = ServerMod.get_make_playerdata(player.index)

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
		enabled = player.connected,
		tags = {player_index=player.index}
	}
	buttons.add{
		type = "button",
		name = "take-player-inventory-button",
		caption = {"players-inventory.caption-take"},
		enabled = false,
		tags = {player_index=player.index, panel=panel.get_index_in_parent()}
	}
	buttons.add{
		type = "button",
		name = "kick-player-button",
		caption = {"players-inventory.caption-kick"},
		enabled = self_player.admin,
		tags = {player_index=player.index, action="kick", panel=panel.get_index_in_parent()}
	}
	buttons.add{
		type = "button",
		name = "ban-player-button",
		caption = {"players-inventory.caption-ban"},
		enabled = self_player.admin,
		tags = {player_index=player.index, action="ban", panel=panel.get_index_in_parent()}
	}
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
	spacer.style.horizontally_stretchable = "on"
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
	buttons.style.horizontally_stretchable = "on"
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

	if in_debug then
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

	if in_debug then
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
	local profiler2 = game.create_profiler()
	PlayersInventory.build_player_inventories(button.parent.parent.parent, from_player)
	game.print("Build inventories: ")
	game.print(profiler2);
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
	PlayersInventory.manage_player_inventory_gui_button(player)
end


function PlayersInventory.on_toggle_players_inventory_window(event)
	local player = game.get_player(event.player_index)
	local window = player.gui.screen["players-inventory-window"]

	if window then
		window.destroy()
		return
	end

	window = PlayersInventory.build_players_inventory_window(player)
	PlayersInventory.build_players_inventory_list(window)
	window.force_auto_center()
end

function PlayersInventory.on_close_players_inventory_window_button_click(event)
	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
	global.selected_items_count[event.player_index] = nil
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

	PlayersInventory.build_players_inventory_list(window)
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


function PlayersInventory.on_inventory_button_click(event)
	local button = event.element
	local player = game.players[event.player_index]

	if event.button == 2 then
		if event.shift and player.admin then
			PlayersInventory.take_items(player, button, true)
		elseif event.control and player.admin then
			PlayersInventory.take_items(player, button)
		elseif button.name == "armor" then
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


function PlayersInventory.on_show_player_button_click(event)
	local character = game.players[event.element.tags.player_index].character

	if not character then
		return
	end

	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
	game.players[event.player_index].zoom_to_world(character.position, 1.0, character)
end

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

	if in_debug then
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
	local profiler2 = game.create_profiler()
	PlayersInventory.build_player_inventories(buttons, from_player)
	profiler2.stop()
	game.print("Build inventories: ")
	game.print(profiler2)

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
    ["toggle-players-inventory-window-button"] = PlayersInventory.on_toggle_players_inventory_window,
    ["close-players-inventory-window-button"] = PlayersInventory.on_close_players_inventory_window_button_click,
    ["follow-player-button"] = PlayersInventory.on_show_player_button_click,
    ["take-player-inventory-button"] = PlayersInventory.on_take_player_inventory_button_click,
    ["kick-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["ban-player-button"] = PlayersInventory.on_kickban_buttons_click,
    ["accept-kickban-button"] = PlayersInventory.on_kickban_accept_button_click,
    ["cancel-kickban-button"] = PlayersInventory.on_kickban_closecancel_buttons_click,
    ["close-kickban-accept-window-button"] = PlayersInventory.on_kickban_closecancel_buttons_click,
    ["expand-player-inventory-button"] = PlayersInventory.on_expand_player_inventory_button_click
}



-- Utility functions --------------------------------------------------------------------------------------------------

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

	— Сделать возможность забрать всё из основного и мусорных инвентарей по нажатию на пустом слоте
	— Сделать фильтры по предметам с галочкой чёрный/белый список
	— [done - и не волнует!] Сделать просмотр модулей в броне
	— Перевести весь мод на __core__/lualib/event_handler
	— [done] Сделать окно подтверждения для киков и банов
	— [done] Сделать надписи после ников: [онлайн] [группа] [руководитель]
	— [done] Сделать итоговую строку с количеством результатов
	— [done] Сделать подгрузку инвентарей по запросу
	— [done] Cделать вывод содержимого оружейных слотов, слота брони и мусорных слотов
	— [done] Сделать раскулачивание мусорных слотов
	— [done] Сделать возможность забрать предметы по отоборажающимся кнопкам (shift+click - стак, ctrl+click - всё)
	— [done] Сделать настройку фильтров для кнопки Раскулачить (right click)
	— [done] Сделать просмотр окна для остальных игроков в режиме только чтение
	— [don't needed] Сделать опцию отображения отдельных инвентарей
	— [not achievable] Сделать фильтр мутов/банов

--]]



return PlayersInventory
