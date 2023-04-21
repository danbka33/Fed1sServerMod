--[[ Copyright (c) 2022 danbka33
 * Part of Fed1sCityblockNames
 *
 * See LICENSE.md in the project directory for license information.
--]]

Stats = require('scripts/stats')
Informatron = require('scripts/informatron')
Interface = require('scripts/interface')

script.on_init(function()
    Informatron.on_init()

    game.permissions.create_group("Admin")

    game.permissions.create_group("PickRole")
    game.permissions.create_group("Banned")

    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.activate_cut, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.activate_paste, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.add_permission_group, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.add_train_station, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.admin_action, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.alt_reverse_select_area, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.alt_select_area, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.alt_select_blueprint_entities, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.alternative_copy, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.begin_mining, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.begin_mining_terrain, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.build, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.build_rail, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.build_terrain, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cancel_craft, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cancel_deconstruct, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cancel_new_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cancel_research, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cancel_upgrade, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_active_character_tab, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_active_item_group_for_crafting, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_active_item_group_for_filters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_active_quick_bar, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_arithmetic_combinator_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_decider_combinator_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_entity_label, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_item_description, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_item_label, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_multiplayer_config, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_picking_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_riding_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_shooting_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_train_stop_station, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_train_wait_condition, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.change_train_wait_condition_data, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.clear_cursor, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.connect_rolling_stock, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.copy, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.copy_entity_settings, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.copy_opened_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.copy_opened_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.craft, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cursor_split, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cursor_transfer, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.custom_input, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cycle_blueprint_book_backwards, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.cycle_blueprint_book_forwards, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.deconstruct, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.delete_blueprint_library, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.delete_blueprint_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.delete_custom_tag, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.delete_permission_group, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.destroy_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.destroy_opened_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.disconnect_rolling_stock, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.drag_train_schedule, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.drag_train_wait_condition, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.drop_blueprint_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.drop_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.edit_blueprint_tool_preview, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.edit_custom_tag, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.edit_permission_group, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.export_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.fast_entity_split, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.fast_entity_transfer, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.flush_opened_entity_fluid, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.flush_opened_entity_specific_fluid, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.go_to_train_station, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.grab_blueprint_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_checked_state_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_elem_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_location_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_selected_tab_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_selection_state_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_switch_state_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_text_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.gui_value_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.import_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.import_blueprint_string, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.import_blueprints_filtered, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.import_permissions_string, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.inventory_split, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.inventory_transfer, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.launch_rocket, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.lua_shortcut, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.map_editor_action, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.market_offer, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.mod_settings_changed, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_achievements_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_blueprint_library_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_blueprint_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_bonus_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_character_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_current_vehicle_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_equipment, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_logistic_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_mod_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_parent_of_opened_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_production_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_technology_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_tips_and_tricks_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_train_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_train_station_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.open_trains_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.paste_entity_settings, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.place_equipment, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.quick_bar_pick_slot, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.quick_bar_set_selected_page, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.quick_bar_set_slot, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.reassign_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.remove_cables, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.remove_train_station, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.reset_assembling_machine, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.reset_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.reverse_select_area, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.rotate_entity, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_area, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_blueprint_entities, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_entity_slot, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_mapper_slot, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_next_valid_gun, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.select_tile_slot, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.send_spidertron, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_auto_launch_rocket, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_autosort_inventory, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_behavior_mode, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_car_weapons_control, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_circuit_condition, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_circuit_mode_of_operation, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_controller_logistic_trash_filter_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_deconstruction_item_tile_selection_mode, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_deconstruction_item_trees_and_rocks_only, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_entity_color, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_entity_energy_property, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_entity_logistic_trash_filter_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_filter, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_flat_controller_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_heat_interface_mode, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_heat_interface_temperature, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_infinity_container_filter_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_infinity_container_remove_unfiltered_items, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_infinity_pipe_filter, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_inserter_max_stack_size, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_inventory_bar, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_linked_container_link_i_d, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_logistic_filter_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_logistic_filter_signal, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_player_color, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_recipe_notifications, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_request_from_buffers, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_research_finished_stops_game, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_signal, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_splitter_priority, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_train_stopped, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_trains_limit, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.set_vehicle_automatic_targeting_parameters, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.setup_assembling_machine, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.setup_blueprint, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.setup_single_blueprint_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.smart_pipette, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.spawn_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.stack_split, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.stack_transfer, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.start_repair, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.start_research, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.start_walking, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.stop_building_by_moving, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.switch_connect_to_logistic_network, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.switch_constant_combinator_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.switch_inserter_filter_mode_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.switch_power_switch_state, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.switch_to_rename_stop_gui, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.take_equipment, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_deconstruction_item_entity_filter_mode, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_deconstruction_item_tile_filter_mode, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_driving, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_enable_vehicle_logistics_while_moving, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_entity_logistic_requests, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_equipment_movement_bonus, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_map_editor, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_personal_logistic_requests, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_personal_roboport, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.toggle_show_entity_info, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.translate_string, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.undo, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.upgrade, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.upgrade_opened_blueprint_by_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.upgrade_opened_blueprint_by_record, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.use_artillery_remote, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.use_item, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.wire_dragging, false)
    game.permissions.get_group("PickRole").set_allows_action(defines.input_action.write_to_console, false)

    game.permissions.get_group("Banned").set_allows_action(defines.input_action.activate_cut, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.activate_paste, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.add_permission_group, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.add_train_station, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.admin_action, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.alt_reverse_select_area, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.alt_select_area, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.alt_select_blueprint_entities, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.alternative_copy, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.begin_mining, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.begin_mining_terrain, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.build, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.build_rail, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.build_terrain, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cancel_craft, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cancel_deconstruct, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cancel_new_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cancel_research, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cancel_upgrade, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_active_character_tab, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_active_item_group_for_crafting, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_active_item_group_for_filters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_active_quick_bar, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_arithmetic_combinator_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_decider_combinator_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_entity_label, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_item_description, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_item_label, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_multiplayer_config, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_picking_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_programmable_speaker_alert_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_programmable_speaker_circuit_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_riding_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_shooting_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_train_stop_station, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_train_wait_condition, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.change_train_wait_condition_data, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.clear_cursor, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.connect_rolling_stock, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.copy, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.copy_entity_settings, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.copy_opened_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.copy_opened_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.craft, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cursor_split, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cursor_transfer, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.custom_input, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cycle_blueprint_book_backwards, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.cycle_blueprint_book_forwards, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.deconstruct, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.delete_blueprint_library, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.delete_blueprint_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.delete_custom_tag, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.delete_permission_group, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.destroy_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.destroy_opened_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.disconnect_rolling_stock, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.drag_train_schedule, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.drag_train_wait_condition, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.drop_blueprint_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.drop_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.edit_blueprint_tool_preview, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.edit_custom_tag, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.edit_permission_group, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.export_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.fast_entity_split, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.fast_entity_transfer, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.flush_opened_entity_fluid, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.flush_opened_entity_specific_fluid, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.go_to_train_station, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.grab_blueprint_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_checked_state_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_elem_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_location_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_selected_tab_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_selection_state_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_switch_state_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_text_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.gui_value_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.import_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.import_blueprint_string, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.import_blueprints_filtered, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.import_permissions_string, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.inventory_split, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.inventory_transfer, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.launch_rocket, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.lua_shortcut, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.map_editor_action, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.market_offer, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.mod_settings_changed, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_achievements_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_blueprint_library_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_blueprint_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_bonus_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_character_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_current_vehicle_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_equipment, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_logistic_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_mod_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_parent_of_opened_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_production_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_technology_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_tips_and_tricks_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_train_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_train_station_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.open_trains_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.paste_entity_settings, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.place_equipment, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.quick_bar_pick_slot, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.quick_bar_set_selected_page, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.quick_bar_set_slot, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.reassign_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.remove_cables, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.remove_train_station, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.reset_assembling_machine, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.reset_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.reverse_select_area, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.rotate_entity, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_area, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_blueprint_entities, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_entity_slot, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_mapper_slot, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_next_valid_gun, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.select_tile_slot, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.send_spidertron, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_auto_launch_rocket, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_autosort_inventory, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_behavior_mode, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_car_weapons_control, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_circuit_condition, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_circuit_mode_of_operation, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_controller_logistic_trash_filter_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_deconstruction_item_tile_selection_mode, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_deconstruction_item_trees_and_rocks_only, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_entity_color, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_entity_energy_property, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_entity_logistic_trash_filter_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_filter, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_flat_controller_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_heat_interface_mode, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_heat_interface_temperature, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_infinity_container_filter_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_infinity_container_remove_unfiltered_items, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_infinity_pipe_filter, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_inserter_max_stack_size, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_inventory_bar, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_linked_container_link_i_d, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_logistic_filter_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_logistic_filter_signal, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_player_color, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_recipe_notifications, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_request_from_buffers, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_research_finished_stops_game, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_signal, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_splitter_priority, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_train_stopped, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_trains_limit, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.set_vehicle_automatic_targeting_parameters, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.setup_assembling_machine, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.setup_blueprint, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.setup_single_blueprint_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.smart_pipette, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.spawn_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.stack_split, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.stack_transfer, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.start_repair, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.start_research, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.start_walking, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.stop_building_by_moving, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.switch_connect_to_logistic_network, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.switch_constant_combinator_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.switch_inserter_filter_mode_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.switch_power_switch_state, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.switch_to_rename_stop_gui, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.take_equipment, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_deconstruction_item_entity_filter_mode, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_deconstruction_item_tile_filter_mode, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_driving, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_enable_vehicle_logistics_while_moving, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_entity_logistic_requests, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_equipment_movement_bonus, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_map_editor, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_personal_logistic_requests, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_personal_roboport, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.toggle_show_entity_info, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.translate_string, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.undo, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.upgrade, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.upgrade_opened_blueprint_by_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.upgrade_opened_blueprint_by_record, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.use_artillery_remote, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.use_item, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.wire_dragging, false)
    game.permissions.get_group("Banned").set_allows_action(defines.input_action.write_to_console, false)

    game.permissions.create_group("Manager")
    --game.permissions.get_group("Admin").add_player("fed1s")
    --game.permissions.get_group("Admin").add_player("danbka33")

    --game.permissions.get_group("Default").set_allows_action(defines.input_action.cancel_research, false)
    --game.permissions.get_group("Default").set_allows_action(defines.input_action.toggle_map_editor, false)
    --game.permissions.get_group("Default").set_allows_action(defines.input_action.set_player_color, false)
    --game.permissions.get_group("Default").set_allows_action(defines.input_action.open_technology_gui, false)
    --game.permissions.get_group("Default").set_allows_action(defines.input_action.edit_permission_group, false)
    --game.permissions.get_group("Default").set_allows_action(defines.input_action.admin_action, false)
    --
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.cancel_research, false)
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.toggle_map_editor, false)
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.set_player_color, false)
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.open_technology_gui, false)
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.edit_permission_group, false)
    --game.permissions.get_group("Manager").set_allows_action(defines.input_action.admin_action, false)

