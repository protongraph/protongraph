extends GraphNode
class_name ProtonNodeUi


signal delete_node
signal node_changed
signal input_changed
signal connection_changed # Emitted from CustomGraphEdit
signal gui_value_changed


var display_name: String
var category: String
var minimap_color: Color
var template_path: String # Sometimes needed to get relative paths.

var _inputs := {}
var _outputs := {}
var _extras := {}
var _rows := [] # Stores the hboxes for the visible components

var _resize_timer: Timer
var _2d_preview_index := -1
var _2d_preview: Control
var _initialized := false	# True when all enter_tree initialization is done


func _enter_tree() -> void:
	if _initialized:
		return

	_generate_default_gui()
	_setup_slots()
	_setup_resize_timer()

	_connect_signals()
	_initialized = true


func set_input(idx: int, name: String, type: int, opts: Dictionary = {}) -> void:
	_inputs[idx] = {
		"name": name,
		"type": type,
		"options": opts,
		"mirror": [],
		"driver": -1,
		"linked": [],
		"multi": false,
		"hidden": false,
		"ui": null
	}


func set_output(idx: int, name: String, type: int, opts: Dictionary = {}) -> void:
	_outputs[idx] = {
		"name": name,
		"type": type,
		"options": opts,
		"hidden": false,
		"ui": null
	}


func set_extra(idx: int, type: int, opts := {}) -> void:
	_extras[idx] = {
		"type": type,
		"options": opts,
		"hidden": false,
		"ui": null
	}


func set_input_visibility(idx: int, is_visible: bool) -> void:
	if _inputs.has(idx):
		_inputs[idx]["hidden"] = !is_visible
		regenerate_default_ui()


func set_output_visibility(idx: int, is_visible: bool) -> void:
	if _outputs.has(idx):
		_outputs[idx]["hidden"] = !is_visible
		regenerate_default_ui()


func set_extra_visibility(idx: int, is_visible: bool) -> void:
	if _extras.has(idx):
		_extras[idx]["hidden"] = !is_visible
		regenerate_default_ui()


func remove_input(idx: int) -> bool:
	if not _inputs.erase(idx):
		return false

	if is_input_connected(idx):
		get_parent().disconnect_input(self, get_input_index_pos(idx))

	return true


func remove_output(idx: int) -> bool:
	if not _outputs.erase(idx):
		return false

	if is_input_connected(idx):
		get_parent().disconnect_input(self, get_output_index_pos(idx))

	return true


# Allows multiple connections on the same input slot.
func enable_multiple_connections_on_slot(idx: int) -> void:
	if not _inputs.has(idx):
		return
	_inputs[idx]["multi"] = true


func export_editor_data() -> Dictionary:
	var editor_scale = EditorUtil.get_editor_scale()
	var data = {}
	data["offset_x"] = offset.x / editor_scale
	data["offset_y"] = offset.y / editor_scale

	if resizable:
		data["rect_x"] = rect_size.x / editor_scale
		data["rect_y"] = rect_size.y / editor_scale

	data["inputs"] = {}
	for idx in _inputs:
		data["inputs"][idx] = {}

		# Store the gui local value
		var local_value = _get_default_gui_value(idx, true)
		if local_value != null:
			data["inputs"][idx]["value"] = local_value

		# Store the visibility status if it was changed. By default everything
		# is visible.
		if _inputs[idx]["hidden"]:
			data["inputs"][idx]["hidden"] = true

		if data["inputs"][idx].empty():
			data["inputs"].erase(idx) # No need to store an empty entry

	data["outputs"] = {}
	for idx in _outputs:
		if _outputs[idx]["hidden"]:
			data["outputs"][idx] = {}
			data["outputs"][idx]["hidden"] = true

	data["extras"] = {}
	for idx in _extras:
		if _extras[idx]["hidden"]:
			data["extras"][idx] = {}
			data["extras"][idx]["hidden"] = true

	if data["outputs"].empty():
		data.erase("outputs")

	if data["extras"].empty():
		data.erase("extras")

	return data


