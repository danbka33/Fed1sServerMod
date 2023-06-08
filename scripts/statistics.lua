-- @ Ajick 2023

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
	"war_enginears",
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



-- Statistics calculation functions --

function Statistics.calculate_builders()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if item_name ~= "ghosts" then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.builders)
end

function Statistics.calculate_architectors()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
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

function Statistics.calculate_war_enginears()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	local function calculate(items)
		local total_count = 0

		for item_name, count in pairs(items) do
			if Statistics.is_defensive_stuff(item_name) then
				total_count = total_count + count
			elseif item_name == "ghosts" then
				total_count = total_count + calculate(count)
			end
		end

		return total_count
	end

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=calculate(items)}
		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.war_enginears)
end

function Statistics.calculate_crafters()
	local crafted = Statistics.get_raw_data_type(Statistics.types.crafted)
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
	local repaired = Statistics.get_raw_data_type(Statistics.types.repaired)
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
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
	local top = {}

	for player_index, items in pairs(killed) do
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

function Statistics.calculate_tree_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
	local top = {}

	for player_index, items in pairs(killed) do
		if not items.neutral then
			goto next_player
		end

		local record = {player_index=player_index, count=0}

		for item_name, damages in pairs(items.neutral) do
			if not Statistics.is_tree(item_name) then
				goto next_item
			end

			for name, count in pairs(damages) do
				record.count = record.count + count
			end

			::next_item::
		end

		table.insert(top, record)

		::next_player::
	end

	Statistics.sort_and_set_top(top, Statistics.tops.tree_haters)
end

function Statistics.calculate_rock_haters()
	local killed = Statistics.get_raw_data_type(Statistics.types.killed)
	local top = {}

	for player_index, items in pairs(killed) do
		if not items.neutral then
			goto next_player
		end

		local record = {player_index=player_index, count=0}

		for item_name, damages in pairs(items.neutral) do
			if not Statistics.is_rock(item_name) then
				goto next_item
			end

			for name, count in pairs(damages) do
				record.count = record.count + count
			end

			::next_item::
		end

		table.insert(top, record)

		::next_player::
	end

	Statistics.sort_and_set_top(top, Statistics.tops.rock_haters)
end

function Statistics.calculate_miners()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
	local top = {}

	for player_index, items in pairs(mined) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if Statistics.is_minable(item_name) then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.miners)
end

function Statistics.calculate_deaths()
	local deaths = Statistics.get_raw_data_type(Statistics.types.deaths)
	local top = {}

	for player_index, forces in pairs(deaths) do
		local record = {player_index=player_index, count=0}


		for force_name, reasons in pairs(forces) do
			if force_name ~= "unknown" then
				for _, count in pairs(reasons) do
					record.count = record.count + count
				end
			else
				record.count = record.count + reasons
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.deaths)
end

function Statistics.calculate_railwaymans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	local function calculate(items)
		local total_count = 0

		for item_name, count in pairs(items) do
			if Statistics.is_railway_stuff(item_name) then
				total_count = total_count + count
			elseif item_name == "ghosts" then
				total_count = total_count + calculate(count)
			end
		end

		return total_count
	end

	for player_index, items in pairs(builded) do
		table.insert(top, {player_index=player_index, count=calculate(items)})
	end

	Statistics.sort_and_set_top(top, Statistics.tops.railwaymans)
end

function Statistics.calculate_runners()
	local walked = Statistics.get_raw_data_type(Statistics.types.walked)
	local top = {}

	for player_index, transports in pairs(walked) do
		local record = {player_index=player_index, count=0}

		for _, count in pairs(transports) do
			record.count = record.count + count
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.runners)
end

function Statistics.calculate_lumberjacks()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
	local top = {}

	for player_index, items in pairs(mined) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if item_name == "wood" then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.lumberjacks)
end

function Statistics.calculate_mariobrothers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if Statistics.is_pipe(item_name) then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.mariobrothers)
end

function Statistics.calculate_oilmans()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if Statistics.is_oil_stuff(item_name) then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.oilmans)
end

function Statistics.calculate_roadworkers()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if Statistics.is_walkpath(item_name) then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.roadworkers)
end

function Statistics.calculate_electricians()
	local builded = Statistics.get_raw_data_type(Statistics.types.builded)
	local top = {}

	for player_index, items in pairs(builded) do
		local record = {player_index=player_index, count=0}

		for item_name, count in pairs(items) do
			if Statistics.is_electric_pole(item_name) then
				record.count = record.count + count
			end
		end

		table.insert(top, record)
	end

	Statistics.sort_and_set_top(top, Statistics.tops.electricians)
end

function Statistics.calculate_fishermans()
	local mined = Statistics.get_raw_data_type(Statistics.types.mined)
	local top = {}

	for player_index, items in pairs(mined) do
		if items["raw-fish"] then
			local record = {player_index=player_index, count=items["raw-fish"]}
			table.insert(top, record)
		end
	end

	Statistics.sort_and_set_top(top, Statistics.tops.fishermans)
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
	table.sort(top, function(first, second) return first.count > second.count end)
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
	for _, type_name in pairs(Statistics.type_names) do
		global.statistics.raw_data[type_name] = global.statistics.raw_data[type_name] or {}
	end

	global.statistics.tops = global.statistics.tops or {}
	for _, top_name in pairs(Statistics.top_names) do
		global.statistics.tops[top_name] = global.statistics.tops[top_name] or {}
	end

	global.statistics.gui = global.statistics.gui or {}
end

function Statistics.on_configuration_changed(data)
	Statistics.on_init()
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

	if event.cause then
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
	local builded = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.builded)
	builded[event.tile.name] = (builded[event.tile.name] or 0) + #event.tiles
end

function Statistics.on_player_repaired_entity(event)
	-- Counting not precisely, but tssss!

	local repaired = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.repaired)

	if event.entity.name == "stone-wall" then
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 4
	else
		repaired[event.entity.name] = (repaired[event.entity.name] or 0) + 2
	end
end

function Statistics.on_entity_died(event)
	if not event.cause or event.cause.name ~= "character" then
		return
	end

	if event.entity.name == "character" then
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
	local mined = Statistics.get_player_raw_data_type(event.player_index, Statistics.types.mined)
	mined[event.item_stack.name] = (mined[event.item_stack.name] or 0) + event.item_stack.count
end

function Statistics.on_player_crafted_item(event)
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

	if not event.parameter or event.parameter == "list" then
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

		if not top_id or top_id % 1 > 0 or top_id < 0 or top_id > #Statistics.top_names then
			self_player.print({"statistics.wrong-parameter"})
			return
		end

		local top_name = Statistics.top_names[top_id]

		-- Statistics["calculate_"..top_name]()

		local top = Statistics.get_top(top_name)

		if not top or not table_size(top) == 0 then
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
			self_player.print(index..". "..player.name.." - "..top[index].count)
		end
	end
end



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
events.on_nth_tick = {}
events.on_nth_tick[180] = Statistics.on_nth_tick
events.events = {
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


commands.add_command("top", "", Statistics.on_top)



--

return Statistics