end)

--

function apply_player_color(player_index)
    local player = game.get_player(player_index)
    local playerData = Informatron.get_make_playerdata(player_index)

    if playerData then
        if playerData.role then
            local color = { 1, 1, 1, 1 }
            local chatColor = { 1, 1, 1, 1 }

            if playerData.role == "warrior" then
                color = { 1, 0.5, 0, 1 }
            elseif playerData.role == "builder" then
                color = { 0, 0.5, 0.5, 1 }
            elseif playerData.role == "defender" then
                color = { 0, 0.5, 1, 1 }
            elseif playerData.role == "service" then
                color = { 0, 0.5, 0.5, 1 }
            end

            if player.permission_group.name == "Admin" then
                color = { 1, 1, 0, 1 }
                chatColor = { 1, 1, 0, 1 }
            elseif player.permission_group.name == "Manager" then
                color = { 0, 1, 0, 1 }
                chatColor = { 0, 1, 0, 1 }
            end

            player.chat_color = chatColor
            player.color = color
        end
    else
        player.chat_color = { 1, 1, 1, 1 }
        player.color = { 1, 1, 1, 1 }
    end


end

local function on_player_create(event)
    Informatron.on_player_created(event)

    apply_player_color(event.player_index)
    --game.players[event.player_index].chat_color = default_color
    --game.players[event.player_index].color = default_color
