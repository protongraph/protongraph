class_name ProtonNodeUi
extends GraphNode

# Takes a ProtonNode resource as input and recreate the corresponding UI

signal value_changed(value, slot)
signal connection_changed


var proton_node: ProtonNode

var _input_connections: Dictionary = {}
var _output_connections: Dictionary = {}


func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)
	_update_frame_stylebox()


func clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()


func rebuild_ui() -> void:
	clear()
	title = proton_node.title
	position_offset = proton_node.external_data.position
	show_close = true
	_populate_rows()
	_setup_connection_slots()


func notify_input_connection_changed(slot: int, connected: bool) -> void:
	var row: Control = get_child(slot)
	var ui_component: GraphNodeUiComponent = row.get_child(0)
	ui_component.notify_connection_changed(connected)
	_input_connections[ui_component.index] = connected
	connection_changed.emit()


func notify_output_connection_changed(slot: int, connected: bool) -> void:
	var row: Control = get_child(slot)
	var ui_component: GraphNodeUiComponent = row.get_child(1)
	ui_component.notify_connection_changed(connected)
	_output_connections[ui_component.index] = connected
	connection_changed.emit()


func is_multiple_connections_enabled_on_slot(idx) -> bool:
	if not idx in proton_node.inputs:
		return false

	var input = proton_node.inputs[idx]
	return input.options.multi if "multi" in input.options else false


func is_input_slot_connected(idx) -> bool:
	if idx in _input_connections:
		return _input_connections[idx]
	return false


func _populate_rows():
	# Create an HBoxContainer for each row
	var inputs_count = proton_node.inputs.size()
	var outputs_count = proton_node.outputs.size()
	var rows_count = max(inputs_count, outputs_count)
	for i in rows_count:
		var hbox := HBoxContainer.new()
		hbox.custom_minimum_size.y = 24
		add_child(hbox)

	var current_row = 0 # Needed because the dictionary keys aren't continuous.

	for idx in proton_node.inputs:
		var input: ProtonNodeSlot = proton_node.inputs[idx]
		var ui = _create_component_for(input)
		get_child(current_row).add_child(ui)
		current_row += 1
		ui.visible = input.visible
		ui.value_changed.connect(_on_local_value_changed.bind(idx))

	current_row = 0
	for idx in proton_node.outputs:
		var output: ProtonNodeSlot = proton_node.outputs[idx]
		var ui = _create_component_for(output, false)
		get_child(current_row).add_child(ui)
		current_row += 1
		ui.visible = output.visible


func _create_component_for(io: ProtonNodeSlot, is_input := true) -> GraphNodeUiComponent:
	var component: GraphNodeUiComponent

	if is_input:
		match io.type:
			DataType.BOOLEAN:
				component = BooleanComponent.new()
			DataType.NUMBER:
				component = ScalarComponent.new()
			DataType.STRING:
				component = StringComponent.new()
				#component.template_path = template_path
			DataType.VECTOR2:
				component = VectorComponent.new()
			DataType.VECTOR3:
				component = VectorComponent.new()
			_:
				component = GenericInputComponent.new()
	else:
		component = GenericOutputComponent.new()

	component.create(io.name, io.type, io.options)
	if is_input:
		component.name = "Input"
	else:
		component.name = "Output"
		component.size_flags_stretch_ratio = 0.1

	component.notify_connection_changed(false)
	return component


# Reset and disable every connection slots. Avoids leaving ghost slots behind
# when rebuilding the UI.
func _reset_connection_slots() -> void:
	for i in get_child_count():
		set_slot(i, false, 0, Color.BLACK, false, 0, Color.BLACK)


func _setup_connection_slots() -> void:
	_reset_connection_slots()
	var current_row = 0

	for key in proton_node.inputs.keys():
		var input = proton_node.inputs[key]
		set_slot_enabled_left(current_row, true)
		set_slot_type_left(current_row, input.type)
		set_slot_color_left(current_row, DataType.COLORS[input.type])
		current_row += 1

	current_row = 0
	for key in proton_node.outputs.keys():
		var output = proton_node.outputs[key]
		set_slot_enabled_right(current_row, true)
		set_slot_type_right(current_row, output.type)
		set_slot_color_right(current_row, DataType.COLORS[output.type])
		current_row += 1


func _update_frame_stylebox():
	var current_theme := ThemeManager.get_current_theme()
	var frame_style := current_theme.get_stylebox("frame", "GraphNode").duplicate()
	frame_style.border_color = DataType.get_category_color(proton_node.category)
	add_theme_stylebox_override("frame", frame_style)

	var selected_frame_style := current_theme.get_stylebox("selected_frame", "GraphNode").duplicate()
	selected_frame_style.border_color = frame_style.border_color
	add_theme_stylebox_override("selected_frame", selected_frame_style)


func _on_position_offset_changed() -> void:
	proton_node.external_data.position = position_offset


func _on_local_value_changed(value, idx) -> void:
	value_changed.emit(value, idx)
