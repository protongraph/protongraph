class_name VectorComponent
extends GraphNodeUiComponent


var _col: VBoxContainer
var _label_box: Container
var _vector_box: Container
var _count := 2
var _link_button: Button
var _ignore_spinbox_updates := false


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_col = VBoxContainer.new()
	add_child(_col)

	_label_box = HBoxContainer.new()
	_label_box.add_child(icon_container)
	_label_box.add_child(label)

	_col.add_child(_label_box)

	_vector_box = VBoxContainer.new()
	_vector_box.custom_minimum_size.x = 120 #Constants.get_vector_width()
	_vector_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_vector_box.add_theme_constant_override("separation", 0)
	_col.add_child(_vector_box)

	var item_indexes = ["x", "y"]

	if type == DataType.VECTOR3:
		item_indexes.push_back("z")
		_count = 3

	elif type == DataType.VECTOR4:
		item_indexes.push_back("z")
		item_indexes.push_back("w")
		_count = 4

	for i in item_indexes.size():
		var s: CustomSpinBox

		# Create spinbox using per index vector options if available.
		var vector_index = item_indexes[i]
		s = UserInterfaceUtil.create_spinbox(vector_index, opts.get_vector_index_options(vector_index))

		_vector_box.add_child(s)
		s.value_changed.connect(_on_value_changed)

		if i == 0:
			s.style = 0
		elif i == item_indexes.size() - 1:
			s.style = 2
		else:
			s.style = 1

	var clear_button := Button.new()
	clear_button.icon = preload("res://ui/icons/icon_clear.svg")
	clear_button.expand_icon = true
	clear_button.custom_minimum_size = Vector2(30, 30)
	clear_button.pressed.connect(_on_clear_pressed)

	_link_button = clear_button.duplicate()
	_link_button.icon = preload("res://ui/icons/icon_link.svg")
	_link_button.toggle_mode = true

	var buttons_container := HBoxContainer.new()
	buttons_container.size_flags_horizontal = SIZE_EXPAND_FILL
	buttons_container.alignment = BoxContainer.ALIGNMENT_END
	buttons_container.add_child(clear_button)
	buttons_container.add_child(_link_button)
	_col.add_child(buttons_container)

	var separator = VSeparator.new()
	separator.modulate = Color(0, 0, 0, 0)
	_col.add_child(separator)


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