end

local function change_color(event)
    if event.name == defines.events.on_console_command and event.command == "color" then
        local player = game.players[event.player_index]
        apply_player_color(event.player_index)
        game.print("Осуждаем игрока " .. player.name, { 1, 1, 0, 1 })
    end
end

local function on_player_joined_game(event)
    apply_player_color(event.player_index)
end

local function on_console_chat(event)
    apply_player_color(event.player_index)

    local player = game.players[event.player_index]
    local playerData = Informatron.get_make_playerdata(event.player_index)

    if player and playerData and playerData.role then

        local sendAdmin = player.permission_group.name == "Admin";
        local sendManager = player.permission_group.name == "Manager";
        local sendPlayerName = player.name;
        local sendRole = playerData.role;

        if ((sendAdmin or sendManager) and string.find(event.message, "!") or player.name == "fed1s") then
            table.insert(Informatron.get_make_admin_texts(), {
                message = player.name .. ": " .. event.message,
                tick = event.tick,
                role = sendRole,
                manager = sendManager,
                admin = sendAdmin,
                playerName = player.name
            })

            for _, player in pairs(game.players) do
                local isAdmin = player.permission_group.name == "Admin"
                local isManager = player.permission_group.name == "Manager"
                local currentPlayerData = Informatron.get_make_playerdata(player.index)
                local playerRole = currentPlayerData.role

                if not (sendPlayerName == player.name) and (isAdmin) and ((sendAdmin) or (sendManager and isManager) or (sendManager and sendRole == playerRole)) then
                    player.play_sound({ path = "admin_notify" })
                end

                Informatron.update_overhead_texts(player)
            end

        end
    end