func restore_editor_data(data: Dictionary) -> void:
	data = DictUtil.fix_types(data)
	var editor_scale = EditorUtil.get_editor_scale()
	offset.x = data["offset_x"] * editor_scale
	offset.y = data["offset_y"] * editor_scale

	rect_size = Vector2.ZERO
	if data.has("rect_x"):
		rect_size.x = data["rect_x"] * editor_scale
	if data.has("rect_y"):
		rect_size.y = data["rect_y"] * editor_scale

	emit_signal("resize_request", rect_size)

	if data.has("inputs"):
		for idx in data["inputs"]:
			var input = data["inputs"][idx]
			if input.has("value"):
				set_default_gui_value(idx, input["value"])
			if input.has("hidden"):
				_inputs[idx]["hidden"] = input["hidden"]

	if data.has("outputs"):
		for idx in data["outputs"]:
			var output = data["outputs"][idx]
			if output.has("hidden"):
				_outputs[idx]["hidden"] = output["hidden"]

	if data.has("extras"):
		for idx in data["extras"]:
			var extra = data["extras"][idx]
			if extra.has("hidden"):
				_extras[idx]["hidden"] = extra["hidden"]

	# For backward compatibility with pre 0.7
	if data.has("slots"):
		for idx in data["slots"]:
			set_default_gui_value(idx, data["slots"][idx])

	_on_editor_data_restored()


# Automatically change the output data type to mirror the type of what's
# connected to the input slot
func mirror_slots_type(input_index, output_index) -> void:
	if not _mirror_type_check(input_index, output_index):
		return

	_inputs[input_index]["mirror"].push_back(output_index)
	_inputs[input_index]["default_type"] = _inputs[input_index]["type"]
	_update_slots_types()


func cancel_type_mirroring(input_index, output_index) -> void:
	if not _mirror_type_check(input_index, output_index):
		return

	_inputs[input_index]["mirror"].erase(output_index)
	_update_slots_types()


func get_inputs_count() -> int:
	return _inputs.size()


func get_connected_input_type(idx: int) -> int:
	var input_type = -1
	if is_input_connected(idx):
		var slot_pos = get_input_index_pos(idx)
		var inputs: Array = get_parent().get_left_nodes(self, slot_pos)
		if inputs.size() > 0:
			var data = inputs[0]
			var input_node = data["node"]
			var output_idx = input_node.get_output_index_at(data["slot"])
			input_type = input_node._outputs[output_idx]["type"]

	return input_type


# Return the variables exposed to the node inspector. Same format as
# get_property_list [ {name: , type: }, ... ]
func get_exposed_variables() -> Array:
	return []


func get_local_input_type(idx: int) -> int:
	if _inputs.has(idx):
		return _inputs[idx]["type"]
	return -1


func get_output_type(idx: int) -> int:
	if _outputs.has(idx):
		return _outputs[idx]["type"]
	return -1


func is_input_connected(idx: int) -> bool:
	var parent = get_parent()
	if not parent:
		return false

	return parent.is_node_connected_to_input(self, get_input_index_pos(idx))


func is_multiple_connections_enabled_on_slot(idx: int) -> bool:
	if not _inputs.has(idx):
		return false
	return _inputs[idx]["multi"]


func set_default_gui_value(idx: int, value) -> void:
	var pos = get_input_index_pos(idx)
	if not _inputs.has(idx):
		return

	var ui = _inputs[idx]["ui"]
	if ui:
		ui.set_value(value)
	_on_default_gui_value_changed(value, idx)


# Force the node to rebuild the user interface. This is needed because the Node
# is generated under a spatial, which make accessing the current theme
# impossible and breaks OptionButtons.
func regenerate_default_ui():
	var template = get_parent()
	if not template:
		return

	var connections = template.backup_connections_for(self)
	template.disconnect_active_connections(self)
	var editor_data = export_editor_data()
	_generate_default_gui()
	restore_editor_data(editor_data)
	_setup_slots()
	template.restore_connections_for(self, connections)


func force_redraw():
	var parent = get_parent()
	if parent:
		parent.force_redraw()


# Override and make it return true if your node should be instanced from a
# scene directly.
# Scene should have the same name as the script and use a ".tscn" extension.
# When using a custom gui, you lose access to the default gui. You have to
# define slots and undo redo yourself but you have complete control over the
# node appearance and behavior.
func has_custom_gui() -> bool:
	return false


# Get the input index of a slot. Indices are arbitrary numbers that doesn't
# match the slot physical position among other other slots.
# Returns -1 if the input index wasn't found
func get_input_index_at(pos: int) -> int:
	if pos == -1 or pos >= _rows.size():
		return -1

	var row = _rows[pos]
	if not row.has_node("Input"):
		return -1

	return row.get_node("Input").index



func get_output_index_at(pos: int) -> int:
	if pos >= _rows.size():
		return -1

	var row = _rows[pos]
	if not row.has_node("Output"):
		return -1

	return row.get_node("Output").index


# Opposite of _get_input_index_at, takes an input index and return its UI
# slot position.
# returns -1 if the input index is invalid or not visible
func get_input_index_pos(idx: int) -> int:
	for i in _rows.size():
		var row = _rows[i]
		if not row.has_node("Input"):
			continue
		if row.get_node("Input").index == idx:
			return i
	return -1


