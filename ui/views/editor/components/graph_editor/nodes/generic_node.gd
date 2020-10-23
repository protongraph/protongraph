extends GraphNode
class_name GenericNodeUi


signal delete_node
signal node_changed
signal input_changed
signal connection_changed


# Set to true to force the template to recreate the whole node instead of the 
# style only. Useful if the graphnode has UI controls like OptionButtons that
# can't be generated properly under a spatial node.
var requires_full_gui_rebuild := false
var inline_vectors := false
var minimap_color: Color
var template_path: String # Sometimes needed to get relative paths.


var _spinbox
var _node: ConceptNode
var _inputs := {}
var _outputs := {}
var _hboxes := []
var _resize_timer := Timer.new()
var _file_dialog: FileDialog
var _initialized := false	# True when all enter_tree initialization is done


func _enter_tree() -> void:
	if _initialized:
		return

	_resize_timer.one_shot = true
	_resize_timer.autostart = false
	add_child(_resize_timer)

	_connect_signals()
	_initialized = true


func create_from(node: ConceptNode) -> void:
	_node = node
	_inputs = node.inputs.duplicate(true)
	_outputs = node.outputs.duplicate(true)


func export_editor_data() -> Dictionary:
	var editor_scale = ConceptGraphEditorUtil.get_editor_scale()
	var data = {}
	data["offset_x"] = offset.x / editor_scale
	data["offset_y"] = offset.y / editor_scale

	if resizable:
		data["rect_x"] = rect_size.x / editor_scale
		data["rect_y"] = rect_size.y / editor_scale

	data["slots"] = {}
	for i in _inputs.size():
		var idx = String(i) # Needed to fix inconsistencies when calling restore
		var local_value = _get_default_gui_value(i, true)
		if local_value != null:
			data["slots"][idx] = local_value

	return data


func restore_editor_data(data: Dictionary) -> void:
	var editor_scale = ConceptGraphEditorUtil.get_editor_scale()
	offset.x = data["offset_x"] * editor_scale
	offset.y = data["offset_y"] * editor_scale

	rect_size = Vector2.ZERO
	if data.has("rect_x"):
		rect_size.x = data["rect_x"] * editor_scale
	if data.has("rect_y"):
		rect_size.y = data["rect_y"] * editor_scale

	emit_signal("resize_request", rect_size)

	var slots = _hboxes.size()

	for i in slots:
		if data["slots"].has(String(i)):
			var value = data["slots"][String(i)]
			set_default_gui_value(i, value)


func get_inputs_count() -> int:
	return _inputs.size()


func get_connected_input_type(idx) -> int:
	var input_type = -1
	if is_input_connected(idx):
		var inputs: Array = get_parent().get_left_nodes(self, idx)
		for data in inputs:
			if input_type == -1:
				input_type = data["node"]._outputs[data["slot"]]["type"]
				break

	return input_type


"""
Return the variables exposed to the node inspector. Same format as
get_property_list [ {name: , type: }, ... ]
"""
func get_exposed_variables() -> Array:
	return []


func is_input_connected(idx: int) -> bool:
	var parent = get_parent()
	if not parent:
		return false

	return parent.is_node_connected_to_input(self, idx)


func is_multiple_connections_enabled_on_slot(idx: int) -> bool:
	if idx >= _inputs.size():
		return false
	return _inputs[idx]["multi"]


func set_default_gui_value(slot: int, value) -> void:
	if _hboxes.size() <= slot:
		return
	
	var component = _hboxes[slot].get_node("Input")
	component.set_value(value)


"""
Force the node to rebuild the user interface. This is needed because the Node 
is generated under a spatial, which make accessing the current theme
impossible and breaks OptionButtons.
"""
func regenerate_default_ui():
	var editor_data = export_editor_data()
	_generate_default_gui()
	restore_editor_data(editor_data)
	_setup_slots()


"""
Returns a list of every ConceptNode connected to this node
"""
func _get_connected_inputs() -> Array:
	var connected_inputs = []
	for i in _inputs.size():
		var nodes: Array = get_parent().get_left_nodes(self, i)
		for data in nodes:
			connected_inputs.append(data["node"])
	return connected_inputs


"""
Returns true if the given output slot get its type from a mirrored input.
False otherwise
"""
func _is_output_mirrored(output_index: int) -> bool:
	if output_index >= _outputs.size():
		return false
	
	for i in _inputs.size():
		for index in _inputs[i]["mirror"]:
			if index == output_index:
				return true
	
	return false


