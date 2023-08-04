-- Copyright © Ajick 2023


local mod_gui = require("__core__/lualib/mod-gui")



-- Constans and variables --

local Statistics = {}

Statistics.type_names = {
	"builded",
	"killed",
	"deaths",
	"repaired",
	"mined",
	"crafted",
	"walked"
}
Statistics.types = {}
for _, type_name in pairs(Statistics.type_names) do
	Statistics.types[type_name] = type_name
end

Statistics.top_names = {
	"builders",
	"architectors",
	"military_enginears",
	"crafters",
	"repairemans",
	"wariors",
	"tree_haters",
	"rock_haters",
	"miners",
	"deaths",
	"railwaymans",
	"runners",
	"lumberjacks",
	"mariobrothers",
	"oilmans",
	"roadworkers",
	"electricians",
	"fishermans"
}



-- Staistics GUI --

function Statistics.create_toggle_button(target_player, redraw)
	local button_flow = mod_gui.get_button_flow(target_player)
	local toggle_button = button_flow.statistics_toggle_window_button
	
	if toggle_button and toggle_button.valid then
		if redraw then
			toggle_button.destroy()
		else
			return
		end
	end

	button_flow.add{
		type = "sprite-button",
		name = "statistics_toggle_window_button",
		sprite = "statistics_white",
		hovered_sprite = "statistics_black",
		clicked_sprite = "statistics_black",
		tooltip = {"statistics.caption"}
	}
end


function Statistics.build_statistics_window(player)
	local player_data = global.statistics.players_data[player.index]
	local window = player.gui.screen.add{type="frame", name="statistics_window", direction="vertical"}


	-- Header --

	local titlebar = window.add{type="flow", direction="horizontal"}
	titlebar.drag_target = window

	titlebar.add{type="label", caption={"statistics.caption"}, ignored_by_interaction=true, style="frame_title"}

	local spacer = titlebar.add{type="empty-widget", ignored_by_interaction=true, style="draggable_space"}
	spacer.style.horizontally_stretchable = true
	spacer.style.height = 24
	spacer.style.left_margin = 5
	spacer.style.right_margin = 5
	
	titlebar.add{
		type = "sprite-button",
		name = "statistics_close_window_button",
		sprite = "utility/close_white",
		hovered_sprite = "utility/close_black",
		clicked_sprite = "utility/close_black",
		style = "close_button"
	}


	-- Content --

	local content = window.add{type="flow", name="content", direction="horizontal"}
	content.style.horizontally_stretchable = true


	-- Tops list --

	local left_panel = content.add{type="flow", name="left_panel", direction="vertical"}

	local tops_menu = left_panel.add{type="scroll-pane", name="tops_menu", direction="vertical"}
	tops_menu.style.margin = 10
	tops_menu.style.width = 200
	
	for _, top_name in pairs(Statistics.top_names) do
		local menu_item_style

		if player_data and top_name == player_data.current_top then
			menu_item_style = "statistics_menu_current_item"
		else
			menu_item_style = "statistics_menu_item"
		end

		tops_menu.add{
			type = "label",
			name = "statistics_top_"..top_name,
			caption = {"statistics."..top_name},
			tags = {top_name=top_name},
			style = menu_item_style
		}
	end

	if player.admin then
		local spacer = left_panel.add{type="empty-widget"}
		spacer.style.vertically_stretchable = true

		left_panel.add{
			type="checkbox", name="statistics_show_all_checkbox", state=global.statistics.show_button,
			caption={"statistics.caption-show-buttons"}, tooltip={"statistics.tooltip-show-buttons"}
		}
	end


	-- Top table --

	local top = content.add{type="frame", name="top", direction="vertical"}
	top.style.width = 550
	top.style.height = 700
	top.style.padding = 20

	local top_header = top.add{type="label", name="place"}
	top_header.style.font = "heading-1"
	top_header.style.font_color = {1, 1, 0}

	local top_subheader = top.add{type="label", name="player"}
	top_subheader.style.font = "heading-3"
	top_subheader.style.font_color = {0.7, 0.7, 0.7}


	-- Top table header --

	local header = top.add{type="table", name="header", column_count=3, ignored_by_interaction=true}
	header.style.top_margin = 20

	local label_place = header.add{
		type = "label",
		name = "place",
		caption = {"statistics.caption-place"},
		style = "subheader_caption_label"
	}
	label_place.style.width = 30
	label_place.style.horizontal_align = "right"

	local label_player = header.add{
		type = "label",
		name = "player",
		caption = {"statistics.caption-player"},
		style = "subheader_caption_label"
	}
	label_player.style.width = 330
	label_player.style.margin = 3

	local label_amount = header.add{
		type = "label",
		name = "amount",
		caption = {"statistics.caption-amount"},
		style = "subheader_caption_label"
	}
	label_amount.style.width = 100
	label_amount.style.horizontal_align = "right"


	-- Top table --

	local data_scroller = top.add{type="scroll-pane", name="data_scroller", direction="vertical"}
	data_scroller.style.horizontally_stretchable = true

	local top_data = data_scroller.add{
		type = "table",
		name = "top_data",
		column_count = 3,
		ignored_by_interaction = true,
		draw_horizontal_lines = true
	}


	--

	player_data.window = window
	player_data.tops_menu = tops_menu
	player_data.top_header = top_header
	player_data.top_subheader = top_subheader
	player_data.data_scroller = data_scroller
	player_data.top_data = top_data


	--

	return window
