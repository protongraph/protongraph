class_name ProtonNodeUi
extends GraphNode

# Takes a ProtonNode resource as input and recreate the corresponding UI

signal value_changed(value, idx)
signal connection_changed


var proton_node: ProtonNode:
	set(val):
		proton_node = val
		_update_frame_stylebox()

var _input_connections := {}
var _output_connections := {}
var _input_component_map := {}
var _output_component_map := {}
var _extras_ui := []


func _ready() -> void:
	resizable = true
	position_offset_changed.connect(_on_position_offset_changed)
	resize_request.connect(_on_resize_request)


func _exit_tree():
	_remove_extra_ui()


func clear() -> void:
	_remove_extra_ui()
	NodeUtil.remove_children(self)
	_input_component_map.clear()
	_output_component_map.clear()
	_input_connections.clear()
	_output_connections.clear()
	size = Vector2i.ZERO


func rebuild_ui() -> void:
	clear()
	title = proton_node.title
	show_close = true

	var data: Dictionary = proton_node.external_data

	if "position" in data:
		position_offset = data.position

	if "size" in data:
		size = data.size

	_populate_rows()
	_setup_connection_slots()


func notify_input_connection_changed(slot: int, connected: bool) -> void:
	var ui_component: GraphNodeUiComponent
	for idx in _input_component_map:
		if _input_component_map[idx].slot == slot:
			ui_component = _input_component_map[idx]

	ui_component.notify_connection_changed(connected)
	_input_connections[ui_component.index] = connected
	connection_changed.emit()


func notify_output_connection_changed(slot: int, connected: bool) -> void:
	var ui_component: GraphNodeUiComponent
	for idx in _output_component_map:
		if _output_component_map[idx].slot == slot:
			ui_component = _output_component_map[idx]

	ui_component.notify_connection_changed(connected)
	_output_connections[ui_component.index] = connected
	connection_changed.emit()


func set_local_value(idx, value) -> void:
	if idx in _input_component_map:
		_input_component_map[idx].set_value(value)


func set_slot_visibility(type: String, idx: Variant, slot_visible: bool) -> void:
	if not proton_node:
		return

	if not "hidden_slots" in proton_node.external_data:
		proton_node.external_data["hidden_slots"] = {
			"input": [],
			"output": [],
			"extra": [],
		}

	var target_array: Array = proton_node.external_data["hidden_slots"][type]

	if slot_visible:
		target_array.erase(idx)

	elif not target_array.has(idx):
		target_array.push_back(idx)

	rebuild_ui()


func is_multiple_connections_enabled_on_slot(slot: int) -> bool:
	var idx = input_slot_to_idx(slot)

	if not idx in proton_node.inputs:
		return false

	var input = proton_node.inputs[idx]
	return input.options.multi if "multi" in input.options else false


func is_input_slot_connected(idx: Variant) -> bool:
	if idx in _input_connections:
		return _input_connections[idx]
	return false


func is_slot_visible(type, idx) -> bool:
	if not proton_node:
		return false

	if not "hidden_slots" in proton_node.external_data:
		return true

	return not idx in proton_node.external_data["hidden_slots"][type]


func input_idx_to_slot(idx: Variant) -> int:
	if idx in _input_component_map:
		return _input_component_map[idx].slot
	return -1


func output_idx_to_slot(idx: Variant) -> int:
	if idx in _output_component_map:
		return _output_component_map[idx].slot
	return -1


func input_slot_to_idx(slot: int) -> Variant:
	for idx in _input_component_map:
		if _input_component_map[idx].slot == slot:
			return idx
	return null


func output_slot_to_idx(slot: int) -> Variant:
	for idx in _output_component_map:
		if _output_component_map[idx].slot == slot:
			return idx
	return null