end

script.on_event(defines.events.on_player_created, on_player_create)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)
script.on_event(defines.events.on_console_command, change_color)
script.on_event(defines.events.on_console_chat, on_console_chat)

local function get_make_blue_chest(blue_chest_index)
    global.blueChest = global.blueChest or {}
    global.blueChest[blue_chest_index] = global.blueChest[blue_chest_index] or {}
    return global.blueChest[blue_chest_index]
end

local function get_make_yellow_chest(yellow_chest_index)
    global.yellowChest = global.yellowChest or {}
    global.yellowChest[yellow_chest_index] = global.yellowChest[yellow_chest_index] or {}
    return global.yellowChest[yellow_chest_index]
end

local function OnYellowChestCreated(entity, player)
    local yellowChestData = get_make_yellow_chest(entity.unit_number)

    if yellowChestData and yellowChestData.entity and yellowChestData.entity.valid then
        return
    end

    global.yellowChest[entity.unit_number] = {
        entity = entity,
        started = false,
        valid = true,
        startPlayer = player
    };
end

local function OnBlueChestCreated(entity, player)
    local blueChestData = get_make_blue_chest(entity.unit_number)

    if blueChestData and blueChestData.entity and blueChestData.entity.valid then
        return
    end

    global.blueChest[entity.unit_number] = {
        entity = entity,
        valid = true,
        startPlayer = player
    };
end

