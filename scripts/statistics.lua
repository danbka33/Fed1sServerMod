-- Copyright © Ajick 2023


local mod_gui = require("__core__/lualib/mod-gui")



-- Constans and variables --

local Statistics = {}

Statistics.counter = 1

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
Statistics.tops = {}
for _, top_name in pairs(Statistics.top_names) do
	Statistics.tops[top_name] = top_name
end



-- Staistics GUI --

function Statistics.create_toggle_button(target_player, player_data)
	local button_flow = mod_gui.get_button_flow(target_player)
	local toggle_button = button_flow.statistics_toggle_window
	
	if toggle_button then
		toggle_button.destroy()
	end

	player_data.toggle_button = button_flow.add{
		type = "sprite-button",
		name = "statistics_toggle_window",
		sprite = "statistics_white",
		hovered_sprite = "statistics_black",
		clicked_sprite = "statistics_black",
		tooltip = {"statistics.caption"}
	}
end


function Statistics.build_statistics_window(player)
	local window = player.gui.screen.add{type="frame", name="statistics_window", direction="vertical"}
	window.style.width = 900
	window.style.height = 700


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
		style = "frame_action_button"
	}


	-- Content --

	local content = window.add{type="flow", name="content", direction="horizontal"}
	content.style.margin = 10
	content.style.horizontally_stretchable = true


	-- Tops list --

	local tops = content.add{type="scroll-pane", name="tops", direction="vertical"}
	-- tops.style.horizontally_stretchable = true
	tops.style.width = 300
	
	for _, top_name in pairs(Statistics.top_names) do
		local label = tops.add{
			type = "label",
			name = "statistics_top_"..top_name,
			caption = {"statistics."..top_name},
			tags = {top_name=top_name}
		}
			-- style = "subheader_caption_label",
		-- label.style.margin = 10
	end


	-- Top table --

	local top = content.add{type="flow", name="top", direction="vertical"}
	top.style.margin = 10
	-- top.style.horizontally_stretchable = true

	local top_header = top.add{type="label", name="place"}
		-- style = "subheader_caption_label"
	-- top_header.style.margin = 10

	local top_subheader = top.add{type="label", name="player"}
		-- style = "subheader_caption_label"
	-- top_subheader.style.margin = 10


	-- Top table header --

	local header = top.add{type="table", name="header", column_count=3, ignored_by_interaction=true}
	-- header.style.margin = 10
	header.style.horizontally_stretchable = true

	local label_place = header.add{
		type = "label",
		name = "place",
		caption = {"statistics.caption-place"}
	}
		-- style = "subheader_caption_label"
	-- label_place.style.margin = 10

	local label_player = header.add{
		type = "label",
		name = "player",
		caption = {"statistics.caption-player"},
		style = "subheader_caption_label"
	}
	-- label_player.style.margin = 10

	local label_amount = header.add{
		type = "label",
		name = "amount",
		caption = {"statistics.caption-amount"},
		style = "subheader_caption_label"
	}
	-- label_amount.style.margin = 10


	-- Top table --

	local scrolled_data = top.add{type="scroll-pane", name="scrolled_data", direction="vertical"}
	-- scrolled_data.style.horizontally_stretchable = true
	-- scrolled_data.style.width = 300

	local data = scrolled_data.add{type="table", name="data", column_count=3, ignored_by_interaction=true}
	-- data.style.margin = 10
	data.style.horizontally_stretchable = true


	--

	global.statistics.players_data[player.index].window = window
	global.statistics.players_data[player.index].top_header = top_header
	global.statistics.players_data[player.index].top_subheader = top_subheader
	global.statistics.players_data[player.index].top_data = data


	--

	return window
end


