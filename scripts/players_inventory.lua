-- Copyright (c) 2022 Ajick

local event_handler = require("__core__/lualib/event_handler")
local mod_gui = require("__core__/lualib/mod-gui")


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

	local titlebar = window.add{type="flow", direction="horizontal"}
	titlebar.drag_target = window

	titlebar.add{type="label", caption={"players-inventory.caption"}, ignored_by_interaction=true, style="frame_title"}

	local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
	spacer.style.horizontally_stretchable = "on"
	spacer.style.height = 24
	spacer.style.left_margin = 4
	spacer.style.right_margin=4

	local search_field = titlebar.add{type="textfield", name="search-player-textfield", style="titlebar_search_textfield"}
	search_field.style.width = 125
	search_field.style.height = 27
	search_field.visible = false

	titlebar.add{
		type = "sprite-button",
		name = "search-player-button",
		sprite = "utility/search_white",
		hovered_sprite = "utility/search_black",
		clicked_sprite = "utility/search_black",
		style = "frame_action_button"
	}
	
	titlebar.add{
		type = "sprite-button",
		name = "close-players-inventory-window-button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "frame_action_button"
	}

	local empty_flow = window.add{type="flow", name="empty-flow", direction="vertical"}
	-- local empty_flow = window.add{type="frame", name="empty-flow", direction="vertical"}
	empty_flow.style.width = 468
	empty_flow.style.height = 150
	empty_flow.style.horizontal_align = "center"
	empty_flow.style.vertical_align = "center"
	empty_flow.visible = false

	empty_flow.add{type="sprite", sprite="utility/ghost_time_to_live_modifier_icon"}
	empty_flow.add{type="label", caption={"players-inventory.empty-caption"}, style="inventory_label"}
	
	window.add{type="scroll-pane", name="main-flow", direction="vertical"}

	return window
end

function PlayersInventory.build_player_inventory_panel(window, player)
	local panel = window["main-flow"].add{
		type = "frame",
		direction = "vertical",
		tags = {player_index=player.index, player=player.name}
	}
	panel.style.padding = 8

	panel.add{type="label", caption=player.name, style="subheader_caption_label"}

	local resources = panel.add{type="table", name="resources", column_count=10}
	resources.style.top_margin = 8
	resources.style.left_margin = 2
	resources.style.padding = 2

	PlayersInventory.build_player_inventory_grid(resources, player)

	local buttons = panel.add{type="flow", direction="horizontal"}
	buttons.style.top_margin = 8

	buttons.add{
		type = "button",
		name = "follow-player-button",
		caption = {"players-inventory.follow-caption"},
		tags = {player_index=player.index}
	}
	buttons.add{
		type = "button",
		name = "grab-player-inventory-button",
		caption = {"players-inventory.grab-caption"},
		tags = {player_index=player.index}
	}
	buttons.add{
		type = "button",
		name = "kick-player-button",
		caption = {"players-inventory.kick-caption"},
		tags = {player_index=player.index, panel=panel.get_index_in_parent()}
	}
	buttons.add{
		type = "button",
		name = "ban-player-button",
		caption = {"players-inventory.ban-caption"},
		tags = {player_index=player.index, panel=panel.get_index_in_parent()}
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
			-- game.print(name)
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

	local window = PlayersInventory.build_players_inventory_window(player)

	for _, player in pairs(game.players) do
		if not player.admin and player.connected then
			PlayersInventory.build_player_inventory_panel(window, player)
		end
	end

	if #window["main-flow"].children == 0 then
		window["empty-flow"].visible = true
	end

	window.force_auto_center()
end

function PlayersInventory.on_search_button_click(event)
	local search_field = event.element.parent["search-player-textfield"]
	local main_flow = search_field.parent.parent["main-flow"]
	local empty_flow = search_field.parent.parent["empty-flow"]

	search_field.visible = not search_field.visible

	if search_field.visible then
		if search_field.text then
			search_field.text = ""

			for _, panel in pairs(main_flow.children) do
				panel.visible = true
			end
		end

		empty_flow.visible = false
		search_field.focus()
	end
end

function PlayersInventory.on_search_players(event)
	local empty_flow = event.element.parent.parent["empty-flow"]
	local main_flow = event.element.parent.parent["main-flow"]
	local text = string.lower(event.element.text)
	local empty = true
	
	for _, panel in pairs(main_flow.children) do
		panel.visible = false
	end

	for _, panel in pairs(main_flow.children) do
		if string.find(string.lower(panel.tags.player), text) then
			panel.visible = true
			empty = false
		end
	end

	empty_flow.visible = empty
end

function PlayersInventory.on_search_confirmed(event)
	event.element.visible = false
end

function PlayersInventory.on_close_players_inventory_window_button_click(event)
	game.players[event.player_index].gui.screen["players-inventory-window"].destroy()
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

function PlayersInventory.on_kick_player_button_click(event)
	local tags = event.element.tags
	local player = game.players[tags.player_index]
	local panel = game.players[event.player_index].gui.screen["players-inventory-window"]["main-flow"].children[tags.panel]
	game.kick_player(player)
	panel.destroy()
end

function PlayersInventory.on_ban_player_button_click(event)
	local tags = event.element.tags
	local player = game.players[tags.player_index]
	local panel = game.players[event.player_index].gui.screen["players-inventory-window"]["main-flow"].children[tags.panel]
	game.ban_player(player)
	panel.destroy()
end


PlayersInventory.players_inventory_gui_click_events = {
    ["toggle-players-inventory-window-button"] = PlayersInventory.on_toggle_players_inventory_window,
    ["search-player-button"] = PlayersInventory.on_search_button_click,
    ["close-players-inventory-window-button"] = PlayersInventory.on_close_players_inventory_window_button_click,
    ["follow-player-button"] = PlayersInventory.on_show_player_button_click,
    ["grab-player-inventory-button"] = PlayersInventory.on_grab_player_inventory_button_click,
    ["kick-player-button"] = PlayersInventory.on_kick_player_button_click,
    ["ban-player-button"] = PlayersInventory.on_ban_player_button_click
}

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

function print(str)
	game.print(str)
	-- for i, k in pairs(str) do
	-- 	game.print(i)
	-- end
end


return PlayersInventory