end

function Statistics.build_top_data(player_data)
	local top = Statistics.get_top(player_data.current_top)

	for _, element in pairs(player_data.tops_menu.children) do
		if element.tags.top_name == player_data.current_top then
			element.style = "statistics_menu_current_item"
		elseif element.style.name == "statistics_menu_current_item" then
			element.style = "statistics_menu_item"
		end
	end

	player_data.top_header.caption = {"statistics."..player_data.current_top}
	player_data.top_subheader.caption = {"statistics."..player_data.current_top.."-info"}

	player_data.top_data.clear()

	if not top then
		player_data.top_data.add{
			type = "label",
			caption = {"statistics.no-data"}
		}

		goto exit
	end

	for place, data in pairs(top) do
		local place_style, player_style, amount_style

		if place < 4 then
			place_style = "statistics_first_three_place"
			player_style = "statistics_first_three_player"
			amount_style = "statistics_first_three_amount"
		elseif place < 11 then
			place_style = "statistics_first_ten_place"
			player_style = "statistics_first_ten_player"
			amount_style = "statistics_first_ten_amount"
		else
			place_style = "statistics_place"
			player_style = "statistics_player"
			amount_style = "statistics_amount"
		end

		local label_place = player_data.top_data.add{
			type = "label",
			caption = place,
			style = place_style
		}

		local label_player = player_data.top_data.add{
			type = "label",
			caption = game.players[data.player_index].name,
			style = player_style
		}

		local label_amount = player_data.top_data.add{
			type = "label",
			caption = data.amount,
			style = amount_style
		}
	end

	::exit::

	player_data.data_scroller.scroll_to_top()
end

function Statistics.close_window(player_data)
	if not player_data then
		log("Statistics.close_window: player_data is gone!")
		return
	end

	if player_data.window then
		player_data.window.destroy()
		player_data.window = nil
	end

	player_data.tops_menu = nil
	player_data.top_header = nil
	player_data.top_subheader = nil
	player_data.data_scroller = nil
	player_data.top_data = nil
end



-- Statistics calculation functions --