local function OnEntityCreated(event)
    local entity = event.created_entity or event.entity
    if not entity or not entity.valid then
        return
    end

    local playerIndex = event.player_index

    if entity.name == "yellow-chest" then
        if not playerIndex then
            entity.destroy()
            return
        end
        local player = game.players[playerIndex]

        if player then
            entity.destructible = false

            OnYellowChestCreated(entity, player)
        else
            entity.destroy();
        end
    elseif entity.name == "blue-chest" then
        if not playerIndex then
            entity.destroy()
            return
        end

        local player = game.players[playerIndex]

        if player then
            entity.destructible = false

            OnBlueChestCreated(entity, player)
        else
            entity.destroy();
        end
    end

end

local function OnEntityRemoved(event)
    local entity = event.entity
    if not entity or not entity.valid then
        return
    end

    if entity.name == "yellow-chest" then
        global.yellowChest[entity.unit_number] = nil
    elseif entity.name == "blue-chest" then
        global.blueChest[entity.unit_number] = nil
    end
end

script.on_event(defines.events.on_built_entity, OnEntityCreated, filters_on_built)
script.on_event(defines.events.on_robot_built_entity, OnEntityCreated, filters_on_built)
script.on_event({ defines.events.script_raised_built, defines.events.script_raised_revive }, OnEntityCreated)

script.on_event(defines.events.on_pre_player_mined_item, OnEntityRemoved, filters_on_mined)
script.on_event(defines.events.on_robot_pre_mined, OnEntityRemoved, filters_on_mined)
script.on_event(defines.events.on_entity_died, OnEntityRemoved, filters_on_mined)
script.on_event(defines.events.script_raised_destroy, OnEntityRemoved)

local function checkPlayerInventoryForRequest(player, requested, chestInventory)

    local playerInventory = player.get_inventory(defines.inventory.character_main);

    if playerInventory then

        for itemName, count in pairs(playerInventory.get_contents()) do
            if itemName and count then
                if requested[itemName] and requested[itemName] > 0 then
                    game.print("Found " .. itemName .. " in amount " .. count .. " in player" .. player.name)
                    if count >= requested[itemName] then
                        game.print("Remove " .. itemName .. " in amount " .. requested[itemName] .. " from player" .. player.name)
                        game.print(count .. ">=" .. requested[itemName])
                        playerInventory.remove({ name = itemName, count = requested[itemName] })
                        chestInventory.insert({ name = itemName, count = requested[itemName] })
                        requested[itemName] = 0
                    elseif count < requested[itemName] then
                        game.print("Remove " .. itemName .. " in amount " .. count .. " from player" .. player.name)
                        game.print(count .. "<" .. requested[itemName])
                        playerInventory.remove({ name = itemName, count = count })
                        chestInventory.insert({ name = itemName, count = count })
                        requested[itemName] = requested[itemName] - count
                    end
                end

            end
        end

    end
end

