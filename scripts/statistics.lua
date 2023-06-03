-- @ Ajick 2023

local Statistics = {}

Statistics.counter = 1

Statistics.types = {
	builded = "builded",
	killed = "killed",
	deaths = "deaths",
	repaired = "repaired",
	mined = "mined",
	crafted = "crafted",
	walked = "walked"
}

Statistics.tops = {
	builders = "builders",
	architectors = "architectors",
	war_enginears = "war_enginears",
	crafters = "crafters",
	repairemans = "repairemans",
	wariors = "wariors",
	tree_haters = "tree_haters",
	rock_haters = "rock_haters",
	miners = "miners",
	sueciders = "sueciders",
	railwaymans = "railwaymans",
	runners = "runners",
	lumberjacks = "lumberjacks",
	mariobrothers = "mariobrothers"
}
	-- "oilmans",



-- Statistics calculation functions --

function Statistics.calculate_builders()
	local builded = Statistics.get_rawdata_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for name, count in pairs(items) do
			if name ~= "ghots" then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.builders)
end

function Statistics.calculate_architectors()
	local builded = Statistics.get_rawdata_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		if not items.ghosts then
			goto continue
		end

		local record = {player_index=player_index, count=0}

		for _, count in pairs(items.ghosts) do
			record.count = record.count + count
		end

		table.insert(top, record)

		::continue::
	end

	Statistics.sort_and_set_top(top, Statistics.tops.architectors)
end

function Statistics.calculate_war_enginears() -- NotImplemented
	-- body
end

function Statistics.calculate_crafters()
	local crafted = Statistics.get_rawdata_type(Statistics.types.crafted)
	local top = {}

	for player_index, items in pairs(crafted) do
		local record = {player_index=player_index, count=0}

		for _, count in pairs(items) do
			record.count = record.count + count
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.crafters)
end

function Statistics.calculate_repairemans()
	local repaired = Statistics.get_rawdata_type(Statistics.types.repaired)
	local top = {}

	for player_index, items in pairs(repaired) do
		local record = {player_index=player_index, count=0}

		for _, count in pairs(items) do
			record.count = record.count + count
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.repairemans)
end

function Statistics.calculate_wariors()
	local kiiled = Statistics.get_rawdata_type(Statistics.types.kiiled)
	local top = {}

	for player_index, items in pairs(kiiled) do
		if not items.enemy then
			goto continue
		end

		local record = {player_index=player_index, count=0}

		for _, damages in pairs(items.enemy) do
			for name, count in pairs(damages) do
				record.count = record.count + count
			end
		end

		table.insert(top, record)

		::continue::
	end

	Statistics.sort_and_set_top(top, Statistics.tops.wariors)
end

function Statistics.calculate_tree_haters() -- NotImplemented
	-- body
end

function Statistics.calculate_rock_haters() -- NotImplemented
	-- body
end

function Statistics.calculate_miners() -- NotImplemented
	-- body
end

function Statistics.calculate_sueciders() -- NotImplemented
	-- body
end

function Statistics.calculate_railwaymans() -- NotImplemented
	-- body
end



-- Statistics utility functions --

function Statistics.get_player_default_rawdata()
	return {
		[Statistics.types.builded] = {},
		[Statistics.types.killed] = {},
		[Statistics.types.deaths] = {},
		[Statistics.types.repaired] = {},
		[Statistics.types.mined] = {},
		[Statistics.types.crafted] = {},
		[Statistics.types.walked] = {}
	}
end

function Statistics.get_player_rawdata_type(player_index, type_id)
	if not global.statistics then -- Blow on water
		Statistics.on_init()
	end

	if not global.statistics.rawdata[player_index] then
		global.statistics.rawdata[player_index] = Statistics.get_player_default_rawdata()
	end

	if not global.statistics.rawdata[player_index][type_id] then
		global.statistics.rawdata[player_index][type_id] = {}
	end

	return global.statistics.rawdata[player_index][type_id]
end

function Statistics.get_rawdata_type(type_id)
	return global.statistics.rawdata[type_id] or {}
end

function Statistics.get_top(top_id)
	return global.statistics.tops[top_id] or {}
end



function Statistics.sort_and_set_top(top, top_id)
	table.sort(top, function(first, second) return first.count > second.count end)
	global.statistics.tops[top_id] = top
end



function Statistics.is_tree(entity_name)
	return string.match(entity_name, "tree") or entity_name == "dead-grey-trunk"
end

function Statistics.is_minable(entity_name)
	return string.match(entity_name, "ore") or entity_name == "wood" or entity_name == "stone"
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



-- Events handlers --