func _populate_rows():
	var current_row = 0 # Needed because the dictionary keys aren't continuous.
	for idx in proton_node.inputs:
		if is_slot_visible("input", idx):
			var input: ProtonNodeSlot = proton_node.inputs[idx]
			var ui = _create_component_for(input)
			ui.index = idx
			ui.slot = current_row
			_input_component_map[idx] = ui
			_get_or_create_row(current_row).add_child(ui)
			current_row += 1
			ui.value_changed.connect(_on_local_value_changed.bind(idx))

	current_row = 0
	for idx in proton_node.outputs:
		if is_slot_visible("output", idx):
			var output: ProtonNodeSlot = proton_node.outputs[idx]
			var ui = _create_component_for(output, true)
			ui.index = idx
			ui.slot = current_row
			_output_component_map[idx] = ui
			_get_or_create_row(current_row).add_child(ui)
			current_row += 1

	for idx in proton_node.extras:
		if is_slot_visible("extra", idx):
			var extra: ProtonNodeSlot = proton_node.extras[idx]
			var ui
			if extra.type == DataType.MISC_CUSTOM_UI:
				ui = extra.options.custom_ui
				_extras_ui.push_back(ui)
			else:
				ui = _create_component_for(extra)

			var row: Control = _create_new_row()
			row.size_flags_vertical = SIZE_EXPAND_FILL
			row.add_child(ui)


func _create_new_row() -> Node:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size.y = 24
	add_child(hbox)
	return hbox


func _get_or_create_row(row_index) -> Node:
	if row_index < get_child_count():
		return get_child(row_index)

	return _create_new_row()


func _create_component_for(io: ProtonNodeSlot, is_output := false) -> GraphNodeUiComponent:
	var component: GraphNodeUiComponent

	if is_output:
		component = GenericOutputComponent.new()
	else:
		component = UserInterfaceUtil.create_component(io.name, io.type, io.options)

	if io.local_value != null:
		component.set_value(io.local_value)
	else:
		io.local_value = component.get_value()

	if is_output:
		component.name = "Output"
		component.size_flags_stretch_ratio = 0.1
	else:
		component.name = "Input"

	component.notify_connection_changed(false)
	return component


# Reset and disable every connection slots. Avoids leaving ghost slots behind
# when rebuilding the UI.
func _reset_connection_slots() -> void:
	for i in get_child_count():
		set_slot(i, false, 0, Color.BLACK, false, 0, Color.BLACK)


func _setup_connection_slots() -> void:
	_reset_connection_slots()

	var slot: int
	var ui: GraphNodeUiComponent
	var type

	for idx in _input_component_map:
		ui = _input_component_map[idx]
		slot = ui.slot
		type = proton_node.inputs[idx].type
		set_slot_enabled_left(slot, true)
		set_slot_type_left(slot, type)
		set_slot_color_left(slot, DataType.COLORS[type])

	for idx in _output_component_map:
		ui = _output_component_map[idx]
		slot = ui.slot
		type = proton_node.outputs[idx].type
		set_slot_enabled_right(slot, true)
		set_slot_type_right(slot, type)
		set_slot_color_right(slot, DataType.COLORS[type])


func _update_frame_stylebox():
	if not proton_node:
		return

	var current_theme := ThemeManager.get_current_theme()
	var frame_style := current_theme.get_stylebox("frame", "GraphNode").duplicate()
	frame_style.border_color = DataType.get_category_color(proton_node.category)
	add_theme_stylebox_override("frame", frame_style)

	var selected_frame_style := current_theme.get_stylebox("selected_frame", "GraphNode").duplicate()
	selected_frame_style.border_color = frame_style.border_color
	add_theme_stylebox_override("selected_frame", selected_frame_style)


# Custom UI provided by the create_extras() must not be freed, so they are
# removed from the tree before their parents are deleted.
func _remove_extra_ui() -> void:
	for ui in _extras_ui:
		var parent = ui.get_parent()
		parent.remove_child(ui)

	_extras_ui.clear()


func _on_position_offset_changed() -> void:
	proton_node.external_data.position = position_offset


func _on_local_value_changed(value, idx) -> void:
	proton_node.set_local_value(idx, value)
	value_changed.emit(value, idx)


func _on_resize_request(new_min_size) -> void:
	size = new_min_size
	proton_node.external_data.size = new_min_size
