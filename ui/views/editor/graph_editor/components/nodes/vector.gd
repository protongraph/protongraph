class_name VectorComponent
extends GraphNodeUiComponent


var _col: VBoxContainer
var _header_box: Container
var _vector_box: Container
var _count := 2
var _link_button: Button
var _ignore_spinbox_updates := false


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	# Create the main Vbox containing everything
	_col = VBoxContainer.new()
	add_child(_col)

	# Adjust container sizing to use all the horizontal space
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Setup the header like this: [icon | label | clear | link]
	_header_box = HBoxContainer.new()
	_header_box.add_child(icon_container)
	_header_box.add_child(label)

	var clear_button := Button.new()
	clear_button.icon = preload("res://ui/icons/icon_clear.svg")
	clear_button.expand_icon = true
	clear_button.custom_minimum_size = Vector2(30, 30)
	clear_button.pressed.connect(_on_clear_pressed)

	_link_button = clear_button.duplicate()
	_link_button.icon = preload("res://ui/icons/icon_link.svg")
	_link_button.toggle_mode = true

	_header_box.add_child(clear_button)
	_header_box.add_child(_link_button)

	_col.add_child(_header_box)

	# Create the spinboxes

	var item_indexes = ["x", "y"]

	if type == DataType.VECTOR3:
		item_indexes.push_back("z")
		_count = 3

	elif type == DataType.VECTOR4:
		item_indexes.push_back("z")
		item_indexes.push_back("w")
		_count = 4

	# Vector box holds between 2 and 4 spinbox (one for each vector component)
	if opts.force_vertical:
		_vector_box = VBoxContainer.new()
	else:
		_vector_box = HBoxContainer.new()
		_vector_box.custom_minimum_size.x = 120 #Constants.get_vector_width()

	_vector_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_vector_box.add_theme_constant_override("separation", 2)
	_col.add_child(_vector_box)

	for i in item_indexes.size():
		var s: CustomSpinBox

		# Create spinbox using per index vector options if available.
		var vector_index = item_indexes[i]
		var opts_copy = opts.get_vector_options(vector_index).get_copy()

		# Convert the option default value from Vector to float type if needed
		if VectorUtil.is_vector(opts.value):
			opts_copy.value = opts.value[vector_index]

		s = UserInterfaceUtil.create_spinbox(vector_index, opts_copy)

		_vector_box.add_child(s)
		s.value_changed.connect(_on_value_changed)

		if i == 0:
			s.style = 0
		elif i == item_indexes.size() - 1:
			s.style = 2
		else:
			s.style = 1



func get_value():
	var res
	match _count:
		2:
			res = Vector2.ZERO
		3:
			res = Vector3.ZERO
		4:
			res = Vector4.ZERO

	for i in _count:
		var spinbox: CustomSpinBox = _vector_box.get_child(i)
		res[i] = spinbox.value

	return res


func set_value(value) -> void:
	var valid_value := false
	var vector

	if value is String: # TODO: Check is this is still used
		value = value.substr(1, value.length() - 2)
		vector = value.split(',')
		valid_value = (vector.size() == _count)

	if value is Vector2 or value is Vector3 or value is Vector4:
		vector = value
		valid_value = true

	if not valid_value:
		return

	_ignore_spinbox_updates = true

	for i in _count:
		var spinbox = _vector_box.get_child(i)
		spinbox.value = float(vector[i])

	_ignore_spinbox_updates = false


func notify_connection_changed(connected: bool) -> void:
	_vector_box.visible = !connected


func _on_value_changed(val: float) -> void:
	if _ignore_spinbox_updates:
		return # Prevents infinite loop when the link button is active

	if _link_button.button_pressed:
		_ignore_spinbox_updates = true

		for i in _count:
			var spinbox = _vector_box.get_child(i)
			spinbox.value = val

		_ignore_spinbox_updates = false

	super(get_value())


func _on_clear_pressed() -> void:
	var default
	match _count:
		2:
			default = Vector2.ZERO
		3:
			default = Vector3.ZERO
		4:
			default = Vector4.ZERO

	set_value(default)
	_on_value_changed(0.0)
