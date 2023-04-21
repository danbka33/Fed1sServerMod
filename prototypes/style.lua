---@diagnostic disable-next-line
serverMod_menu_width = 250
---@diagnostic disable-next-line
serverMod_content_width = 940 -- inner width is serverMod_content_width - 40 - 12

-- Used by fCPU, and possibly others
---@diagnostic disable-next-line
function serverMod_make_image(unique_name, filename, width, height)
  data.raw["gui-style"]["default"][unique_name] = {
    type = "button_style",
    width = width,
    height = height,
    clicked_graphical_set = { filename = filename, scale = 1, width = width, height = height},
    default_graphical_set = { filename = filename, scale = 1, width = width, height = height},
    disabled_graphical_set = { filename = filename, scale = 1, width = width, height = height},
    hovered_graphical_set = { filename = filename, scale = 1, width = width, height = height},
  }
end

-- Used by Equipment Gantry
data.raw["gui-style"]["default"]["serverMod_image_container"] = {
  type = "frame_style",
  padding = 4,
  width = serverMod_content_width - 40 - 12,
  graphical_set = {
    base = {
      corner_size = 8,
      opacity = 0.9,
      position = { 403, 0 }
    },
    shadow = nil
  },
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 2
  },
  top_margin = 15,
  bottom_margin = 15,
  horizontal_align = "center",
}

-- Used by SE
data.raw["gui-style"]["default"]["serverMod_close_button"] = {
  parent = "frame_button",
  size = 20,
  type = "button_style",
  top_padding = -2,
  top_margin = -4,
  default_font_color = { 1,1,1 },
}

-- Used by SE
data.raw["gui-style"]["default"]["serverMod_inside_deep_frame"] = {
  type = "frame_style",
  graphical_set = {
    base = {
      center = {
        position = { 42, 8 },
        size = { 1,1 }
      },
      corner_size = 8,
      draw_type = "outer",
      position = {17,0}
    },
    shadow = nil
  },
  padding = 0,
  parent = "frame",
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
  vertically_stretchable = "on",
}

----------------------------------------------------------------------------

local style = data.raw["gui-style"]["default"]

style.serverMod_root_frame = {
  type = "frame_style",
  height = 800
}

style.serverMod_titlebar_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 8
}

style.serverMod_titlebar_icon = {
  type = "image_style",
  size = 20,
  stretch_image_to_widget_size = true
}

style.serverMod_drag_handle = {
  type = "empty_widget_style",
  parent = "draggable_space",
  horizontally_stretchable = "on",
  height = 24,
  left_margin = 4,
  right_margin = 4
}

style.serverMod_time_label = {
  type = "label_style",
  font = "default-small-semibold"
}

style.serverMod_main_flow = {
  type = "horizontal_flow_style",
  horizontal_spacing = 8
}

style.serverMod_menu_frame = {
  type = "frame_style",
  parent = "inside_deep_frame",
  width = serverMod_menu_width,
  vertically_stretchable = "stretch_and_expand"
}

style.serverMod_menu_scroll_pane = {
  type = "scroll_pane_style",
  parent = "list_box_scroll_pane",
  horizontally_stretchable = "stretch_and_expand",
  vertically_stretchable = "stretch_and_expand",
  dont_force_clipping_rect_for_contents = true,
  padding = 0,
  vertical_flow_style = {
    type = "vertical_flow_style",
    vertical_spacing = 4,
  },
}

style.serverMod_menu_button = {
  type = "button_style",
  font = "default-listbox",
  horizontal_align = "left",
  horizontally_stretchable = "on",
  horizontally_squashable = "on",
  bottom_margin = -3,
  default_font_color = {227, 227, 227},
  hovered_font_color = {0, 0, 0},
  selected_clicked_font_color = {0.97, 0.54, 0.15},
  selected_font_color = {0.97, 0.54, 0.15 },
  selected_hovered_font_color = {0.97, 0.54, 0.15},
  default_graphical_set = {
    corner_size = 8,
    position = {208, 17}
  },
  clicked_graphical_set = {
    corner_size = 8,
    position = {352, 17}
  },
  hovered_graphical_set = {
    base = {
      corner_size = 8,
      position = {34, 17}
    }
  },
  disabled_graphical_set = {
    corner_size = 8,
    position = {17, 17}
  }
}

style.serverMod_menu_button_primary = {
  type = "button_style",
  parent = "serverMod_menu_button",
  font = "default-bold",
  default_font_color = {255, 230,192},
}

style.serverMod_menu_button_selected = {
  type = "button_style",
  parent = "serverMod_menu_button",
  default_font_color = {0, 0, 0},
  hovered_font_color = {0, 0, 0},
  selected_clicked_font_color = {0, 0, 0},
  selected_font_color = {0, 0, 0},
  selected_hovered_font_color = {0, 0, 0},
  default_graphical_set = {
    corner_size = 8,
    position = { 54, 17 }
  },
  hovered_graphical_set = {
    corner_size = 8,
    position = { 54, 17 }
  }
}

style.serverMod_menu_button_primary_selected = {
  type = "button_style",
  parent = "serverMod_menu_button_selected",
  font = "default-bold",
}

style.serverMod_content_frame = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  width = serverMod_content_width,
  horizontally_stretchable = "on",
  vertically_stretchable = "on"
}

style.serverMod_content_subheader_frame = {
  type = "frame_style",
  parent = "subheader_frame",
  height = 56,
  horizontally_stretchable = "stretch_and_expand",
  vertical_flow_style = {
    left_padding = 20,
    right_padding = 20,
    top_padding = 5,
    type = "vertical_flow_style",
    vertical_align = "center"
  }
}

style.serverMod_content_title = {
  type = "label_style",
  parent = "frame_title",
  font = "heading-2"
}

style.serverMod_content_scroll_pane = {
  type = "scroll_pane_style",
  parent = "naked_scroll_pane",
  width = serverMod_content_width,
  padding = 20,
  extra_padding_when_activated = 0,
  vertically_stretchable = "on"
}
