-- utility sprites don't work right now so use hidden signals
data:extend({
  {
    type = "virtual-signal",
    name = "serverMod",
    icon = "__Fed1sServerMod__/graphics/icons/Fed1sServerMod.png",
    icon_size = 640,
    subgroup = "virtual-signal-utility",
    order = "i[serverMod]",
  },
  {
    type = "virtual-signal",
    name = "serverMod",
    icon = "__Fed1sServerMod__/graphics/icons/Fed1sServerMod.png",
    icon_size = 640,
    subgroup = "virtual-signal-utility",
    order = "i[serverMod]",
  },
  {
    type = "item-subgroup",
    name = "virtual-signal-utility",
    group = "signals",
    order = "u-a"
  },
})
