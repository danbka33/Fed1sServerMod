local recipe_radar_passive = util.table.deepcopy(data.raw.recipe["radar"])
recipe_radar_passive.name = "radar-passive"
recipe_radar_passive.enabled = true
recipe_radar_passive.result = "radar-passive"

data.raw.recipe["radar"].enabled = false

data:extend({
    recipe_radar_passive,
    {
        type = "recipe",
        name = "yellow-chest",
        enabled = true,
        energy_required = 1,
        ingredients = {
            { "wood", 1 },
        },
        result = "yellow-chest",
        requester_paste_multiplier = 1
    },
    --{
    --    type = "recipe",
    --    name = "blue-chest2",
    --    enabled = true,
    --    energy_required = 1,
    --    ingredients = {
    --        { "wood", 1 },
    --    },
    --    result = "blue-chest2",
    --    requester_paste_multiplier = 1
    --}
})