func get_output_index_pos(idx: int) -> int:
	for i in _rows.size():
		var row = _rows[i]
		if not row.has_node("Output"):
			continue
		if row.get_node("Output").index == idx:
			return i
	return -1


# Returns a list of every ProtonNode connected to this node
func _get_connected_inputs() -> Array:
	var connected_inputs = []
	for idx in _inputs:
		var slot_pos = get_input_index_pos(idx)
		var nodes: Array = get_parent().get_left_nodes(self, slot_pos)
		for data in nodes:
			connected_inputs.push_back(data["node"])
	return connected_inputs


# Override this if you're using a custom GUI to change input slots default
# behavior. This returns the local input data for the given slot
func _get_input(_index: int) -> Array:
	return []


# Used in mirror_slot_types and cancel_slot_types. Prints a warning if the
# provided slot is out of bounds.
func _mirror_type_check(input_index, output_index) -> bool:
	if not _inputs.has(input_index):
		print("Error: invalid input index (", input_index, ") passed to ", display_name)
		return false

	if not _outputs.has(output_index):
		print("Error: invalid output index (", input_index, ") passed to ", display_name)
		return false

	return true


# Returns true if the given output slot get its type from a mirrored input.
# False otherwise
func _is_output_mirrored(output_index: int) -> bool:
	if not _outputs.has(output_index):
		return false

	for i in _inputs:
		for index in _inputs[i]["mirror"]:
			if index == output_index:
				return true

	return false


# Based on the previous calls to set_input and set_ouput, this method will call
# the GraphNode.set_slot method accordingly with the proper parameters. This
# makes it easier syntax wise on the derived node and makes it more readable.
func _setup_slots() -> void:
	# Reset and disable all slots to avoid leaving ghost slots when hiding
	# graph node ui components.
	for i in get_child_count():
		set_slot(i, false, 0, Color.black, false, 0, Color.black)

	# Setup a slot for each visible components.
	for i in _rows.size():
		var has_input := false
		var input_type := 0
		var input_color := Color(0)
		var has_output := false
		var output_type := 0
		var output_color := Color(0)
		var input_icon = null
		var output_icon = null
		var row = _rows[i]

		if row.has_node("Input"):
			has_input = true
			var input_component = row.get_node("Input")
			var i_idx = input_component.index
			var driver = _inputs[i_idx]["driver"]
			if driver != -1:
				input_type = _inputs[driver]["type"]
			else:
				input_type = _inputs[i_idx]["type"]
			input_color = DataType.COLORS[input_type]
			input_icon = TextureUtil.get_input_texture(_inputs[i_idx]["multi"])

		if row.has_node("Output"):
			has_output = true
			var output_component = row.get_node("Output")
			var o_idx = output_component.index
			output_type = _outputs[o_idx]["type"]
			output_color = DataType.COLORS[output_type]
			output_icon = TextureUtil.get_output_texture()

		set_slot(i, has_input, input_type, input_color, has_output, output_type, output_color, input_icon, output_icon)

	# If the node can't be resized, make it as small as possible
	if not resizable:
		emit_signal("resize_request", Vector2(rect_min_size.x, 0.0))


# Clear all child controls
func _clear_gui() -> void:
	for child in _rows:
		remove_child(child)
		child.queue_free()

	_rows = []

	for idx in _inputs:
		_inputs[idx]["ui"] = null

	for idx in _outputs:
		_outputs[idx]["ui"] = null

	for idx in _extras:
		var ui = _extras[idx]["ui"]
		if ui:
			remove_child(ui)
			ui.queue_free()
			_extras[idx]["ui"] = null


func _generate_default_gui_style() -> void:
	var scale: float = EditorUtil.get_editor_scale()

	# Base Style
	var style = StyleBoxFlat.new()
	var color = Color("e61f2531")
	style.border_color = DataType.to_category_color(category)
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
	selected_style.shadow_color = DataType.to_category_color(category)
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

	add_constant_override("port_offset", int(12 * scale))
	add_font_override("title_font", get_font("bold", "EditorFonts"))
	add_constant_override("separation", 2)
	add_constant_override("title_offset", int(21 * scale))
	add_constant_override("close_offset", int(21 * scale))


