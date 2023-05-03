local it_radar_passive = util.table.deepcopy(data.raw.item["radar"])
it_radar_passive.name = "radar-passive"
it_radar_passive.place_result = "radar-passive"
it_radar_passive.order = "d[radar]-b[radar-passive]"

data:extend({
    it_radar_passive,
    {
        type = "item",
        name = "necromancy-chest",
        icon = "__Fed1sServerMod__/graphics/icons/yellow-chest/yellow-chest.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "storage",
        place_result = "necromancy-chest",
        order = "a[items]-e[necromancy-chest]",
        stack_size = 1
    },
    {
        type = "item",
        name = "yellow-chest",
        icon = "__Fed1sServerMod__/graphics/icons/yellow-chest/yellow-chest.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "storage",
        place_result = "yellow-chest",
        order = "a[items]-e[yellow-chest]",
        stack_size = 1
    },
    {
        type = "item",
        name = "blue-chest2",
        icon = "__Fed1sServerMod__/graphics/icons/yellow-chest/blue-chest.png",
        icon_size = 64, icon_mipmaps = 4,
        subgroup = "storage",
        place_result = "blue-chest2",
        order = "a[items]-e[blue-chest]",
        stack_size = 50
    }
})