function Statistics.build_top_data(player_data)
	Statistics["calculate_"..player_data.current_top]()
	local top = Statistics.get_top(player_data.current_top)

	if not player_data.current_top then
		player_data.current_top = Statistics.top_names[1]
		player_data.pinned_tops = {}
		player_data.pin_side = "left"
	end

	player_data.top_header.caption = {"statistics."..player_data.current_top}
	player_data.top_subheader.caption = {"statistics."..player_data.current_top.."-info"}

	player_data.top_data.clear()

	if #top < 1 then
		player_data.top_data.add{
			type = "label",
			caption = {"statistics.no-data"}
		} -- , style = "subheader_caption_label"
	end

	for place, data in pairs(top) do
		player_data.top_data.add{
			type = "label",
			caption = place
		} -- , style = "subheader_caption_label"

		player_data.top_data.add{
			type = "label",
			caption = game.players[data.player_index].name
		} -- , style = "subheader_caption_label"

		player_data.top_data.add{
			type = "label",
			caption = data.amount
		} -- , style = "subheader_caption_label"
	end
end


-- Statistics calculation functions --

function Statistics.calculate_builders()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local amount = 0

		for item_name, count in pairs(items) do
			if item_name ~= "ghosts" then
				amount = amount + count
			end
		end

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort_and_set_top(top, Statistics.tops.builders)
	end
end

function Statistics.calculate_architectors()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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
		Statistics.sort_and_set_top(top, Statistics.tops.architectors)
	end
end

function Statistics.calculate_military_enginears()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	local function calculate(items)
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_defensive_stuff(item_name) then
				amount = amount + count
			elseif item_name == "ghosts" then
				amount = amount + calculate(count)
			end
		end

		return amount
	end

	for player_index, items in pairs(builded) do
		local amount = calculate(items)

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort_and_set_top(top, Statistics.tops.military_enginears)
	end
end

function Statistics.calculate_crafters()
	local crafted = Statistics.get_raw_data_type(Statistics.types.crafted)
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
		Statistics.sort_and_set_top(top, Statistics.tops.crafters)
	end
end

function Statistics.calculate_repairemans()
	local repaired = Statistics.get_raw_data_type(Statistics.types.repaired)
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
		Statistics.sort_and_set_top(top, Statistics.tops.repairemans)
	end
end

function Statistics.calculate_wariors()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
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
		Statistics.sort_and_set_top(top, Statistics.tops.wariors)
	end
end

function Statistics.calculate_tree_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
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

			for name, count in pairs(damages) do
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
		Statistics.sort_and_set_top(top, Statistics.tops.tree_haters)
	end
end

function Statistics.calculate_rock_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
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

			for name, count in pairs(damages) do
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
		Statistics.sort_and_set_top(top, Statistics.tops.rock_haters)
	end
end

function Statistics.calculate_miners()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
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
		Statistics.sort_and_set_top(top, Statistics.tops.miners)
	end
end

function Statistics.calculate_deaths()
	local deaths = Statistics.get_raw_data_type(Statistics.types.deaths)
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
		Statistics.sort_and_set_top(top, Statistics.tops.deaths)
	end
end

function Statistics.calculate_railwaymans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	local function calculate(items)
		local amount = 0

		for item_name, count in pairs(items) do
			if Statistics.is_railway_stuff(item_name) then
				amount = amount + count
			elseif item_name == "ghosts" then
				amount = amount + calculate(count)
			end
		end

		return amount
	end

	for player_index, items in pairs(builded) do
		local amount = calculate(items)

		if amount > 0 then
			table.insert(top, {player_index=player_index, amount=amount})
		end
	end

	if #top > 0 then
		Statistics.sort_and_set_top(top, Statistics.tops.railwaymans)
	end
end

function Statistics.calculate_runners()
	local walked = Statistics.get_raw_data_type(Statistics.types.walked)
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
		Statistics.sort_and_set_top(top, Statistics.tops.runners)
	end
end

function Statistics.calculate_lumberjacks()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
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
		Statistics.sort_and_set_top(top, Statistics.tops.lumberjacks)
	end
end

function Statistics.calculate_mariobrothers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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
		Statistics.sort_and_set_top(top, Statistics.tops.mariobrothers)
	end
end

function Statistics.calculate_oilmans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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
		Statistics.sort_and_set_top(top, Statistics.tops.oilmans)
	end
end

function Statistics.calculate_roadworkers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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
		Statistics.sort_and_set_top(top, Statistics.tops.roadworkers)
	end