function Statistics.calculate_builders()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

    if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if item_name ~= "ghosts" and not Statistics.is_walkpath(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_architectors()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end


	local top = {}

	for player_index, items in pairs(builded) do
		if not items.ghosts then
			goto continue
		end

		local amount = 0

		for _, count in pairs(items.ghosts) do
			amount = amount + count
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end

		::continue::
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_military_enginears()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_defensive_stuff(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_crafters()
	local crafted = Statistics.get_raw_data_type(Statistics.types.crafted)

	if not crafted then
    	return
    end

	local top = {}

	for player_index, items in pairs(crafted) do
		local amount = 0

		for _, count in pairs(items) do
			amount = amount + count
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_repairemans()
	local repaired = Statistics.get_raw_data_type(Statistics.types.repaired)

	if not repaired then
    	return
    end

	local top = {}

	for player_index, items in pairs(repaired) do
		local amount = 0

		for _, count in pairs(items) do
			amount = amount + count
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_wariors()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)

	if not killed then
    	return
    end

	local top = {}

	for player_index, items in pairs(killed) do
		if not items.enemy then
			goto continue
		end

		local amount = 0

		for _, damages in pairs(items.enemy) do
			for name, count in pairs(damages) do
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end

		::continue::
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_tree_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)

	if not killed then
    	return
    end


	local top = {}

	for player_index, items in pairs(killed) do
		if not items.neutral then
			goto next_player
		end

		local amount = 0

		for item_name, damages in pairs(items.neutral) do
			if not Statistics.is_tree(item_name) then
				goto next_item
			end

			for _, count in pairs(damages) do
				amount = amount + count
			end

			::next_item::
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end

		::next_player::
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_rock_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)

	if not killed then
    	return
    end

	local top = {}

	for player_index, items in pairs(killed) do
		if not items.neutral then
			goto next_player
		end

		local amount = 0

		for item_name, damages in pairs(items.neutral) do
			if not Statistics.is_rock(item_name) then
				goto next_item
			end

			for _, count in pairs(damages) do
				amount = amount + count
			end

			::next_item::
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end

		::next_player::
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_miners()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)

	if not mined then
    	return
    end

	local top = {}

	for player_index, items in pairs(mined) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_minable(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_deaths()
	local deaths = Statistics.get_raw_data_type(Statistics.types.deaths)

	if not deaths then
    	return
    end

	local top = {}

	for player_index, forces in pairs(deaths) do
		local amount = 0

		for force_name, reasons in pairs(forces) do
			if force_name ~= "unknown" then
				for _, count in pairs(reasons) do
					amount = amount + count
				end
			else
				amount = amount + reasons
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_railwaymans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_railway_stuff(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_runners()
	local walked = Statistics.get_raw_data_type(Statistics.types.walked)

	if not walked then
    	return
    end

	local top = {}

	for player_index, transports in pairs(walked) do
		local amount = 0

		for _, count in pairs(transports) do
			amount = amount + count
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_lumberjacks()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)

	if not mined then
    	return
    end

	local top = {}

	for player_index, items in pairs(mined) do
		local amount = 0

		for item_name, count in pairs(items) do
			if item_name == "wood" then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_mariobrothers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_pipe(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_oilmans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_oil_stuff(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_roadworkers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_walkpath(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_electricians()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)

	if not builded then
    	return
    end

	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_electric_pole(item_name) then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end

function Statistics.calculate_fishermans()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)

	if not mined then
    	return
    end

	local top = {}

	for player_index, items in pairs(mined) do
		if items["raw-fish"] then
			table.insert(top, {player_index=player_index, amount=items["raw-fish"]})
		end
	end

	if #top > 0 then
		Statistics.sort(top)
	else
		top = nil
	end

	return top
end



-- Statistics utility functions --

function Statistics.get_raw_data_type(type_name)
	if not global.statistics.raw_data[type_name] then
		global.statistics.raw_data[type_name] = {}
	end

	return global.statistics.raw_data[type_name]
end

function Statistics.get_player_raw_data_type(player_index, type_name)
    local raw_data = Statistics.get_raw_data_type(type_name)

    if not raw_data[player_index] then
        raw_data[player_index] = {}
    end

    return raw_data[player_index]
end

function Statistics.get_top(top_name)
	return Statistics["calculate_"..top_name]()
end


function Statistics.sort(top)
	table.sort(top, function(first, second) return first.amount > second.amount end)
end

function Statistics.split_version(str)
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


function Statistics.is_tree(entity_name)
	return string.match(entity_name, "tree") or entity_name == "dead-grey-trunk"
end

function Statistics.is_minable(entity_name)
	return string.match(entity_name, "ore") or entity_name == "stone" or entity_name == "coal"
end

function Statistics.is_rock(entity_name)
	return string.match(entity_name, "rock")
end

function Statistics.is_defensive_stuff(entity_name)
	return string.match(entity_name, "turret") or entity_name == "stone-wall" or entity_name == "gate"
end

function Statistics.is_oil_stuff(entity_name)
	return entity_name == "pumpjack" or entity_name == "oil-refinery" or entity_name == "chemical-plant"
		or entity_name == "pipe" or entity_name == "storage-tank"
end

function Statistics.is_railway_stuff(entity_name)
	return entity_name == "straight-rail" or entity_name == "curved-rail" or entity_name == "rail-signal"
		or entity_name == "rail-chain-signal" or entity_name == "train-stop" or entity_name == "locomotive"
		or entity_name == "cargo-wagon" or entity_name == "fluid-wagon"
end

function Statistics.is_pipe(entity_name)
	return entity_name == "pipe" or entity_name == "pipe-to-ground"
end

function Statistics.is_electric_pole(entity_name)
	return string.match(entity_name, "pole") or entity_name == "substation"
end

function Statistics.is_walkpath(entity_name)
	return entity_name == "landfill" or entity_name == "stone-path"
		or entity_name == "concrete" or entity_name == "refined-concrete"
		or entity_name == "hazard-concrete-left" or entity_name == "hazard-concrete-right"
		or entity_name == "refined-hazard-concrete-left" or entity_name == "refined-hazard-concrete-right"
end

function Statistics.is_wall(entity_name)
	return entity_name == "stane-wall" or entity_name == "mending-wall-rampant-arsenal"
		or entity_name == "reinforced-wall-rampant-arsenal"
end



-- Events handlers --

function Statistics.on_init()
	global.statistics = {}
	global.statistics.show_button = true
	global.statistics.raw_data = {}
	global.statistics.players_data = {}
end

function Statistics.on_configuration_changed(data)
	if not data then
		return
	end

	if data.mod_changes	and data.mod_changes["Fed1sServerMod"] and data.mod_changes["Fed1sServerMod"].old_version then
		-- Migrations --

		local major, minor, build = Statistics.split_version(data.mod_changes["Fed1sServerMod"].old_version)

		if major <= 1 or minor <= 1 or build < 11 then
			if global.statistics.gui then
				global.statistics.gui = nil
			end

			if not global.statistics.show_button then
				global.statistics.show_button = true
			end

			if not global.statistics.players_data then
				global.statistics.players_data = {}
			end

			for player_index, player in pairs(game.players) do
				global.statistics.players_data[player_index] = {
					current_top = Statistics.top_names[1],
					favorite_tops = {},
					pinned_tops = {},
					pin_side = "left"
				}

				local button_flow = mod_gui.get_button_flow(player)

				if button_flow.statistics_toggle_window
				and button_flow.statistics_toggle_window.valid
				then
					button_flow.statistics_toggle_window.destroy()
				end

				Statistics.create_toggle_button(player)
			end

			log("Fed1sServerMod.Statistics migrated to version "..data.mod_changes["Fed1sServerMod"].new_version)
		end
	end
end


function Statistics.on_player_created(event)
	global.statistics.players_data[event.player_index] = {
		current_top = Statistics.top_names[1],
		favorite_tops = {},
		pinned_tops = {},
		pin_side = "left"
	}

	if global.statistics.show_button then
		Statistics.create_toggle_button(game.players[event.player_index])
	end
end

function Statistics.on_player_joined_game(event)
	local player = game.players[event.player_index]

	if player.gui.screen.statistics_window then
		player.gui.screen.statistics_window.destroy()
		global.statistics.players_data[player.index].window = nil
		Statistics.close_window(global.statistics.players_data[player.index])
	end
end


function Statistics.on_player_died(event)
	local deaths = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.deaths)

	if event.cause and event.cause.valid then
		if event.cause.name == "character" then
			local killed = Statistics.get_player_raw_data_type(event.cause.player.index, Statistics.types.killed)

			if not killed.pvp then
				killed.pvp = {}
			end

			killed.pvp[event.player_index] = (killed.pvp[event.player_index] or 0) + 1

			if not deaths.pvp then
				deaths.pvp = {}
			end

			deaths.pvp[event.cause.player.index] = (deaths.pvp[event.cause.player.index] or 0) + 1
		else
			if not deaths[event.cause.force.name] then
				deaths[event.cause.force.name] = {}
			end

			local force_deaths = deaths[event.cause.force.name]
			force_deaths[event.cause.name] = (force_deaths[event.cause.name] or 0) + 1
		end
	else
		deaths.unknown = (deaths.unknown or 0) + 1
	end
end

function Statistics.on_built_entity(event)
	if not event.created_entity or not event.created_entity.valid then
		return
	end

	local builded = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.builded)

	if event.created_entity.name == "entity-ghost" then
		builded.ghosts = builded.ghosts or {}
		local count = builded.ghosts[event.created_entity.ghost_name] or 0
		builded.ghosts[event.created_entity.ghost_name] = count + 1
	else
		builded[event.created_entity.name] = (builded[event.created_entity.name] or 0) + 1
	end
