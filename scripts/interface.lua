local Interface = {}

function Interface.server_mod_default_menu(player_index)
    return {}
end

---Creates the contents of ServerMod's own ServerMod pages.
---@param player_index uint Player index
---@param element LuaGuiElement Content scroll pane to place elements inside
---@param page_name string Page name
function Interface.server_mod_page_content(player_index, element, page_name)
    local current_player = game.get_player(player_index) --[[@as LuaPlayer]]
    local currentPlayerData = ServerMod.get_make_playerdata(current_player.index)

    -- Main page
    if page_name == "server_mod" then
        local admins = {}
        local managers = {}

        local warriorCount = 0
        local warriorCountOnline = 0
        local warriorManagers = {}

        local defenderCount = 0
        local defenderCountOnline = 0
        local defenderManagers = {}

        local builderCount = 0
        local builderCountOnline = 0
        local builderManagers = {}

        for _, player in pairs(game.players) do
            local playerData = ServerMod.get_make_playerdata(player.index)

            if player.admin then
                table.insert(admins, player.name)
            elseif playerData.manager then
                table.insert(managers, player.name)
            end

            if not playerData.applied then
                goto nextplayer
            end

            if playerData.role == ServerMod.roles.warrior then
                if playerData.manager then
                    if player.connected then
                        table.insert(warriorManagers, "[color=#00ff18]" .. player.name .. "[/color]")
                    else
                        table.insert(warriorManagers, "[color=#ffffff]" .. player.name .. "[/color]")
                    end
                end

                warriorCount = warriorCount + 1;

                if player.connected then
                    warriorCountOnline = warriorCountOnline + 1
                end
            elseif playerData.role == ServerMod.roles.defender then
                if playerData.manager then
                    if player.connected then
                        table.insert(defenderManagers, "[color=#00ff18]" .. player.name .. "[/color]")
                    else
                        table.insert(defenderManagers, "[color=#ffffff]" .. player.name .. "[/color]")
                    end
                end

                defenderCount = defenderCount + 1

                if player.connected then
                    defenderCountOnline = defenderCountOnline + 1
                end
            elseif playerData.role == ServerMod.roles.builder then
                if playerData.manager then
                    if player.connected then
                        table.insert(builderManagers, "[color=#00ff18]" .. player.name .. "[/color]")
                    else
                        table.insert(builderManagers, "[color=#ffffff]" .. player.name .. "[/color]")
                    end
                end

                builderCount = builderCount + 1

                if player.connected then
                    builderCountOnline = builderCountOnline + 1
                end
            end

            ::nextplayer::
        end

        -------------------------------------------------------------------------------------------------------------------
        -- local yt_addr = element.add{type="flow", direction="horizontal"}
        -- yt_addr.add{type="label", caption={"Fed1sServerMod.youtube_channel"}, style = "heading_1_label"}
        -- yt_addr.add{type="textfield", text="https://www.youtube.com/@fed1splay", read_only=true, style="stretchable_textfield"}

        -- local discord_addr = element.add{type="flow", direction="horizontal"}
        -- discord_addr.add{type="label", caption={"Fed1sServerMod.discord_server"}, style="heading_1_label"}
        -- discord_addr.add{type="textfield", text="https://discord.gg/RDpzDGY", read_only=true, style="stretchable_textfield"}

        -- local lang = element.add{type="flow", direction="horizontal"}
        -- lang.style.bottom_margin = 10

        -- lang.add{type="label", caption={"Fed1sServerMod.server_language_caption"}, style="heading_1_label"}

        -- local lang_label = lang.add{type="label", caption={"Fed1sServerMod.server_language"}}
        -- lang_label.style.top_margin = 5

        -- Оставил на всякий случай
        -- @АдЖ
        -------------------------------------------------------------------------------------------------------------------

        local info_table = element.add{type="table", column_count=2}
        info_table.style.bottom_margin = 10

        info_table.add{type="label", caption={"Fed1sServerMod.youtube_channel"}, style = "heading_1_label"}
        info_table.add{type="textfield", text="https://www.youtube.com/@fed1splay", read_only=true, style="stretchable_textfield"}

        info_table.add{type="label", caption={"Fed1sServerMod.discord_server"}, style="heading_1_label"}
        info_table.add{type="textfield", text="https://discord.gg/RDpzDGY", read_only=true, style="stretchable_textfield"}

        info_table.add{type="label", caption={"Fed1sServerMod.server_language_caption"}, style="heading_1_label"}
        info_table.add{type="label", caption={"Fed1sServerMod.server_language"}}

        do
            local line = element.add{type="line"}
            line.style.top_margin = 10
        end

        element.add{type="label", caption={"Fed1sServerMod.current_online", #game.connected_players}}

        do
            local line = element.add{type="line"}
            line.style.bottom_margin = 10
        end

        if not currentPlayerData.applied then
            local flow = element.add{type="flow", direction="horizontal"}
            flow.style.horizontally_stretchable = true
            flow.style.horizontal_align = "center"

            local label = flow.add{type="label", caption={"Fed1sServerMod.to_close_window"}, style="heading_1_label"}
            label.style.horizontal_align = "center"

            local line = element.add{type="line"}
            line.style.top_margin = 10
            line.style.bottom_margin = 10
        end

        element.add{type="label", caption={"Fed1sServerMod.fed1s_rule_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_rules"}}

        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.admin_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.admin_desc"}}



        element.add{type="label", caption={"Fed1sServerMod.admins", table.concat(admins, ", ")}}

        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.manager_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.manager_desc"}}

        element.add{type="label", caption={"Fed1sServerMod.managers", table.concat(managers, ", ")}}


        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_pick_role_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_pick_role"}}

        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_warrior_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_warrior_text"}}

        element.add{type="label", caption={"Fed1sServerMod.count", warriorCount, warriorCountOnline}}

        element.add{type="label", caption={"Fed1sServerMod.role_managers", table.concat(warriorManagers, ", ")}}

        element.add{
            type = "button",
            caption = {"Fed1sServerMod.fed1s_warrior_button"},
            name = "fed1s_warrior",
            style = "server_mod_menu_button_primary"
        }

        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_defender_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_defender_text"}}

        element.add{type="label", caption={"Fed1sServerMod.count", defenderCount, defenderCountOnline}}

        element.add{type="label", caption={"Fed1sServerMod.role_managers", table.concat(defenderManagers, ", ")}}

        element.add{
            type = "button",
            caption = {"Fed1sServerMod.fed1s_defender_button"},
            name = "fed1s_defender",
            style = "server_mod_menu_button_primary"
        }

        element.add{type="line"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_builder_header"}, style = "heading_1_label"}

        element.add{type="label", caption={"Fed1sServerMod.fed1s_builder_text"}}

        element.add{type="label", caption={"Fed1sServerMod.count", builderCount, builderCountOnline}}

        element.add{type="label", caption={"Fed1sServerMod.role_managers", table.concat(builderManagers, ", ")}}

        element.add{
            type = "button",
            caption = {"Fed1sServerMod.fed1s_builder_button"},
            name = "fed1s_builder",
            style = "server_mod_menu_button_primary"
        }

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