"""
Based on the previous calls to set_input and set_ouput, this method will call the
GraphNode.set_slot method accordingly with the proper parameters. This makes it easier syntax
wise on the child node side and make it more readable.
"""
func _setup_slots() -> void:
	var slots = _hboxes.size()
	for i in slots + 1:	# +1 to prevent leaving an extra slot active when removing inputs
		var has_input := false
		var input_type := 0
		var input_color := Color(0)
		var has_output := false
		var output_type := 0
		var output_color := Color(0)
		var input_icon = null
		var output_icon = null

		if _inputs.has(i):
			has_input = true
			var driver = _inputs[i]["driver"]
			if driver != -1:
				input_type = _inputs[driver]["type"]
			else:
				input_type = _inputs[i]["type"]
			input_color = ConceptGraphDataType.COLORS[input_type]
			input_icon = TextureUtil.get_input_texture(_inputs[i]["multi"])
		
		if _outputs.has(i):
			has_output = true
			output_type = _outputs[i]["type"]
			output_color = ConceptGraphDataType.COLORS[output_type]
			output_icon = TextureUtil.get_output_texture()

		if not has_input and not has_output and i < _hboxes.size():
			_hboxes[i].visible = false

		set_slot(i, has_input, input_type, input_color, has_output, output_type, output_color, input_icon, output_icon)

	# Remove elements generated as part of the default gui but doesn't match any slots
	for b in _hboxes:
		if not b.visible:
			_hboxes.erase(b)
			remove_child(b)

	# If the node can't be resized, make it as small as possible
	if not resizable:
		emit_signal("resize_request", Vector2(rect_min_size.x, 0.0))


"""
Clear all child controls
"""
func _clear_gui() -> void:
	_hboxes = []
	for child in get_children():
		if child is Control:
			remove_child(child)
			child.queue_free()


func _generate_default_gui_style() -> void:
	var scale: float = ConceptGraphEditorUtil.get_editor_scale()

	# Base Style
	var style = StyleBoxFlat.new()
	var color = Color("e61f2531")
	style.border_color = ConceptGraphDataType.to_category_color(_node.category)
	minimap_color = style.border_color
	style.set_bg_color(color)
	style.set_border_width_all(2 * scale)
	style.set_border_width(MARGIN_TOP, 32 * scale)
	style.content_margin_left = 22 * scale;
	style.content_margin_right = 22 * scale;
	style.set_corner_radius_all(4 * scale)
	style.set_expand_margin_all(4 * scale)
	style.shadow_size = 8 * scale
	style.shadow_color = Color(0, 0, 0, 0.2)

	# Selected Style
	var selected_style = style.duplicate()
	selected_style.shadow_color = ConceptGraphDataType.to_category_color(_node.category)
	selected_style.shadow_size = 4 * scale
	selected_style.border_color = color

	if not comment:
		add_stylebox_override("frame", style)
		add_stylebox_override("selectedframe", selected_style)
	else:
		style.set_bg_color(Color("0a4371b5"))
		style.content_margin_top = 40 * scale
		add_stylebox_override("comment", style)
		add_stylebox_override("commentfocus", selected_style)

	add_constant_override("port_offset", 12 * scale)
	var bold_font: Font = get_font("bold", "EditorFonts")
	add_font_override("title_font", get_font("bold", "EditorFonts"))
	add_constant_override("separation", 2)
	add_constant_override("title_offset", 21 * scale)
	add_constant_override("close_offset", 21 * scale)


# Generate a default UI based on the parameters found in _inputs and _outputs.
# Each slot gets a GraphNodeComponent based on the data type. This component 
# adds type specific UI, scalars get a spinbox and so on. It's also the 
# component responsibility to display the type icon and slot name.
func _generate_default_gui() -> void:
	_clear_gui()
	_generate_default_gui_style()

	title = _node.display_name
	show_close = true
	rect_min_size = Vector2(0.0, 0.0)
	rect_size = Vector2(0.0, 0.0)
	var total_slots = max(_inputs.size(), _outputs.size())
	
	for i in total_slots:
		# Create a Hbox container per slot like this
		# -> [InputComponent, OutputComponent]
		var hbox = HBoxContainer.new()
		hbox.rect_min_size.y = Constants.get_slot_height()
		_hboxes.append(hbox)
		add_child(hbox)
		
		var input_component = _create_component("input", i)
		if input_component:
			input_component.name = "Input"
			hbox.add_child(input_component)
		
		var output_component = _create_component("output", i)
		if output_component:
			output_component.name = "Output"
			hbox.add_child(output_component)

	_on_connection_changed()
	_redraw()


