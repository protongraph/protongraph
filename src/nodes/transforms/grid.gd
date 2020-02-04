tool
extends ConceptNode

class_name ConceptNodeTransformGrid

"""
Generates a list of transforms aligned to a grid in a 3D volume
"""



var _x: SpinBox
var _y: SpinBox
var _z: SpinBox


func _ready() -> void:
	# x, output
	set_slot(0,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE,
		true, ConceptGraphDataType.TRANSFORM_ARRAY, ConceptGraphColor.TRANSFORM_ARRAY)
	_x = get_node("x/SpinBox")

	# y
	set_slot(1,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE,
		false, 0, Color(0))
	_y = get_node("y/SpinBox")

	# z
	set_slot(2,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE,
		false, 0, Color(0))
	_z = get_node("z/SpinBox")

	connect("connection_changed", self, "_on_connection_changed")
	_on_connection_changed()


func get_node_name() -> String:
	return "Transform Grid"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Generates a list of transforms aligned to a grid in a 3D volume"


func has_custom_gui() -> bool:
	return true


func export_custom_data() -> Dictionary:
	var data := {}
	var size = _get_dimensions()
	data["x"] = size.x
	data["y"] = size.y
	data["z"] = size.z
	return data


func restore_custom_data(data: Dictionary) -> void:
	_x.get_line_edit().text = String(data["x"])
	_x.apply()
	_y.get_line_edit().text = String(data["y"])
	_y.apply()
	_z.get_line_edit().text = String(data["z"])
	_z.apply()


func _generate_output(idx: int) -> Array:
	var transforms = []
	var size = _get_dimensions()

	for i in range(0, size.x):
		for j in range(0, size.y):
			for k in range(0, size.z):
				var t = Transform()
				t.origin = Vector3(i, j, k)
				transforms.append(t)
	return transforms


func _get_dimensions() -> Vector3:
	var size := Vector3.ZERO

	var input_x = get_input(0)
	var input_y = get_input(1)
	var input_z = get_input(2)

	size.x = input_x if input_x else int(_x.get_line_edit().text)
	size.y = input_y if input_y else int(_y.get_line_edit().text)
	size.z = input_z if input_z else int(_z.get_line_edit().text)

	return size


func _on_value_changed(_value: float) -> void:
	emit_signal("node_changed", self, true)


func _on_connection_changed() -> void:
	"""
	When the nodes connections changes, this method check for all the input slots and hide the
	associated spinbox if something is connected.
	"""
	_x.visible = !is_input_connected(0)
	_y.visible = !is_input_connected(1)
	_z.visible = !is_input_connected(2)
