extends GraphNodeComponent
class_name VectorComponent


var _col: VBoxContainer
var _label_box: Container
var _vector_box: Container
var _count := 2


func create(label_name: String, type: int, opts := {}) -> void:
	.create(label_name, type, opts)

	_col = VBoxContainer.new()
	add_child(_col)

	_label_box = HBoxContainer.new()
	_label_box.add_child(icon_container)
	_label_box.add_child(label)

	_col.add_child(_label_box)

	var inline = Settings.get_setting(Settings.INLINE_VECTOR_FIELDS)

	if inline:
		_vector_box = HBoxContainer.new()
	else:
		_vector_box = VBoxContainer.new()
		_vector_box.rect_min_size.x = Constants.get_vector_width()
		_vector_box.size_flags_horizontal = Control.SIZE_EXPAND

	_vector_box.add_constant_override("separation", 0)
	_col.add_child(_vector_box)

	var item_indexes = ["x", "y"]
	if type == DataType.VECTOR3:
		item_indexes.push_back("z")
		_count = 3


	for i in item_indexes.size():
		var s: CustomSpinBox

		# Check if there's per attribute option when creating the spinboxes
		var vector_index = item_indexes[i]
		if opts.has(vector_index):
			s = ScalarComponent.create_spinbox(vector_index, opts[vector_index])
		else:
			s = ScalarComponent.create_spinbox(vector_index, opts)
		_vector_box.add_child(s)
		Signals.safe_connect(s, "value_changed", self, "_on_value_changed")

		if inline:
			s.set_style(3)
		elif i == 0:
			s.set_style(0)
		elif i == item_indexes.size() - 1:
			s.set_style(2)
		else:
			s.set_style(1)

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
	if not value:
		return

	var vector
	if value is Vector3 or value is Vector2 or value is Array:
		vector = value
	elif value is String:
		value = value.substr(1, value.length() - 2)
		vector = value.split(',')
	else:
		return

	for i in _count:
		var spinbox = _vector_box.get_child(i)
		spinbox.value = float(vector[i])


func notify_connection_changed(connected: bool) -> void:
	_vector_box.visible = !connected


func _on_value_changed(_val) -> void:
	emit_signal("value_changed", get_value())
