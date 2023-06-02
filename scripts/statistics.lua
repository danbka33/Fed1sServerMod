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
	"builders",
	"architectors",
	"war_enginears",
	"crafters",
	"reparemans",
	"wariors",
	"tree_haters",
	"rock_haters",
	"miners",
	"sueciders",
	"railwaymans",
}
	-- "oilmans",



-- Statistics calculation functions --

function Statistics.calculate_builders()
	-- body
end

function Statistics.calculate_architectors()
	-- body
end

function Statistics.calculate_war_enginears()
	-- body
end

function Statistics.calculate_crafters()
	-- body
end

function Statistics.calculate_reparemans()
	-- body
end

function Statistics.calculate_wariors()
	-- body
end

function Statistics.calculate_tree_haters()
	-- body
end

function Statistics.calculate_rock_haters()
	-- body
end

function Statistics.calculate_miners()
	-- body
end

function Statistics.calculate_sueciders()
	-- body
end

function Statistics.calculate_railwaymans()
	-- body
end



-- Statistics utility functions --

function Statistics.get_players_default_rawdata()
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

function Statistics.get_player_rawdata_type(player_index, type_name)
	if not global.statistics then -- Blow on water
		Statistics.on_init()
	end

	if not global.statistics.rawdata[player_index] then
		global.statistics.rawdata[player_index] = Statistics.get_players_default_rawdata()
	end

	if not global.statistics.rawdata[player_index][type_name] then
		global.statistics.rawdata[player_index][type_name] = {}
	end

	return global.statistics.rawdata[player_index][type_name]
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
	global.statistics.rawdata[event.player_index] = Statistics.get_players_default_rawdata()
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
	builded[event.tiles.name] = (builded[event.tiles.name] or 0) + event.tiles.count
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
	local walk_distance = Statistics.get_player_rawdata_type(event.player_index, Statistics.types.walked)
	local count = walk_distance[1] or 0
	count = count + 1
	walk_distance[1] = count
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

	global.statistics[event.player_index] = Statistics.get_players_default_rawdata()

	if global.profiler_gui then
		global.profiler_gui.destroy()
		global.profiler_gui = nil
	end

	global.profiler = nil
end

function on_toggle_profiler(event)
	if global.profiler_gui then
		global.profiler_gui.destroy()
		global.profiler_gui = nil
		global.profiler = nil
		return
	end

	global.profiler_gui = game.players[event.player_index].gui.left.add{type="text-box", caption="New Profiler"}
	global.profiler_gui.style.width = 400
	global.profiler_gui.style.height = 600
end

function on_test(event)
	printp(serpent.block(global.statistics[event.player_index]))
	-- printp(serpent.block(Statistics.get_players_default_rawdata()))
end

commands.add_command("profiler", "", on_toggle_profiler)
commands.add_command("test", "", on_test)
commands.add_command("reinit", "", on_reinit)




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