function Statistics.on_init()
	global.statistics = global.statistics or {}
	global.statistics.gui = global.statistics.gui or {}
	global.statistics.rawdata = global.statistics.rawdata or {}
	global.statistics.tops = global.statistics.tops or {}

	for _, top_name in pairs(Statistics.tops) do
		global.statistics.tops[top_name] = global.statistics.tops[top_name] or {}
	end
end

function Statistics.on_configuration_changed(data)
	Statistics.on_init()
end

function Statistics.on_nth_tick(event)
	-- Statistics["calculate_"..Statistics.tops[Statistics.counter]]()

	if Statistics.counter < table_size(Statistics.tops) then
		Statistics.counter = Statistics.counter + 1
	else
		Statistics.counter = 1
	end
end



function Statistics.on_player_created(event)
	global.statistics.rawdata[event.player_index] = Statistics.get_player_default_rawdata()
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
	local deaths = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.deaths)

	if event.cause then
		deaths[event.cause.name] = (deaths[event.cause.name] or 0) + 1
	else
		deaths.undefined = (deaths.undefined or 0) + 1
	end
end



function Statistics.on_built_entity(event)
	local builded = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.builded)

	if event.created_entity.name == "entity-ghost" then
		builded.ghosts = builded.ghosts or {}
		local count = builded.ghosts[event.created_entity.ghost_name] or 0
		builded.ghosts[event.created_entity.ghost_name] = count + 1
	else
		builded[event.created_entity.name] = (builded[event.created_entity.name] or 0) + 1
	end
end

function Statistics.on_player_built_tile(event)
	local builded = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.builded)
	builded[event.tile.name] = (builded[event.tile.name] or 0) + #event.tiles
end

function Statistics.on_player_repaired_entity(event)
	-- Counting not precisely, but tssss!

	local repaired = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.repaired)

	if event.entity.name == "stone-wall" then
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 4
	else
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 2
	end
end

function Statistics.on_entity_died(event)
	if not event.force or event.force.name ~= "player" then
		return
	end

	if not event.cause or event.cause.name ~= "character" then
		return
	end

	local killed = Statistics.get_player_rawdata_type(event.cause.player.index, Statistics.types.killed)

	if not killed[event.entity.force.name] then
		killed[event.entity.force.name] = {}
	end

	if not killed[event.entity.force.name][event.entity.name] then
		killed[event.entity.force.name][event.entity.name] = {}
	end

	local entity = killed[event.entity.force.name][event.entity.name]
	local count = entity[event.damage_type.name] or 0

	entity[event.damage_type.name] = count + 1
end

function Statistics.on_player_mined_item(event)
	local mined = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.mined)
	mined[event.item_stack.name] = (mined[event.item_stack.name] or 0) + event.item_stack.count
end

function Statistics.on_player_crafted_item(event)
	local crafted = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.crafted)
	crafted[event.item_stack.name] = (crafted[event.item_stack.name] or 0) + event.item_stack.count
end

function Statistics.on_player_changed_position(event)
	local walked = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.walked)
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



-- Profiler and debug --

local profiler, profiler_gui

function printp(caption)
	if not global.profiler_gui then
		return
	end

	global.profiler_gui.caption = caption
end

function on_reinit(event)
	Statistics.on_init()

	global.statistics[event.player_index] = Statistics.get_player_default_rawdata()

	if global.profiler_gui then
		global.profiler_gui.destroy()
		global.profiler_gui = nil
	end

	global.profiler = nil
end

function on_toggle_profiler(event)
	if not game.players[event.player_index].admin then
		return
	end

	if global.profiler_gui then
		global.profiler_gui.destroy()
		global.profiler_gui = nil
		global.profiler = nil
		return
	end

	global.profiler_gui = game.players[event.player_index].gui.left.add{type="text-box", caption="New Profiler"}
	global.profiler_gui.style.width = 400
	global.profiler_gui.style.height = 600

	printp(serpent.block(global.statistics.rawdata[event.player_index]))
end

function on_printall(event)
	printp(serpent.block(global.statistics.rawdata))
end

function on_printself(event)
	printp(serpent.block(global.statistics.rawdata[event.player_index]))
end

-- commands.add_command("reinit", "", on_reinit)
commands.add_command("profiler", "", on_toggle_profiler)
commands.add_command("printall", "", on_printall)
commands.add_command("printself", "", on_printself)



-- Module events handler --

local events = {}
events.on_init = Statistics.on_init
events.on_configuration_changed = Statistics.on_configuration_changed
-- events.on_nth_tick = {}
-- events.on_nth_tick[300] = Statistics.on_nth_tick
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
	[defines.events.on_player_crafted_item] = Statistics.on_player_crafted_item
}

EventHandler.add_lib(events)



--

return Statistics