end

function Statistics.calculate_electricians()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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
		Statistics.sort_and_set_top(top, Statistics.tops.electricians)
	end
end

function Statistics.calculate_fishermans()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
	local top = {}

	for player_index, items in pairs(mined) do
		if items["raw-fish"] then
			table.insert(top, {player_index=player_index, amount=items["raw-fish"]})
		end
	end

	if #top > 0 then
		Statistics.sort_and_set_top(top, Statistics.tops.fishermans)
	end
end


-- Statistics utility functions --

function Statistics.get_raw_data_type(type_name)
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
	return global.statistics.tops[top_name] or {}
end



function Statistics.sort_and_set_top(top, top_name)
	table.sort(top, function(first, second) return first.amount > second.amount end)
	global.statistics.tops[top_name] = top
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



-- Events handlers --

function Statistics.on_init()
	global.statistics = global.statistics or {}
	global.statistics.raw_data = global.statistics.raw_data or {}
	global.statistics.tops = global.statistics.tops or {}
	global.statistics.players_data = global.statistics.players_data or {}
	global.statistics.gui = global.statistics.gui or {}
end

function Statistics.on_configuration_changed(data)
	Statistics.on_init()

	for player_index, player in pairs(game.players) do
		Statistics.create_toggle_button(player, global.statistics.players_data[player_index])
	end

	-- migrations

	if not data then
		return
	end

	if data.mod_changes
	and data.mod_changes["Fed1sServerMod"]
	and data.mod_changes["Fed1sServerMod"].old_version == "1.1.2"
	then
		for _, top_name in pairs(Statistics.top_names) do
			global.statistics.tops[top_name] = {}
		end

		for player_index, player in pairs(game.players) do
			global.statistics.players_data[player_index] = {
				current_top = Statistics.top_names[1],
				pinned_tops = {},
				pin_side = "left"
			}
		end
	end
end

function Statistics.on_nth_tick(event)
	-- local profiler = game.create_profiler()
	Statistics["calculate_"..Statistics.top_names[Statistics.counter]]()
	-- profiler.stop()
	-- printp({"", Statistics.top_names[Statistics.counter], " - ", profiler})
	-- local top_name = Statistics.top_names[Statistics.counter]
	-- printp(top_name..":\n\n"..serpent.block(Statistics.get_top(top_name)))

	if Statistics.counter < table_size(Statistics.tops) then
		Statistics.counter = Statistics.counter + 1
	else
		Statistics.counter = 1
	end
end

function Statistics.on_player_created(event)
	if not global.statistics.players_data then
		global.statistics.players_data = {}
	end

	global.statistics.players_data[event.player_index] = {
		current_top = global.statistics.top_names[1],
		pinned_tops = {},
		pin_side = "left"
	}

	Statistics.create_toggle_button(
		game.players[event.player_index],
		global.statistics.players_data[event.player_index]
	)
end

function Statistics.on_player_joined_game(event)
	if not global.statistics then
		Statistics.on_init()
	end

	if global.statistics.gui[event.player_index] and global.statistics.gui[event.player_index].window then
		global.statistics.gui[event.player_index].window.destroy()
		global.statistics.gui[event.player_index].window = nil
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
	if not event.tile or not event.tile.valid then
		return
	end

	local builded = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.builded)
	builded[event.tile.name] = (builded[event.tile.name] or 0) + #event.tiles
end

function Statistics.on_player_repaired_entity(event)
	if not event.entity or not event.entity.valid then
		return
	end

	-- Counting not precisely, but tssss!

	local repaired = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.repaired)

	if event.entity.name == "stone-wall" then
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
	local self_player = game.players[event.player_index]

	if not event.parameter or event.parameter == "" or event.parameter == "list" then
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

		Statistics["calculate_"..top_name]()

		local top = Statistics.get_top(top_name)

		if not top or #top == 0 then
			self_player.print({"statistics.no-data"})
			return
		end

		local max_index = table_size(top)

		if max_index > 10 then
			max_index = 10
		end

		self_player.print({"statistics.heading-1", {"statistics."..top_name}}, {0.8, 0.8, 0})
		self_player.print({"statistics.heading-3", {"statistics."..top_name.."-info"}}, {0.8, 0.8, 0.8})

		for index = 1, max_index do
			local player = game.players[top[index].player_index]
			self_player.print(index..". "..player.name.." - "..top[index].amount)
		end
	end
