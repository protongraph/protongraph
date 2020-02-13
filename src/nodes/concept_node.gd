"""
The base class for every nodes you can add in the Graph editor. It provides a basic UI framework
for nodes with simple parameters as well as a caching system and other utilities.
"""

tool
class_name ConceptNode
extends GraphNode


signal delete_node
signal node_changed
signal connection_changed

var concept_graph
var edit_mode := false

var _inputs := {}
var _outputs := {}
var _cache := {}
var _hboxes := []
var _resize_timer := Timer.new()


func _ready() -> void:
	_setup_slots()
	_generate_default_gui()

	_resize_timer.one_shot = true
	_resize_timer.autostart = false
	add_child(_resize_timer)

	_connect_signals()


func has_custom_gui() -> bool:
	return false


func get_node_name() -> String:
	return "ConceptNode"


func get_category() -> String:
	return "No category"


func get_description() -> String:
	return "A brief description of the node functionality"


func get_editor_input(name: String) -> Node: # Avoid cyclic references
	"""
	Query the parent ConceptGraph node in the editor and returns the corresponding input node if it
	exists
	"""
	if edit_mode:
		return null
	return get_parent().get_parent().get_input(name)  # TODO : Bad, replace this with something less error prone


func get_output(idx: int):
	"""
	Returns what the node generates for a give slot
	This method ensure the output is not calculated more than one time per run. It's useful if the
	output node is connected to more than one node. It ensure the results are the same and save
	some performance
	"""
	if _cache.has(idx):
		return _cache[idx]
	_cache[idx] = _generate_output(idx)
	return _cache[idx]


func clear_cache() -> void:
	# Empty the cache to force the node to recalculate its output next time get_output is called
	_clear_cache()
	_cache = {}


func reset() -> void:
	"""
	Clears the cache and the cache of every single nodes right to this one.
	"""
	clear_cache()
	for node in get_parent().get_all_right_nodes(self):
		node.reset()


func export_editor_data() -> Dictionary:
	var data = {}
	data["offset_x"] = offset.x
	data["offset_y"] = offset.y

	if resizable:
		data["rect_x"] = rect_size.x
		data["rect_y"] = rect_size.y

	data["slots"] = {}
	var slots = _hboxes.size()
	for i in range(0, slots):
		var hbox = _hboxes[i]
		for c in hbox.get_children():
			if c is CheckBox:
				data["slots"][i] = c.pressed
			if c is SpinBox:
				data["slots"][i] = c.value

	return data


func restore_editor_data(data: Dictionary) -> void:
	offset.x = data["offset_x"]
	offset.y = data["offset_y"]

	if data.has("rect_x"):
		rect_size.x = data["rect_x"]
	if data.has("rect_y"):
		rect_size.x = data["rect_y"]

	if has_custom_gui():
		return

	var slots = _hboxes.size()
	for i in range(0, slots):
		if data["slots"].has(String(i)):
			var type = _inputs[i]["type"]
			var value = data["slots"][String(i)]
			var hbox = _hboxes[i]
			match type:
				ConceptGraphDataType.BOOLEAN:
					hbox.get_node("CheckBox").pressed = value
				ConceptGraphDataType.SCALAR:
					hbox.get_node("SpinBox").value = value


func export_custom_data() -> Dictionary:
	"""
	Because we're saving the tree to a json file, we need each node to explicitely specify the data
	to save. It's also the node responsability to restore it when we load the file. Most nodes
	won't need this but it could be useful for nodes that allows the user to type in raw values
	directly if nothing is connected to a slot.
	"""
	return {}


func restore_custom_data(data: Dictionary) -> void:
	"""
	This method get exactly what it exported from the export_custom_data method. Use it to manually
	restore the previous node state.
	"""
	pass


func is_input_connected(idx: int) -> bool:
	return get_parent().is_node_connected_to_input(self, idx)


func get_input(idx: int, default = null):
	var input = get_parent().get_left_node(self, idx)
	if input.has("node"):
		return input["node"].get_output(input["slot"])

	if has_custom_gui():
		return default # No input source connected

	# If no source is connected, check if it's a base type with a value defined on the node itself
	match _inputs[idx]["type"]:
		ConceptGraphDataType.BOOLEAN:
			return _hboxes[idx].get_node("CheckBox").pressed
		ConceptGraphDataType.SCALAR:
			return _hboxes[idx].get_node("SpinBox").value

	return default # Not a base type and no source connected


func set_input(idx: int, name: String, type: int, opts: Dictionary = {}):
	_inputs[idx] = {
		"name": name,
		"type": type,
		"color": ConceptGraphDataType.COLORS[type],
		"options": opts
	}


func set_output(idx: int, name: String, type: int, opts: Dictionary = {}):
	_outputs[idx] = {
		"name": name,
		"type": type,
		"color": ConceptGraphDataType.COLORS[type],
		"options": opts
	}