func _create_component(source: String, i: int) -> GraphNodeComponent:
	var data = _inputs if source == "input" else _outputs
	if not data.has(i):
		return null
	
	var component
	var opts = data[i]["options"] if data[i].has("options") else {}
	var text = data[i]["name"]
	var type = data[i]["type"]
	
	if source == "input":
		match type:
			ConceptGraphDataType.BOOLEAN:
				component = BooleanComponent.new()
				
			ConceptGraphDataType.SCALAR:
				component = ScalarComponent.new()
				
			ConceptGraphDataType.STRING:
				component = StringComponent.new()
				component.template_path = template_path
				
			ConceptGraphDataType.VECTOR2:
				component = VectorComponent.new()
			
			ConceptGraphDataType.VECTOR3:
				component = VectorComponent.new()

			_:
				component = GenericInputComponent.new()
	else:
		component = GenericOutputComponent.new()

	component.create(text, type, opts)
	return component


func _get_default_gui_value(idx: int, for_export := false):
	if _hboxes.size() <= idx:
		return null
	
	var component: GraphNodeComponent = _hboxes[idx].get_node("Input")
	return component.get_value()


# Forces the GraphNode to redraw its gui, mostly to fix outdated connections
# after a resize.
func _redraw() -> void:
	if not resizable:
		emit_signal("resize_request", Vector2(rect_min_size.x, 0.0))
	if get_parent():
		get_parent().force_redraw()


func _connect_signals() -> void:
	Signals.safe_connect(self, "close_request", self, "_on_close_request")
	Signals.safe_connect(self, "resize_request", self, "_on_resize_request")
	Signals.safe_connect(self, "connection_changed", self, "_on_connection_changed")
	Signals.safe_connect(_resize_timer, "timeout", self, "_on_resize_timeout")


func _update_slots_types() -> void:
	# Change the slots type if the mirror option is enabled
	var slots_types_updated = false

	for i in _inputs.size():
		for o in _inputs[i]["mirror"]:
			slots_types_updated = true
			var type = _inputs[i]["default_type"]

			# Copy the connected input type if there is one but if multi connection is enabled,
			# all connected inputs must share the same type otherwise it will use the default type.
			if is_input_connected(i):
				var inputs: Array = get_parent().get_left_nodes(self, i)
				var input_type = -1

				for data in inputs:
					if not data["node"]:
						continue
					if input_type == -1:
						input_type = data["node"]._outputs[data["slot"]]["type"]
					else:
						if data["node"]._outputs[data["slot"]]["type"] != input_type:
							input_type = -2
				if input_type >= 0:
					type = input_type

			_inputs[i]["type"] = type
			_outputs[o]["type"] = type

	if slots_types_updated:
		_setup_slots()
		# Propagate the type change to the connected nodes
		var parent = get_parent()
		if parent:
			for node in parent.get_all_right_nodes(self):
				node.emit_signal("connection_changed")


func _on_resize_request(new_size) -> void:
	rect_size = new_size
	if resizable:
		_resize_timer.start(2.0)


func _on_resize_timeout() -> void:
	emit_signal("node_changed", self, false)


func _on_close_request() -> void:
	emit_signal("delete_node", self)


"""
When the nodes connections changes, this method checks for all the input slots 
and hides everything that's not a label if something is connected to the
associated slot.

For types like Numbers, Strings, Vectors or Boolean, it's possible to set a
value on the node itself, but if something is connected to the slot, it takes
priority over the local value. Hiding the default GUI should avoid some 
confusion by not displaying a value that's not used.
"""
func _on_connection_changed() -> void:
	# Hides the default gui (except for the name) if something is connected to 
	# the given slot
	for i in _inputs.size():
		var connected = is_input_connected(i)
		var type = _inputs[i]["type"]
		if _inputs[i].has("default_type"):
			type = _inputs[i]["default_type"] # Mirroring is enabled
		
		var component = _hboxes[i].get_node("Input")
		component.notify_connection_changed(connected)


	_update_slots_types()
	_redraw()


func _on_default_gui_value_changed(value, slot: int) -> void:
	emit_signal("node_changed", self, true)
	emit_signal("input_changed", slot, value)
