-- utility sprites don't work right now so use hidden signals
data:extend({
  {
    type = "virtual-signal",
    name = "server_mod",
    icon = "__Fed1sServerMod__/graphics/icons/Fed1sServerMod.png",
    icon_size = 640,
    subgroup = "virtual-signal-utility",
    order = "i[server_mod]",
  },
  {
    type = "virtual-signal",
    name = "server_mod",
    icon = "__Fed1sServerMod__/graphics/icons/Fed1sServerMod.png",
    icon_size = 640,
    subgroup = "virtual-signal-utility",
    order = "i[server_mod]",
  },
  {
    type = "item-subgroup",
    name = "virtual-signal-utility",
    group = "signals",
    order = "u-a"
  },
})