local updates_per_tick = 5;
local function on_nth_tick_60(event)
    if not global.yellowChest then
        global.yellowChest = {}
    end

    if not global.blueChest then
        global.blueChest = {}
    end

    local tick = event.tick

    if not global.tick_blue_index then
        global.tick_blue_index = nil
    end
    if not global.tick_yellow_index then
        global.tick_yellow_index = nil
    end
    if not global.tick_blue_player_index then
        global.tick_blue_player_index = nil
    end
    if not global.tick_yellow_player_index then
        global.tick_yellow_player_index = nil
    end
    if not global.tick_yellow_player_connected then
        global.tick_yellow_player_connected = false
    end
    if not global.tick_blue_state then
        global.tick_blue_state = 0
    end
    if not global.tick_yellow_state then
        global.tick_yellow_state = 0
    end

    -- Pick yellow chest
    if global.tick_yellow_state == 0 then

        --game.print("Picking yellow chest")

        if global.tick_yellow_index and not global.yellowChest[global.tick_yellow_index] then
            global.yellowChest[global.tick_yellow_index] = nil
        end

        local yellowIndex, yellowChestData = next(global.yellowChest, global.tick_yellow_index)
        if yellowIndex then
            --game.print("Picked yellow chest " .. yellowIndex)
            global.tick_yellow_index = yellowIndex
            yellowChestData.requested = {}
            yellowChestData.players = {}

            if yellowChestData.started then
                local yellowChestEntity = yellowChestData.entity

                if not yellowChestEntity or not yellowChestEntity.valid then
                    global.yellowChest[global.tick_yellow_index] = nil
                else
                    for _, player in pairs(game.players) do
                        yellowChestData.players[player.index] = player
                    end

                    global.tick_yellow_state = 1
                    --game.print("Yellow chest " .. yellowIndex .. " start inventory check")
                    for i = 1, yellowChestData.entity.request_slot_count do
                        local slot = yellowChestData.entity.get_request_slot(i);
                        if slot then
                            --game.print("Need " .. slot.name .. " in amount " .. slot.count)
                            yellowChestData.requested[slot.name] = slot.count
                        end
                    end
                end
            else
                --game.print("Yellow chest " .. yellowIndex .. " not started")
            end
        else
            -- yellow chest updates complete, moving on
            global.tick_yellow_index = nil
        end
        -- Inventory check for yellow chest
    elseif global.tick_yellow_state == 1 then

        --game.print("Inventory check for yellow chest " .. global.tick_yellow_index)

        if global.tick_yellow_index and not global.yellowChest[global.tick_yellow_index] then
            --game.print("reset in 1 state")
            global.tick_yellow_state = 0
            global.yellowChest[global.tick_yellow_index] = nil
        else

            local yellowChestData = global.yellowChest[global.tick_yellow_index]
            local yellowChestEntity = yellowChestData.entity
            local requested = yellowChestData.requested

            if yellowChestEntity and yellowChestEntity.valid then

                if yellowChestData.started then
                    --game.print("Yellow chest " .. global.tick_yellow_index .. " inventory check. Started")
                    -- 5 check per tick
                    for i = 1, 5 do
                        local playerIndex, _ = next(yellowChestData.players, global.tick_yellow_player_index)

                        --game.print("Yellow player index: " .. tostring(playerIndex))
                        game.print(global.tick_yellow_player_connected)

                        if playerIndex then
                            local player = game.players[playerIndex]

                            global.tick_yellow_player_index = playerIndex

                            if player then
                                --game.print("Scout player: " .. player.name)
                                if player.connected == global.tick_yellow_player_connected then
                                    --game.print("Scout with connection check player: " .. player.name)

                                    local chestInventory = yellowChestEntity.get_inventory(defines.inventory.chest);

                                    if not chestInventory then
                                        break
                                    end

                                    checkPlayerInventoryForRequest(player, requested, chestInventory)
                                end

                            end
                        else
                            --game.print("Switch player connected: " .. tostring(global.tick_yellow_player_connected) .. " to " .. tostring(not global.tick_yellow_player_connected))
                            global.tick_yellow_player_connected = not global.tick_yellow_player_connected
                            global.tick_yellow_player_index = nil
                        end
                    end

                    local needRequest = false
                    for itemName, count in pairs(requested) do
                        if count > 0 then
                            needRequest = true
                        end
                    end

                    if not needRequest then
                        game.print("Request is done")
                        yellowChestData.players = {}
                        global.tick_blue_player_connected = false
                        yellowChestData.started = false
                        global.tick_yellow_state = 0
                    end
                else
                    yellowChestData.players = {}
                    yellowChestData.requested = {}
                    global.tick_yellow_state = 0
                    global.tick_yellow_player_index = nil
                end
            else
                -- Get next yellow chest
                global.tick_yellow_state = 0
            end
        end
    else
        global.tick_yellow_state = 0
    end

    if global.tick_blue_state == 0 then
        if global.tick_blue_index and not global.blueChest[global.tick_blue_index] then
            global.blueChest[global.tick_blue_index] = nil
        end

        local blueIndex, blueChestData = next(global.blueChest, global.tick_blue_index)
        if blueIndex then
            game.print("Picked yellow chest " .. blueIndex)
            global.tick_blue_index = blueIndex
            blueChestData.requested = {}
            if blueChestData.started then
                local blueChestEntity = blueChestData.entity

                if not blueChestEntity or not blueChestEntity.valid then
                    global.blueChest[global.tick_blue_index] = nil
                else
                    global.tick_blue_state = 1
                    for i = 1, blueChestData.entity.request_slot_count do
                        local slot = blueChestData.entity.get_request_slot(i);
                        if slot then
                            game.print("Need " .. slot.name .. " in amount " .. slot.count)
                            blueChestData.requested[slot.name] = slot.count
                        end
                    end
                end
            end
        else
            -- blue chest updates complete, moving on
            global.tick_blue_index = nil
        end
        -- Inventory check for blue chest
    elseif global.tick_blue_state == 1 then

        game.print("Inventory check for blue chest " .. global.tick_blue_index)

        if global.tick_blue_index and not global.blueChest[global.tick_blue_index] then
            global.blueChest[global.tick_blue_index] = nil
        else

            local blueChestData = global.blueChest[global.tick_blue_index]
            local blueChestEntity = blueChestData.entity

            if blueChestEntity and blueChestEntity.valid then

                if blueChestData.started then
                    -- 5 check per tick
                    for i = 1, 5, 1 do
                        local playerIndex, player = next(game.players, global.tick_blue_player_index)

                        if playerIndex then
                            if not player.connected then
                                game.print("Scout player: " .. player.name)
                                local requested = blueChestData.requested

                                local chestInventory = entity.get_inventory(defines.inventory.chest);

                                if not chestInventory then
                                    break
                                end

                                checkPlayerInventoryForRequest(player, requested, chestInventory)
                            end
                        else
                            global.tick_blue_player_index = nil
                            global.tick_blue_state = 0
                        end
                    end

                    local needRequest = false
                    for itemName, count in pairs(requested) do
                        if count > 0 then
                            needRequest = true
                        end
                    end

                    if not needRequest then
                        global.tick_blue_player_connected = false
                        blueChestData.started = false
                        global.tick_blue_state = 0
                    end
                end
            else
                -- Get next blue chest
                global.tick_blue_state = 0
            end
        end
    else
        global.tick_blue_state = 0
    end

    Informatron.on_nth_tick_60(event)
