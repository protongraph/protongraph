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
	_x = _create_spin_box()

	# y
	set_slot(1,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE,
		false, 0, Color(0))
	_y = _create_spin_box()

	# z
	set_slot(2,
		true, ConceptGraphDataType.NUMBER_SINGLE, ConceptGraphColor.NUMBER_SINGLE,
		false, 0, Color(0))
	_z = _create_spin_box()


func get_node_name() -> String:
	return "Transform Grid"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Generates a list of transforms aligned to a grid in a 3D volume"


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


func _create_spin_box() -> SpinBox:
	var box = SpinBox.new()
	box.allow_greater = true
	add_child(box)
	return box


func _get_dimensions() -> Vector3:
	var size := Vector3.ZERO
	size.x = int(_x.get_line_edit().text)
	size.y = int(_y.get_line_edit().text)
	size.z = int(_z.get_line_edit().text)
	return size