end

function Statistics.on_player_built_tile(event)
	if not event.tile or not event.tile.valid
	or not event.tiles or not event.tiles.valid
	then
		return
	end

	local builded = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.builded)
	builded[event.tile.name] = (builded[event.tile.name] or 0) + #event.tiles
end

function Statistics.on_player_repaired_entity(event)
	if not event.entity or not event.entity.valid then
		return
	end

	local repaired = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.repaired)

	-- Counting not precisely, but tssss!

	if Statistics.is_wall(event.entity.name) then
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 4
	else
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 2
	end
end

function Statistics.on_entity_died(event)
	if not event.entity or not event.entity.valid or event.entity.name == "character" then
		return
	end

	if not event.cause or not event.cause.valid or event.cause.name ~= "character" then
		return
	end

	if not event.damage_type or not event.damage_type.valid then
		return
	end

	local killed = Statistics.get_player_raw_data_type(event.cause.player.index, Statistics.types.killed)

	if not killed[event.entity.force.name] then
		killed[event.entity.force.name] = {}
	end

	if not killed[event.entity.force.name][event.entity.name] then
		killed[event.entity.force.name][event.entity.name] = {}
	end

	local enemy = killed[event.entity.force.name][event.entity.name]
	enemy[event.damage_type.name] = (enemy[event.damage_type.name] or 0) + 1