end

script.on_nth_tick(60, on_nth_tick_60)

local function on_gui_opened(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    if not player then
        return
    end

    if not entity then
        return
    end

    if entity.name == "yellow-chest" then
        log(entity.help())

        local yellowChestData = get_make_yellow_chest(entity.unit_number)

        if yellowChestData.entity and yellowChestData.entity.valid then
            local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]
            if (yellowChestGui) then
                yellowChestGui.destroy();
            end
            yellowChestGui = player.gui.relative.add({
                type = "frame",
                name = "fed1s_yellow_chest_gui",
                direction = "vertical",
                caption = { "gui.yellow-chest-gui-label" },
                tags = {
                    id = entity.unit_number,
                    chestType = "yellow"
                }
            })
            yellowChestGui.anchor = {
                gui = defines.relative_gui_type.container_gui,
                position = defines.relative_gui_position["left"],
            }

            local statusText = "Включено"

            if not yellowChestData.started then
                statusText = "Выключено"
            end

            yellowChestGui.add({
                type = "label",
                name = "fed1s_gui_yellow_chest_status",
                caption = { "gui.yellowchest_status", statusText },

            })

            yellowChestGui.add({
                type = "button",
                name = "fed1s_gui_yellow_chest_start_button",
                caption = { "gui.yellowchest_start_button" },
                style = "green_button",
                tags = { id = entity.unit_number, chestType = "yellow" },
                enabled = not yellowChestData.started
            })

            yellowChestGui.add({
                type = "button",
                name = "fed1s_gui_yellow_chest_stop_button",
                caption = { "gui.yellowchest_stop_button" },
                style = "red_button",
                tags = { id = entity.unit_number, chestType = "yellow" },
                enabled = yellowChestData.started
            })
        end


    end