func _setup_slots() -> void:
	"""
	Based on the previous calls to set_input and set_ouput, this method will call the
	GraphNode.set_slot method accordingly with the proper parameters. This makes it easier syntax
	wise on the child node side and make it more readable.
	"""
	var slots = max(_inputs.size(), _outputs.size())
	for i in range(0, slots):
		var has_input = false
		var input_type = 0
		var input_color = Color(0)
		var has_output = false
		var output_type = 0
		var output_color = Color(0)

		if _inputs.has(i):
			has_input = true
			input_type = _inputs[i]["type"]
			input_color = _inputs[i]["color"]
		if _outputs.has(i):
			has_output = true
			output_type = _outputs[i]["type"]
			output_color = _outputs[i]["color"]

		set_slot(i, has_input, input_type, input_color, has_output, output_type, output_color)


func _generate_default_gui() -> void:
	"""
	If the child node does not define a custom UI itself, this function will generate a default UI
	based on the parameters provided with set_input and set_ouput. Each slots will have a Label
	and their name attached.
	The input slots will have additional UI elements based on their type.
	Scalars input gets a spinbox that's hidden when something is connected to the slot.
	Values stored in the spinboxes are automatically exported and restored.
	"""
	if has_custom_gui():
		return

	title = get_node_name()
	resizable = false
	show_close = true
	size_flags_horizontal = SIZE_SHRINK_CENTER

	# TODO : Some refactoring would be nice
	var slots = max(_inputs.size(), _outputs.size())
	for i in range(0, slots):

		# Create a Hbox container per slot like this -> [LabelIn, (opt), LabelOut]
		var hbox = HBoxContainer.new()
		hbox.rect_min_size.y = 24

		# Hbox have at least two elements (In and Out label), or more for some base types
		# for example with additional spinboxes. All of them are stored in ui_elements
		var ui_elements = []

		# label_left holds the name of the input slot.
		var label_left = Label.new()
		ui_elements.append(label_left)

		# If this slot has an input
		if _inputs.has(i):
			label_left.text = _inputs[i]["name"]

			# Add the optional UI elements based on the data type.
			match _inputs[i]["type"]:
				ConceptGraphDataType.BOOLEAN:
					var opts = _inputs[i]["options"]
					var checkbox = CheckBox.new()
					checkbox.pressed = opts["value"] if opts.has("value") else false
					checkbox.connect("toggled", self, "_on_value_changed")
					ui_elements.append(checkbox)
				ConceptGraphDataType.SCALAR:
					var opts = _inputs[i]["options"]
					var spinbox = SpinBox.new()
					spinbox.max_value = opts["max"] if opts.has("max") else 1000
					spinbox.min_value = opts["min"] if opts.has("min") else 0
					spinbox.value = opts["value"] if opts.has("value") else 0
					spinbox.step = opts["step"] if opts.has("step") else 0.001
					spinbox.exp_edit = opts["exp"] if opts.has("exp") else true
					spinbox.allow_greater = opts["allow_greater"] if opts.has("allow_greater") else true
					spinbox.allow_lesser = opts["allow_lesser"] if opts.has("allow_lesser") else false
					spinbox.rounded = opts["rounded"] if opts.has("rounded") else false
					spinbox.connect("value_changed", self, "_on_value_changed")
					ui_elements.append(spinbox)
				#ConceptGraphDataType.VECTOR:
				#	var vector_input = ConceptNodeGuiVectorInput.new()
				#	vector_input.connect("value_changed", self, "_on_value_changed")
				#	ui_elements.append(vector_input)

		# Label right holds the output slot name. Set to expand and align_right to push the text on
		# the right side of the node panel
		var label_right = Label.new()
		label_right.size_flags_horizontal = SIZE_EXPAND_FILL
		label_right.align = Label.ALIGN_RIGHT
		if _outputs.has(i):
			label_right.text = _outputs[i]["name"]
		ui_elements.append(label_right)

		# Push all the ui elements in order in the Hbox container
		for ui in ui_elements:
			hbox.add_child(ui)

		# Make sure it appears in the editor and store along the other Hboxes
		add_child(hbox)
		_hboxes.append(hbox)


func _generate_output(idx: int):
	"""
	Overide this function in the derived classes to return something usable
	"""
	return null


func _clear_cache():
	"""
	Overide this function to customize how the output cache should be cleared. If you have memory
	to free or anything else, that's where you should define it.
	"""
	pass


func _connect_signals() -> void:
	connect("close_request", self, "_on_close_request")
	connect("resize_request", self, "_on_resize_request")
	connect("connection_changed", self, "_on_connection_changed")
	_resize_timer.connect("timeout", self, "_on_resize_timeout")


func _on_resize_request(new_size) -> void:
	rect_size = new_size
	_resize_timer.start(2.0)


func _on_resize_timeout() -> void:
	emit_signal("node_changed", self, false)


func _on_close_request() -> void:
	emit_signal("delete_node", self)


func _on_connection_changed() -> void:
	"""
	When the nodes connections changes, this method check for all the input slots and hide
	everything that's not a label if something is connected to the associated slot.
	"""
	var slots = _hboxes.size()
	for i in range(0, slots):
		var visible = !is_input_connected(i)
		for ui in _hboxes[i].get_children():
			if not ui is Label:
				ui.visible = visible


func _on_value_changed(_value: float) -> void:
	emit_signal("node_changed", self, true)
