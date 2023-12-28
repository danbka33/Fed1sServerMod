--[[ Copyright (c) 2022 danbka33
 * Part of Fed1sCityblockNames
 *
 * See LICENSE.md in the project directory for license information.
--]]
data:extend{
    {
        type = "int-setting",
        name = "passive-radar-range",
        setting_type = "startup",
        default_value = 5,
        minimum_value = 1,
        maximum_value = 1000,
        order = "1",
    },
    {
        type = "bool-setting",
        name = "server_mod-show-overhead-button",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "1"
    },
    {
        type = "bool-setting",
        name = "server_mod_admin_message_on_center",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "2"
    },
    {
        type = "bool-setting",
        name = "server_mod_show_stats",
        setting_type = "runtime-per-user",
        default_value = true,
        order = "3"
    }
}