end

function Statistics.on_player_mined_item(event)
	if not event.item_stack then
		return
	end

	local mined = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.mined)
	mined[event.item_stack.name] = (mined[event.item_stack.name] or 0) + event.item_stack.count
end

function Statistics.on_player_crafted_item(event)
	if not event.item_stack then
		return
	end

	local crafted = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.crafted)
	crafted[event.item_stack.name] = (crafted[event.item_stack.name] or 0) + event.item_stack.count
end

function Statistics.on_player_changed_position(event)
	local walked = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.walked)
	local player = game.players[event.player_index]
	local count, vehicle

	if player.vehicle then
		vehicle = player.vehicle.name
	else
		vehicle = "feet"
	end

	count = (walked[vehicle] or 0) + 1
	walked[vehicle] = count
end


function Statistics.on_top(event)
	local self_player

	if event.player_index then
		self_player = game.players[event.player_index]
	else
		self_player = rcon
	end

	if not event.parameter or event.parameter == "" then
		self_player.print({"statistics.heading-1", {"statistics.all-categories"}})

		for index, top_name in pairs(Statistics.top_names) do
			self_player.print({
				"", index, ". ",
				{"statistics.heading-1", {"statistics."..top_name}}, " - ",
				{"statistics."..top_name.."-info"}
			})
		end
	else
		local top_id = tonumber(event.parameter)

		if not top_id or top_id % 1 > 0 or top_id < 1 or top_id > #Statistics.top_names then
			self_player.print({"statistics.wrong-parameter"})
			return
		end

		local top_name = Statistics.top_names[top_id]
		local top = Statistics.get_top(top_name)

		if not top or #top == 0 then
			self_player.print({"statistics.no-data"})
			return
		end

		local max_index = #top

		if max_index > 10 then
			max_index = 10
		end

		if self_player.object_name and self_player.object_name == "LuaRCON" then
			self_player.print("statistics."..top_name)
		else
			self_player.print({"statistics.heading-1", {"statistics."..top_name}}, {0.8, 0.8, 0})
			self_player.print({"statistics.heading-3", {"statistics."..top_name.."-info"}}, {0.8, 0.8, 0.8})
		end

		for index = 1, max_index do
			local player = game.players[top[index].player_index]
			self_player.print(index..". "..player.name.." - "..top[index].amount)
		end
	end
end


function Statistics.on_toggle_statistics_window(event)
	local player_data = global.statistics.players_data[event.player_index]

	if player_data.window then
		Statistics.close_window(player_data)
		return
	end

	local window = Statistics.build_statistics_window(game.players[event.player_index])

	Statistics.build_top_data(player_data)

	window.force_auto_center()
	game.players[event.player_index].opened = window
end