# Generate a default UI based on the parameters found in _inputs and _outputs.
# Each slot gets a GraphNodeComponent based on the data type. This component
# adds type specific UI, scalars get a spinbox and so on. It's also the
# component responsibility to display the type icon and slot name.
func _generate_default_gui() -> void:
	_clear_gui()
	_generate_default_gui_style()

	title = display_name
	show_close = true
	rect_min_size = Vector2(0.0, 0.0)
	rect_size = Vector2(0.0, 0.0)

	for idx in _inputs:
		var component = _create_component("input", idx)
		if component:
			component.name = "Input"
			Signals.safe_connect(component, "value_changed", self, "_on_default_gui_value_changed", [idx])
			_inputs[idx]["ui"] = component

	for idx in _outputs:
		var component = _create_component("output", idx)
		if component:
			component.name = "Output"
			_outputs[idx]["ui"] = component

	var input_keys = _inputs.keys()
	var output_keys = _outputs.keys()

	while not input_keys.empty() or not output_keys.empty():
		# Create a Hbox container per slot like this
		# -> [InputComponent, OutputComponent]
		var hbox = HBoxContainer.new()
		hbox.rect_min_size.y = Constants.get_slot_height()

		while not input_keys.empty():
			var i_idx = input_keys.pop_front()
			if i_idx != null and not _inputs[i_idx]["hidden"]:
				hbox.add_child(_inputs[i_idx]["ui"])
				break

		while not output_keys.empty():
			var o_idx = output_keys.pop_front()
			if o_idx != null and not _outputs[o_idx]["hidden"]:
				hbox.add_child(_outputs[o_idx]["ui"])
				break

		if hbox.get_child_count() > 0:
			add_child(hbox)
			_rows.push_back(hbox)

	for idx in _extras:
		if _extras[idx]["hidden"]:
			continue

		if _extras[idx]["type"] == Constants.UI_PREVIEW_2D:
			var preview = preload("components/preview_2d.tscn").instance()
			preview.link_to_output(_extras[idx]["options"]["output_index"])
			_extras[idx]["ui"] = preview
			Signals.safe_connect(preview, "preview_hidden", self, "_on_2d_preview_hidden")
			add_child(preview)

	_on_connection_changed()
	_on_default_gui_ready()


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
			DataType.BOOLEAN:
				component = BooleanComponent.new()

			DataType.SCALAR:
				component = ScalarComponent.new()

			DataType.STRING:
				component = StringComponent.new()
				component.template_path = template_path

			DataType.VECTOR2:
				component = VectorComponent.new()

			DataType.VECTOR3:
				component = VectorComponent.new()

			_:
				component = GenericInputComponent.new()
	else:
		component = GenericOutputComponent.new()

	component.create(text, type, opts)
	component.index = i
	return component


func _get_default_gui_value(idx: int, for_export := false):
	if not _inputs.has(idx):
		return null

	var component: GraphNodeComponent = _inputs[idx]["ui"]
	if not component:
		return null

	if for_export:
		return component.get_value_for_export()
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


func _setup_resize_timer() -> void:
	if not _resize_timer:
		_resize_timer = Timer.new()
		_resize_timer.one_shot = true
		_resize_timer.autostart = false
		add_child(_resize_timer)


func _update_slots_types() -> void:
	# Change the slots type if the mirror option is enabled
	var slots_types_updated = false

	for i in _inputs:
		for o in _inputs[i]["mirror"]:
			slots_types_updated = true
			var type = _inputs[i]["default_type"]

			# Copy the connected input type if there is one but if
			# multi connection is enabled, all connected inputs must share the
			# same type otherwise it will use the default type.
			if is_input_connected(i):
				var slot_pos = get_input_index_pos(i)
				var inputs: Array = get_parent().get_left_nodes(self, slot_pos)
				var input_type = -1

				for data in inputs:
					var input_node = data["node"]
					if not input_node:
						continue
					var output_idx = input_node.get_output_index_at(data["slot"])
					if output_idx == -1:
						continue
					if input_type == -1:
						input_type = input_node._outputs[output_idx]["type"]
					else:
						if input_node._outputs[output_idx]["type"] != input_type:
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
	if not resizable:
		return
	if not _resize_timer:
		_setup_resize_timer()
	_resize_timer.start(2.0)


func _on_resize_timeout() -> void:
	emit_signal("node_changed", self, false)


func _on_close_request() -> void:
	emit_signal("delete_node", self)


func _on_connection_changed() -> void:
	# Notify the UI slot component about the new connection status. Some
	# components hides their icon and label depending on this.
	for idx in _inputs:
		var connected = is_input_connected(idx)
		var ui = _inputs[idx]["ui"]
		if ui:
			ui.notify_connection_changed(connected)

	_update_slots_types()
	_redraw()


func _on_default_gui_value_changed(value, slot: int) -> void:
	emit_signal("gui_value_changed", value, slot)
	emit_signal("input_changed", slot, value)


func _on_2d_preview_hidden() -> void:
	if not resizable:
		emit_signal("resize_request", Vector2(rect_min_size.x, 0.0))


func _on_default_gui_ready() -> void:
	pass


# Override in child nodes. Called when restore_editor_data() has completed
func _on_editor_data_restored() -> void:
	pass