end


function Statistics.on_toggle_statistics_window(event)
	local player_data = global.statistics.players_data[event.player_index]

	if player_data.window then
		player_data.window.destroy()
		player_data.window = nil
		player_data.top_header = nil
		player_data.top_subheader = nil
		player_data.top_data = nil
		return
	end

	local window = Statistics.build_statistics_window(game.players[event.player_index], player_data)

	Statistics.build_top_data(player_data)

	window.force_auto_center()
end

function Statistics.on_close_statistics_window(event)
	local player_data = global.statistics.players_data[event.player_index]

	player_data.window.destroy()
	player_data.window = nil
	player_data.top_header = nil
	player_data.top_subheader = nil
	player_data.top_data = nil
end


function Statistics.on_top_click(event)
	if not event.element or not event.element.valid then
		return
	end

	if not event.element.tags or not event.element.tags.top_name then
		return
	end

	local player_data = global.statistics.players_data[event.player_index]

	player_data.current_top = event.element.tags.top_name

	Statistics.build_top_data(player_data)
end

function Statistics.on_gui_click(event)
    if not event.element.valid then
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
	["statistics_toggle_window"] = Statistics.on_toggle_statistics_window,
	["statistics_close_window_button"] = Statistics.on_close_statistics_window
}

	-- ["statistics_clear_search"] = Statistics.on_clear_search,

	-- ["statistics_expand_button"] = Statistics.on_toggle_expand_panel,

	-- ["statistics_follow_button"] = Statistics.on_follow_player,
	-- ["statistics_favorite_button"] = Statistics.on_favorite_click,

	-- ["statistics_promotion_button"] = Statistics.on_promotion_click,

	-- ["statistics_warn_button"] = Statistics.on_punish_player,
	-- ["statistics_mute_button"] = Statistics.on_mute_click,
	-- ["statistics_kick_button"] = Statistics.on_punish_player,
	-- ["statistics_ban_button"] = Statistics.on_ban_click,

	-- ["statistics_accept_punishment_button"] = Statistics.on_punishment_accept,
	-- ["statistics_cancel_punishment_button"] = Statistics.on_punishment_closecancel,
	-- ["statistics_close_accept_prompt_window_button"] = Statistics.on_punishment_closecancel,

	-- ["statistics_give_button"] = Statistics.on_give_button_click,
	-- ["statistics_take_selected_button"] = Statistics.on_take_selected_click



-- Profiler and debug --

function on_reinit(event)
	-- global.statistics = nil
	Statistics.on_init()
	-- global.statistics.raw_data.deaths = {}
end

function on_toggle_profiler(event)
	if not game.players[event.player_index].admin then
		return
	end

	if global.statistics.profiler_gui then
		global.statistics.profiler_gui.destroy()
		global.statistics.profiler_gui = nil
		return
	end

	global.statistics.profiler_gui = game.players[event.player_index].gui.left.add{type="text-box", caption="New Profiler"}
	global.statistics.profiler_gui.style.width = 400
	global.statistics.profiler_gui.style.height = 600

	printp(serpent.block(global.statistics.raw_data))
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



-- commands.add_command("reinit", "", on_reinit)
-- commands.add_command("profiler", "", on_toggle_profiler)
-- commands.add_command("print", "", on_print)



-- Module events handler --

local events = {}
events.on_init = Statistics.on_init
events.on_configuration_changed = Statistics.on_configuration_changed
-- events.on_nth_tick = {}
-- events.on_nth_tick[180] = Statistics.on_nth_tick
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
	[defines.events.on_gui_click] = Statistics.on_gui_click
}

EventHandler.add_lib(events)


commands.add_command("top", "", Statistics.on_top)



--

return Statistics