require("util")
local sounds = require("__base__.prototypes.entity.sounds")
local hit_effects = require("__base__.prototypes.entity.hit-effects")

data:extend({

    {
        type = "logistic-container",
        name = "yellow-chest",
        icon = "__Fed1sServerMod__/graphics/icons/yellow-chest/yellow-chest.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = { "placeable-neutral", "player-creation" },
        minable = { mining_time = 0.2, result = "yellow-chest" },
        max_health = 350,
        corpse = "steel-chest-remnants",
        dying_explosion = "steel-chest-explosion",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        resistances = {
            {
                type = "fire",
                percent = 90
            },
            {
                type = "impact",
                percent = 60
            }
        },
        collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        damaged_trigger_effect = hit_effects.entity(),
        fast_replaceable_group = "container",
        inventory_size = 48,
        logistic_mode = "buffer",
        logistic_slots_count = 48,
        vehicle_impact_sound = sounds.generic_impact,
        render_not_in_network_icon = false,
        picture = {
            layers = {
                {
                    filename = "__Fed1sServerMod__/graphics/entity/yellow-chest/yellow-chest.png",
                    priority = "extra-high",
                    width = 64,
                    height = 80,
                    shift = util.by_pixel(-0.25, -0.5),
                    scale = 0.5
                },
                {
                    filename = "__base__/graphics/entity/steel-chest/hr-steel-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 46,
                    shift = util.by_pixel(12.25, 8),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
    {
        type = "logistic-container",
        name = "blue-chest2",
        icon = "__Fed1sServerMod__/graphics/icons/yellow-chest/blue-chest.png",
        icon_size = 64, icon_mipmaps = 4,
        flags = { "placeable-neutral", "player-creation" },
        minable = { mining_time = 0.2, result = "blue-chest2" },
        max_health = 350,
        corpse = "steel-chest-remnants",
        dying_explosion = "steel-chest-explosion",
        open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume = 0.43 },
        close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
        resistances = {
            {
                type = "fire",
                percent = 90
            },
            {
                type = "impact",
                percent = 60
            }
        },
        collision_box = { { -0.35, -0.35 }, { 0.35, 0.35 } },
        selection_box = { { -0.5, -0.5 }, { 0.5, 0.5 } },
        damaged_trigger_effect = hit_effects.entity(),
        fast_replaceable_group = "container",
        inventory_size = 48,
        logistic_mode = "buffer",
        logistic_slots_count = 48,
        vehicle_impact_sound = sounds.generic_impact,
        render_not_in_network_icon = false,
        picture = {
            layers = {
                {
                    filename = "__Fed1sServerMod__/graphics/entity/yellow-chest/blue-chest.png",
                    priority = "extra-high",
                    width = 64,
                    height = 80,
                    shift = util.by_pixel(-0.25, -0.5),
                    scale = 0.5
                },
                {
                    filename = "__base__/graphics/entity/steel-chest/hr-steel-chest-shadow.png",
                    priority = "extra-high",
                    width = 110,
                    height = 46,
                    shift = util.by_pixel(12.25, 8),
                    draw_as_shadow = true,
                    scale = 0.5
                }
            }
        },
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points,
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = default_circuit_wire_max_distance
    },
})