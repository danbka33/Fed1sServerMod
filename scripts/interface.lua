local Interface = {}

function Interface.server_mod_default_menu(player_index)
  return {
  }
end

---Creates the contents of ServerMod's own ServerMod pages.
---@param player_index uint Player index
---@param element LuaGuiElement Content scroll pane to place elements inside
---@param page_name string Page name
function Interface.server_mod_page_content(player_index, element, page_name)
  local player = game.get_player(player_index) --[[@as LuaPlayer]]
  local currentPlayerData = ServerMod.get_make_playerdata(player.index)

  -- Main page
  if page_name == "server_mod" then

    local warriorCount = 0
    local warriorCountOnline = 0
    local warriorManager = ""

    local defenderManager = ""
    local defenderCount = 0
    local defenderCountOnline = 0

    local builderManager = ""
    local builderCount = 0
    local builderCountOnline = 0

    local currentOnline = 0

    local admins = ""
    local managers = ""
    for _, player in pairs(game.players) do
      local playerData = ServerMod.get_make_playerdata(player.index)
      if player.connected then
        currentOnline = currentOnline + 1
      end

      if player.permission_group.name == "Admin" then
        admins = admins .. player.name .. "   "
      end
      if player.permission_group.name == "Manager" then
        managers = managers .. player.name .. "   "
      end

      if playerData.role == "warrior"  then
        if player.permission_group.name == "Manager" then
          local addedName = "[color=#ffffff]" .. player.name .. "[/color]"

          if player.connected then
            addedName = "[color=#00ff18]" .. player.name .. "[/color]"
          end

          warriorManager = warriorManager .. addedName .. "   "
        end
        warriorCount = warriorCount + 1;

        if player.connected then
          warriorCountOnline = warriorCountOnline + 1
        end
      end

      if playerData.role == "defender"  then
        if player.permission_group.name == "Manager" then
          local addedName = "[color=#ffffff]" .. player.name .. "[/color]"

          if player.connected then
            addedName = "[color=#00ff18]" .. player.name .. "[/color]"
          end

          defenderManager = defenderManager .. addedName .. "   "

        end

        defenderCount = defenderCount + 1

        if player.connected then
          defenderCountOnline = defenderCountOnline + 1
        end
      end

      if playerData.role == "builder"  then
        if player.permission_group.name == "Manager" then
          local addedName = "[color=#ffffff]" .. player.name .. "[/color]"

          if player.connected then
            addedName = "[color=#00ff18]" .. player.name .. "[/color]"
          end

          builderManager = builderManager .. addedName .. "   "
        end
        builderCount = builderCount + 1
        if player.connected then
          builderCountOnline = builderCountOnline + 1
        end
      end

    end

    element.add{type="label", caption={"Fed1sServerMod.streamer"}, style = "heading_1_label"}

    table.add{type="textfield", text="https://www.youtube.com/@fed1splay", read_only=true,style="stretchable_textfield"}
    table.add{type="label", caption="Discord:", style = "heading_1_label"}
    table.add{type="textfield", text="https://discord.gg/RDpzDGY", read_only=true,style="stretchable_textfield"}
    table.add{type="label", caption="Язык сервера:", style = "heading_1_label"}
    table.add{type="textfield", text="русский.", read_only=true,style="stretchable_textfield"}

    if not currentPlayerData.applied then
      element.add{type="label", caption={"Fed1sServerMod.to_close_window"}}
    end

    element.add{type="label", caption={"Fed1sServerMod.current_online", currentOnline}}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_rule_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_rules"}}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.admin_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.admin_desc"}}



    element.add{type="label", caption={"Fed1sServerMod.admins", admins}}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.manager_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.manager_desc"}}

    element.add{type="label", caption={"Fed1sServerMod.managers", managers}}


    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_pick_role_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_pick_role"}}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_warrior_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_warrior_text"}}

    element.add{type="label", caption={"Fed1sServerMod.count", warriorCount, warriorCountOnline}}

    element.add{type="label", caption={"Fed1sServerMod.role_managers", warriorManager}}

    element.add{
      type = "button",
      caption = {"Fed1sServerMod.fed1s_warrior_button"},
      name = "fed1s_warrior",
      style = "server_mod_menu_button_primary"}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_defender_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_defender_text"}}

    element.add{type="label", caption={"Fed1sServerMod.count", defenderCount, defenderCountOnline}}

    element.add{type="label", caption={"Fed1sServerMod.role_managers", defenderManager}}

    element.add{
      type = "button",
      caption = {"Fed1sServerMod.fed1s_defender_button"},
      name = "fed1s_defender",
      style = "server_mod_menu_button_primary"}

    element.add{type="line"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_builder_header"}, style = "heading_1_label"}

    element.add{type="label", caption={"Fed1sServerMod.fed1s_builder_text"}}

    element.add{type="label", caption={"Fed1sServerMod.count", builderCount, builderCountOnline}}

    element.add{type="label", caption={"Fed1sServerMod.role_managers", builderManager}}

    element.add{
      type = "button",
      caption = {"Fed1sServerMod.fed1s_builder_button"},
      name = "fed1s_builder",
      style = "server_mod_menu_button_primary"}

    --element.add{type="line"}
    --
    --element.add{type="label", caption={"Fed1sServerMod.fed1s_service_header"}, style = "heading_1_label"}
    --
    --local serviceManager = ""
    --for _, player in pairs(game.players) do
    --  local playerData = ServerMod.get_make_playerdata(player.index)
    --  if playerData.role == "service" and player.permission_group.name == "Manager" then
    --    serviceManager = serviceManager .. player.name .. "   "
    --  end
    --end
    --
    --element.add{type="label", caption={"Fed1sServerMod.role_managers", serviceManager}}
    --
    --
    --element.add{type="label", caption={"Fed1sServerMod.fed1s_service_text"}}
    --
    --element.add{
    --  type = "button",
    --  caption = {"Fed1sServerMod.fed1s_service_button"},
    --  name = "fed1s_service",
    --  style = "server_mod_menu_button_primary"}


  end
end

-- Remote interface. Other mods can add menus the same way.
remote.add_interface("server_mod", {

  server_mod_menu = function(data) -- populates the menu
    return Interface.server_mod_default_menu(data.player_index)
  end,

  server_mod_page_content = function(data) -- provides cntent to a page
    return Interface.server_mod_page_content(data.player_index, data.element, data.page_name)
  end,

  --Called once per second, only use if you have timers on the page, avoid rebuilding the whole page
  --server_mod_page_content_update = function(data)
  --  return Interface.server_mod_page_content_update(
  --    data.page_name, data.player_index, data.element)
  --end,

  server_mod_open_to_page = function(data) -- causes ServerMod to open to a specific page
    if data.player_index and data.interface and data.page_name then
      local player = game.get_player(data.player_index)
      if player then
        ServerMod.open(player, {interface=data.interface, page_name=data.page_name})
      end
    end
  end
})

return Interface
