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
Return the variables exposed to the node inspector. Same format as get_property_list
[ {name: , type: }, ... ]
"""
func get_exposed_variables() -> Array:
	return []


func is_input_connected(idx: int) -> bool:
	var parent = get_parent()
	if not parent:
		return false

	return parent.is_node_connected_to_input(self, idx)


func set_default_gui_value(slot: int, value) -> void:
	if _hboxes.size() <= slot:
		return

	var type = _inputs[slot]["type"]
	var left = _hboxes[slot].get_node("Left")

	match type:
		ConceptGraphDataType.BOOLEAN:
			left.get_node("CheckBox").pressed = value
		ConceptGraphDataType.SCALAR:
			left.get_node("SpinBox").value = value
		ConceptGraphDataType.STRING:
			if left.has_node("LineEdit"):
				left.get_node("LineEdit").text = value
			elif left.has_node("OptionButton"):
				var btn: OptionButton = left.get_node("OptionButton")
				btn.selected = btn.get_item_index(int(value))
		ConceptGraphDataType.VECTOR2:
			_set_vector_value(slot, value)
		ConceptGraphDataType.VECTOR3:
			_set_vector_value(slot, value)


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
	print("Bold font : ", bold_font)
	add_font_override("title_font", get_font("bold", "EditorFonts"))
	add_constant_override("separation", 2)
	add_constant_override("title_offset", 21 * scale)
	add_constant_override("close_offset", 21 * scale)


"""
If the child node does not define a custom UI itself, this function will generate a default UI
based on the parameters provided with set_input and set_ouput. Each slots will have a Label
and their name attached.
The input slots will have additional UI elements based on their type.
Scalars input gets a spinbox that's hidden when something is connected to the slot.
Values stored in the spinboxes are automatically exported and restored.
"""
func _generate_default_gui() -> void:
	_clear_gui()
	_generate_default_gui_style()

	title = _node.display_name
	show_close = true
	rect_min_size = Vector2(0.0, 0.0)
	rect_size = Vector2(0.0, 0.0)
	var max_output_label_length := 0
	var slots = max(_inputs.size(), _outputs.size())
	
	for i in slots:
		# Create a Hbox container per slot like this -> [InputComponent, OutputComponent]
		var hbox = HBoxContainer.new()
		hbox.rect_min_size.y = 24 * ConceptGraphEditorUtil.get_editor_scale()

		# Make sure it appears in the editor and store along the other Hboxes
		_hboxes.append(hbox)
		add_child(hbox)

		# If this slot has an input
		if _inputs.has(i):

			var opts = _inputs[i]["options"] if _inputs[i].has("options") else null

			var input_type = _inputs[i]["type"]
			
			label_left.text = _inputs[i]["name"]
			label_left.hint_tooltip = ConceptGraphDataType.Types.keys()[_inputs[i]["type"]].capitalize()

			# Add the optional UI elements based on the data type.
			# TODO : We could probably just check if the property exists with get_property_list
			# and do that automatically instead of manually setting everything one by one
			match _inputs[i]["type"]:
				ConceptGraphDataType.BOOLEAN:
					var checkbox = CheckBox.new()
					checkbox.focus_mode = Control.FOCUS_NONE
					checkbox.name = "CheckBox"
					checkbox.pressed = opts["value"] if opts.has("value") else false
					checkbox.connect("toggled", self, "_on_default_gui_value_changed", [i])
					checkbox.connect("toggled", self, "_on_default_gui_interaction", [checkbox, i])
					left_box.add_child(checkbox)

				ConceptGraphDataType.SCALAR:
					var n = _inputs[i]["name"]
					var out_n = ""
					_create_spinbox(n, opts, left_box, i)
					label_left.visible = false
					
					if _outputs.has(i):
						out_n = _outputs[i]["name"]

					# Make sure there's enough horizontal space for the custom
					# spinbox when the name is too large
					var char_count = n.length() + out_n.length()
					var scale = ConceptGraphEditorUtil.get_editor_scale()
					var rx = (char_count * 8.0 + 150.0) * scale
					if rect_min_size.x < rx:
						rect_min_size.x = rx

				ConceptGraphDataType.STRING:
					if opts.has("type") and opts["type"] == "dropdown":
						var dropdown = OptionButton.new()
						dropdown.add_stylebox_override("normal", load("res://views/themes/styles/graphnode_button_normal.tres"))
						dropdown.add_stylebox_override("hover", load("res://views/themes/styles/graphnode_button_hover.tres"))
						dropdown.focus_mode = Control.FOCUS_NONE
						dropdown.name = "OptionButton"
						for item in opts["items"].keys():
							dropdown.add_item(item, opts["items"][item])
						dropdown.connect("item_selected", self, "_on_default_gui_value_changed", [i])
						dropdown.connect("item_selected", self, "_on_default_gui_interaction", [dropdown, i])
						left_box.add_child(dropdown)
						requires_full_gui_rebuild = true
					else:
						var line_edit = LineEdit.new()
						line_edit.add_stylebox_override("normal", load("res://views/themes/styles/graphnode_button_normal.tres"))
						line_edit.add_stylebox_override("focus", load("res://views/themes/styles/graphnode_line_edit_focus.tres"))
						line_edit.rect_min_size.x = 120
						line_edit.name = "LineEdit"
						line_edit.placeholder_text = opts["placeholder"] if opts.has("placeholder") else "Text"
						line_edit.expand_to_text_length = opts["expand"] if opts.has("expand") else true
						line_edit.text = opts["text"] if opts.has("text") else ""
						line_edit.connect("text_changed", self, "_on_default_gui_value_changed", [i])
						line_edit.connect("text_changed", self, "_on_default_gui_interaction", [line_edit, i])
						left_box.add_child(line_edit)

						if opts.has("file_dialog"):
							var folder_button = Button.new()
							folder_button.add_stylebox_override("normal", load("res://views/themes/styles/graphnode_button_normal.tres"))
							folder_button.add_stylebox_override("hover", load("res://views/themes/styles/graphnode_button_hover.tres"))
							folder_button.icon = TextureUtil.get_texture("res://ui/icons/icon_folder.svg")
							folder_button.connect("pressed", self, "_show_file_dialog", [opts["file_dialog"], line_edit])
							left_box.add_child(folder_button)

				ConceptGraphDataType.VECTOR2:
					label_left.visible = false
					left_box.add_child(_create_vector_default_gui(_inputs[i]["name"], opts, 2, i))

				ConceptGraphDataType.VECTOR3:
					label_left.visible = false
					left_box.add_child(_create_vector_default_gui(_inputs[i]["name"], opts, 3, i))

		# Label right holds the output slot name. Set to expand and align_right to push the text on
		# the right side of the node panel
		var label_right = Label.new()
		label_right.name = "LabelRight"
		label_right.mouse_filter = MOUSE_FILTER_PASS
		#label_right.size_flags_horizontal = SIZE_EXPAND_FILL
		label_right.size_flags_horizontal = SIZE_FILL
		label_right.align = Label.ALIGN_RIGHT
		label_right.visible = false
		
		var output_icon_container = CenterContainer.new()
		var output_icon = TextureRect.new()
		output_icon_container.add_child(output_icon)

		if _outputs.has(i):
			label_right.text = _outputs[i]["name"]
			if label_right.text.length() > max_output_label_length:
				max_output_label_length = label_left.text.length()
			label_right.hint_tooltip = ConceptGraphDataType.Types.keys()[_outputs[i]["type"]].capitalize()
			if label_right.text != "":
				label_right.visible = true
			
			var out_opts = _outputs[i]["options"]
			var show_output_icon := true
			if out_opts and out_opts.has("type_icon"):
				show_output_icon = out_opts["type_icon"]
			
			if show_output_icon and not _is_output_mirrored(i):
				output_icon.texture = TextureUtil.get_slot_icon(_outputs[i]["type"])
				output_icon.modulate = ConceptGraphDataType.COLORS[_outputs[i]["type"]]

		hbox.add_child(label_right)
		hbox.add_child(output_icon_container)

	rect_min_size.x += max_output_label_length * 6.0 # TODO; tmp hack, use editor scale here and find a better layout
	_on_connection_changed()
	_redraw()


func _create_spinbox(property_name, opts, parent, idx) -> SpinBox:
	if not _spinbox:
		_spinbox = preload("res://ui/views/editor/components/spinbox/spinbox.tscn")
	var spinbox = _spinbox.instance()
	if parent:
		parent.add_child(spinbox)
	spinbox.set_label_text(property_name)
	spinbox.name = "SpinBox"
	spinbox.max_value = opts["max"] if opts.has("max") else 1000
	spinbox.min_value = opts["min"] if opts.has("min") else 0
	spinbox.value = opts["value"] if opts.has("value") else 0
	spinbox.step = opts["step"] if opts.has("step") else 0.001
	spinbox.exp_edit = opts["exp"] if opts.has("exp") else false
	spinbox.allow_greater = opts["allow_greater"] if opts.has("allow_greater") else true
	spinbox.allow_lesser = opts["allow_lesser"] if opts.has("allow_lesser") else true
	spinbox.rounded = opts["rounded"] if opts.has("rounded") else false
	spinbox.connect("value_changed", self, "_on_default_gui_value_changed", [idx])
	spinbox.connect("value_changed", self, "_on_default_gui_interaction", [spinbox, idx])
	return spinbox


func _create_vector_default_gui(property_name, opts, count, idx) -> VBoxContainer:
	var item_indexes = ["x", "y"]
	if count == 3:
		item_indexes.append("z")

	var vbox = VBoxContainer.new()
	vbox.name = "VectorContainer"
	
	var label_box = HBoxContainer.new()

	var show_input_icon := true
	if opts and opts.has("type_icon"):
		show_input_icon = opts["type_icon"]
	
	if show_input_icon:
		var input_icon_container = CenterContainer.new()
		var input_icon = TextureRect.new()
		
		var type = ConceptGraphDataType.VECTOR2
		if count == 3:
			type = ConceptGraphDataType.VECTOR3
		
		input_icon.texture = TextureUtil.get_slot_icon(type)
		input_icon.modulate = ConceptGraphDataType.COLORS[type]
		
		input_icon_container.add_child(input_icon)
		label_box.add_child(input_icon_container)

	if property_name:
		var label = Label.new()
		label.text = property_name
		label_box.add_child(label)
	
	if label_box.get_child_count() != 0:
		vbox.add_child(label_box)
	

	var vector_box
	if inline_vectors:
		vector_box = HBoxContainer.new()
	else:
		vector_box = VBoxContainer.new()
		vector_box.rect_min_size.x = 120 * ConceptGraphEditorUtil.get_editor_scale()
		vector_box.rect_min_size.y = 24 * count * ConceptGraphEditorUtil.get_editor_scale()
	vector_box.name = "Vector"
	vector_box.add_constant_override("separation", 0)
	vbox.add_child(vector_box)

	var s
	for i in item_indexes.size():
		var vector_index = item_indexes[i]
		if opts.has(vector_index):
			s = _create_spinbox(vector_index, opts[vector_index], vector_box, idx)
		else:
			s = _create_spinbox(vector_index, opts, vector_box, idx)
		if inline_vectors:
			s.style = 3
		elif i == 0:
			s.style = 0
		elif i == item_indexes.size() - 1:
			s.style = 2
		else:
			s.style = 1

	var separator = VSeparator.new()
	separator.modulate = Color(0, 0, 0, 0)
	vbox.add_child(separator)

	return vbox


func _get_vector_value(idx: int):
	var left = _hboxes[idx].get_node("Left")
	var vbox = left.get_node("VectorContainer")
	if not left or not vbox:
		return null

	var vector_box = vbox.get_node("Vector")
	var count = vector_box.get_child_count()
	var res
	if count == 2:
		res = Vector2.ZERO
	else:
		res = Vector3.ZERO

	for i in count:
		res[i] = vector_box.get_child(i).value
	return res


func _set_vector_value(idx: int, value) -> void:
	if not value or idx >= _inputs.size():
		return

	var vbox = _hboxes[idx].get_node("Left").get_node("VectorContainer")
	if not vbox:
		return

	var vector

	if value is String:
		# String to Vector conversion
		value = value.substr(1, value.length() - 2)
		vector = value.split(',')
	elif value is Vector3 or value is Vector2:
		vector = value

	var vector_box = vbox.get_node("Vector")
	var count = vector_box.get_child_count()

	for i in count:
		vector_box.get_child(i).value = float(vector[i])


func _get_default_gui_value(idx: int, for_export := false):
	if _hboxes.size() <= idx:
		return null

	var left = _hboxes[idx].get_node("Left")
	if not left:
		return null

	match _inputs[idx]["type"]:
		ConceptGraphDataType.BOOLEAN:
			if left.has_node("CheckBox"):
				return left.get_node("CheckBox").pressed
		ConceptGraphDataType.SCALAR:
			if left.has_node("SpinBox"):
				return left.get_node("SpinBox").value
		ConceptGraphDataType.STRING:
			if left.has_node("LineEdit"):
				return left.get_node("LineEdit").text
			elif left.has_node("OptionButton"):
				var btn = left.get_node("OptionButton")
				if for_export:
					return btn.get_item_id(btn.selected)
				else:
					return btn.get_item_text(btn.selected)
		ConceptGraphDataType.VECTOR2:
			return _get_vector_value(idx)
		ConceptGraphDataType.VECTOR3:
			return _get_vector_value(idx)

	return null


"""
Forces the GraphNode to redraw its gui, mostly to fix outdated connections after a resize.
"""
func _redraw() -> void:
	if not resizable:
		emit_signal("resize_request", Vector2(rect_min_size.x, 0.0))
	if get_parent():
		get_parent().force_redraw()
	else:
		hide()
		show()


func _connect_signals() -> void:
	Signals.safe_connect(self, "close_request", self, "_on_close_request")
	Signals.safe_connect(self, "resize_request", self, "_on_resize_request")
	Signals.safe_connect(self, "connection_changed", self, "_on_connection_changed")
	Signals.safe_connect(_resize_timer, "timeout", self, "_on_resize_timeout")


"""
Shows a FileDialog window and write the selected file path to the given line edit.
"""
func _show_file_dialog(opts: Dictionary, line_edit: LineEdit) -> void:
	if not _file_dialog:
		_file_dialog = FileDialog.new()
		add_child(_file_dialog)

	_file_dialog.rect_min_size = Vector2(500, 500)
	_file_dialog.mode = opts["mode"] if opts.has("mode") else FileDialog.MODE_SAVE_FILE
	_file_dialog.resizable = true
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM

	if opts.has("filters"):
		var filters = PoolStringArray()
		for filter in opts["filters"]:
			filters.append(filter)
		_file_dialog.set_filters(filters)

	Signals.safe_connect(_file_dialog, "file_selected", self, "_on_file_selected", [line_edit])
	_file_dialog.popup_centered()


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


"""
Called from _show_file_dialog when confirming the selection
"""
func _on_file_selected(path, line_edit: LineEdit) -> void:
	line_edit.text = get_parent().get_relative_path(path)


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
		
		for ui in _hboxes[i].get_node("Left").get_children():
			# Hide the default GUI if something is connected
			ui.visible = !connected
			# Force the Name label and icon to always be visible
			if ui is Label or ui is CenterContainer:
				ui.visible = true

				# Special case for numbers and vectors. The icon should be 
				# hidden unless something is connected
				if type == ConceptGraphDataType.SCALAR \
					or type == ConceptGraphDataType.VECTOR2 \
					or type == ConceptGraphDataType.VECTOR3:
						ui.visible = connected

	_update_slots_types()
	_redraw()


func _on_default_gui_value_changed(value, slot: int) -> void:
	emit_signal("node_changed", self, true)
	emit_signal("input_changed", slot, value)