end

local function on_gui_closed(event)
    local player = game.players[event.player_index]

    local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]
    if (yellowChestGui) then
        yellowChestGui.destroy();
    end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)
script.on_event(defines.events.on_gui_closed, on_gui_closed)

local function on_player_flushed_fluid(event)
    local player = game.players[event.player_index]
    local entity = event.entity
    game.print(player.name .. " УДАЛИЛ ЖИДКОСТЬ В ТРУБЕ " .. event.fluid .. " В КОЛИЧЕСТВЕ " .. math.floor(event.amount) .. ". [gps=" .. entity.position.x .. "," .. entity.position.y .. "] ", { 1, 1, 0, 1 })
end
script.on_event(defines.events.on_player_flushed_fluid, on_player_flushed_fluid)

local function on_player_mined_entity(event)
    local player = game.players[event.player_index]
    local entity = event.entity

    if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" or player.name == "fed1s" then
        return ;
    end

    local lastUser = entity.last_user
    local ownername = "unknowm"

    if lastUser then
        ownername = lastUser.name
    end

    if (entity.name == "storage-tank") then
        local fluidExist = false
        local fluidList = ''

        for asd, fluid in pairs(entity.get_fluid_contents()) do

            if fluid > 100 then
                fluidExist = true
                fluidList = fluidList .. asd .. ': ' .. math.floor(fluid) .. '  '
            end
        end

        if fluidExist then
            game.print(player.name .. ' УДАЛЯЕТ РЕЗЕРВУАР С ЖИДКОСТЬЮ. ' .. fluidList .. ". [gps=" .. entity.position.x .. "," .. entity.position.y .. "] ", { 1, 1, 0, 1 })
        end
    end

    if entity.type == "entity-ghost" and ownername == "fed1s" then
        game.print(player.name .. ' УДАЛЯЕТ ЧЕРТЕЖ АДМИНИСТРАТОРА.' .. ". [gps=" .. entity.position.x - math.floor(entity.position.x % 32) .. "," .. entity.position.y - math.floor(entity.position.y % 32) .. "] ", { 1, 1, 0, 1 })
    end
end
script.on_event(defines.events.on_player_mined_entity, on_player_mined_entity)

local function on_pre_ghost_deconstructed(event)
    local player = game.players[event.player_index]

    if player.permission_group.name == "Admin" or player.permission_group.name == "Manager" or player.name == "fed1s" then
        return ;
    end

    local ghost = event.ghost

    local lastUser = ghost.last_user

    local ownername = "unknowm"

    if lastUser then
        ownername = lastUser.name
    end

    if ownername == "fed1s" then
        game.print(player.name .. ' УДАЛЯЕТ ЧЕРТЕЖ АДМИНИСТРАТОРА. ' .. ". [gps=" .. ghost.position.x - math.floor(ghost.position.x % 32) .. "," .. ghost.position.y - math.floor(ghost.position.y % 32) .. "] ", { 1, 1, 0, 1 })
    end
end
script.on_event(defines.events.on_pre_ghost_deconstructed, on_pre_ghost_deconstructed)

local function on_gui_click(event)
    if event.element.tags and event.element.tags.id and event.element.tags.chestType then
        local id = event.element.tags.id
        local chestType = event.element.tags.chestType

        if chestType == "yellow" then
            local yellowChestData = get_make_yellow_chest(id)

            if yellowChestData then
                if event.element.name == "fed1s_gui_yellow_chest_start_button" then
                    yellowChestData.started = true
                elseif event.element.name == "fed1s_gui_yellow_chest_stop_button" then
                    yellowChestData.started = false
                end

                for _, player in pairs(game.players) do
                    local yellowChestGui = player.gui.relative["fed1s_yellow_chest_gui"]

                    if yellowChestGui then
                        yellowChestGui.destroy()
                        return
                    end
                end
            end
        end
    end

    Informatron.on_gui_click(event)
end

script.on_event(defines.events.on_gui_click, on_gui_click)