function Statistics.on_close_statistics_window(event)
	Statistics.close_window(global.statistics.players_data[event.player_index])
end

function Statistics.on_gui_closed(event)
	if not event.player_index then
        return
    end

    if event.gui_type ~= defines.gui_type.custom then
        return
    end

    if not event.element or not event.element.valid then
        return
    end

    if event.element.name == "statistics_window" then
        Statistics.close_window(global.statistics.players_data[event.player_index])
    end
end


function Statistics.on_top_click(event)
	if not event.element.tags or not event.element.tags.top_name then
		return
	end

	local player_data = global.statistics.players_data[event.player_index]
	player_data.current_top = event.element.tags.top_name

	Statistics.build_top_data(player_data)
end

function Statistics.on_gui_checked_state_changed(event)
	local element = event.element

	if not element or not element.valid then
		return
	end

	if element.name ~= "statistics_show_all_checkbox" then
		return
	end

	for _, player in pairs(game.players) do
		if not player.admin then

			if element.state then
				Statistics.create_toggle_button(player, true)
			else
				local button_flow = mod_gui.get_button_flow(player)

				if button_flow.statistics_toggle_window_button
				and button_flow.statistics_toggle_window_button.valid
				then
					button_flow.statistics_toggle_window_button.destroy()
				end

				Statistics.close_window(global.statistics.players_data[player.index])
			end
		end
	end

	global.statistics.show_button = element.state
end

function Statistics.on_gui_click(event)
    if not event.element or not event.element.valid then
        return
    end

    local element_name = event.element.name

    if Statistics.gui_click_events[element_name] then
        Statistics.gui_click_events[element_name](event)
    elseif string.match(element_name, "statistics_top_") then
        Statistics.on_top_click(event)
    end
end

Statistics.gui_click_events = {
	["statistics_toggle_window_button"] = Statistics.on_toggle_statistics_window,
	["statistics_close_window_button"] = Statistics.on_close_statistics_window
}



-- Profiler and debug --

function on_toggle_profiler(event)
	local player = game.players[event.player_index]
	if not player.admin then
		return
	end

	if not global.statistics.profiler_gui then
		global.statistics.profiler_gui = {}
	end

	if global.statistics.profiler_gui[event.player_index] then
		global.statistics.profiler_gui[event.player_index].destroy()
		global.statistics.profiler_gui[event.player_index] = nil
		return
	end

	global.statistics.profiler_gui[event.player_index] = player.gui.left.add{type="text-box"}
	global.statistics.profiler_gui[event.player_index].style.width = 400
	global.statistics.profiler_gui[event.player_index].style.height = 600
end

function on_print(event)
	printp(serpent.block(global.statistics.raw_data))
end

function printp(caption, add)
	if not global.statistics.profiler_gui then
		return
	end

	if add then 
		global.statistics.profiler_gui.caption = {"", global.statistics.profiler_gui.caption, "\n", caption}
	else
		global.statistics.profiler_gui.caption = caption
	end
end


commands.add_command("profiler", "", on_toggle_profiler)
commands.add_command("print", "", on_print)



-- Module events handler --

local events = {}

events.on_init = Statistics.on_init
events.on_configuration_changed = Statistics.on_configuration_changed

events.events = {
	[defines.events.on_player_created] = Statistics.on_player_created,
	[defines.events.on_player_joined_game] = Statistics.on_player_joined_game,
	[defines.events.on_player_changed_position] = Statistics.on_player_changed_position,
	[defines.events.on_player_died] = Statistics.on_player_died,
	[defines.events.on_built_entity] = Statistics.on_built_entity,
	[defines.events.on_player_built_tile] = Statistics.on_player_built_tile,
	[defines.events.on_player_repaired_entity] = Statistics.on_player_repaired_entity,
	[defines.events.on_entity_died] = Statistics.on_entity_died,
	[defines.events.on_player_mined_item] = Statistics.on_player_mined_item,
	[defines.events.on_player_crafted_item] = Statistics.on_player_crafted_item,
	[defines.events.on_gui_click] = Statistics.on_gui_click,
	[defines.events.on_gui_closed] = Statistics.on_gui_closed,
	[defines.events.on_gui_checked_state_changed] = Statistics.on_gui_checked_state_changed
}

EventHandler.add_lib(events)


commands.add_command("top", "", Statistics.on_top)



--

return Statistics