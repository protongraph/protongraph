class_name ProtonNodeUi
extends GraphNode

# Takes a ProtonNode resource as input and recreate the corresponding UI


var proton_node: ProtonNode


func _ready() -> void:
	position_offset_changed.connect(_on_position_offset_changed)


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


func is_multiple_connections_enabled_on_slot(idx) -> bool:
	if not idx in proton_node.inputs:
		return false

	var input = proton_node.inputs[idx]
	return input.options.multi if "multi" in input.options else false


func _populate_rows():
	# Create an HBoxContainer for each row
	var inputs_count = proton_node.inputs.size()
	var outputs_count = proton_node.outputs.size()
	var rows_count = max(inputs_count, outputs_count)
	for i in rows_count:
		var hbox := HBoxContainer.new()
		add_child(hbox)

	for i in proton_node.inputs.size():
		var input = proton_node.inputs[i]
		var ui = _create_component_for(input)
		get_child(i).add_child(ui)
		ui.visible = input.options.hidden if "hidden" in input.options else true

	for i in proton_node.outputs.size():
		var output = proton_node.outputs[i]
		var ui = _create_component_for(output, false)
		get_child(i).add_child(ui)
		ui.visible = output.options.hidden if "hidden" in output.options else true


func _create_component_for(io: Dictionary, is_input := true) -> GraphNodeUiComponent:
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
		component.size_flags_horizontal = SIZE_EXPAND_FILL
	else:
		component.name = "Output"
	return component


# Reset and disable every connection slots. Avoids leaving ghost slots behind
# when rebuilding the UI.
func _reset_connection_slots() -> void:
	for i in get_child_count():
		set_slot(i, false, 0, Color.BLACK, false, 0, Color.BLACK)


func _setup_connection_slots() -> void:
	_reset_connection_slots()

	for i in proton_node.inputs.size():
		var input = proton_node.inputs[i]
		set_slot_enabled_left(i, true)
		set_slot_type_left(i, input.type)
		set_slot_color_left(i, DataType.COLORS[input.type])

	for i in proton_node.outputs.size():
		var output = proton_node.outputs[i]
		set_slot_enabled_right(i, true)
		set_slot_type_right(i, output.type)
		set_slot_color_right(i, DataType.COLORS[output.type])


func _on_position_offset_changed() -> void:
	proton_node.external_data.position = position_offset
