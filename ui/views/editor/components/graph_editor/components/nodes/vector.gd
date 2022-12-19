class_name VectorComponent
extends GraphNodeUiComponent


var _col: VBoxContainer
var _label_box: Container
var _vector_box: Container
var _count := 2


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

	var separator = VSeparator.new()
	separator.modulate = Color(0, 0, 0, 0)
	_col.add_child(separator)


func get_value():
	var res
	if _count == 2:
		res = Vector2.ZERO
	else:
		res = Vector3.ZERO

	for i in _count:
		var spinbox: CustomSpinBox = _vector_box.get_child(i)
		res[i] = spinbox.value
	return res


func set_value(value) -> void:
	var valid_value := false
	var vector

	if value is Vector3 or value is Vector2:
		vector = value
		valid_value = true

	elif value is String:
		value = value.substr(1, value.length() - 2)
		vector = value.split(',')
		valid_value = (vector.size() == _count)

	if not valid_value:
		return

	for i in _count:
		var spinbox = _vector_box.get_child(i)
		spinbox.value = float(vector[i])


func notify_connection_changed(connected: bool) -> void:
	_vector_box.visible = !connected


func _on_value_changed(_val) -> void:
	super(get_value())
