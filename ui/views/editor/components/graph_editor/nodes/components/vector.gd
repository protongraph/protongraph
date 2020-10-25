extends GraphNodeComponent
class_name VectorComponent


var _col: VBoxContainer
var _label_box: Container
var _vector_box: Container
var _count := 2


func create(label_name: String, type: int, opts := {}) -> void:
	.create(label_name, type, opts)

	var _col = VBoxContainer.new()
	add_child(_col)
	
	_label_box = HBoxContainer.new()
	_label_box.add_child(icon_container)
	_label_box.add_child(label)

	_col.add_child(_label_box)
	
	var inline = Settings.get_setting(ConceptGraphSettings.INLINE_VECTOR_FIELDS)
	
	if inline:
		_vector_box = HBoxContainer.new()
	else:
		_vector_box = VBoxContainer.new()
		_vector_box.rect_min_size.x = Constants.get_vector_width()

	_vector_box.add_constant_override("separation", 0)
	_col.add_child(_vector_box)

	var item_indexes = ["x", "y"]
	if type == DataType.VECTOR3:
		item_indexes.append("z")
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

		if inline:
			s.style = 3
		elif i == 0:
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
		res[i] = _vector_box.get_child(i).value
	return res


func set_value(value) -> void:
	if not value:
		return

	var vector
	if value is Vector3 or value is Vector2:
		vector = value
	elif value is String:
		value = value.substr(1, value.length() - 2)
		vector = value.split(',')

	for i in _count:
		_vector_box.get_child(i).value = float(vector[i])


func notify_connection_changed(connected: bool) -> void:
	_vector_box.visible = !connected
