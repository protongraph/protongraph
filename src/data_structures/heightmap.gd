tool
class_name ConceptGraphHeightmap
extends Object


var size := Vector2(64, 64)
var mesh_size := Vector2(64, 64)
var height_scale := 0.0
var height_offset := 0.0
var data: Array
var transform: Transform


func init(_size: Vector2, _mesh_size: Vector2, _height_scale: float, _height_offset: float) -> void:
	size = _size + Vector2(1, 1)
	mesh_size = _mesh_size + Vector2(1, 1)
	height_scale = _height_scale
	height_offset = _height_offset
	data = Array()
	data.resize(size.x * size.y)
	transform = Transform()


func duplicate(_opts):
	# Don't use ConceptGraphHeightmap.new() here because it causes a cyclic dependency
	var res = get_script().new()
	res.size = size
	res.data = data.duplicate()
	res.transform = Transform(transform)
	res.mesh_size = mesh_size
	res.height_scale = height_scale
	res.height_offset = height_offset
	return res


func get_point_global(x: int, y: int, ignore_y_axis: bool = false) -> Vector3:
	var pos = Vector3.ZERO
	var ratio_x = (mesh_size.x - 1) / (size.x - 1)
	var ratio_y = (mesh_size.y - 1) / (size.y - 1)

	pos.x = x * ratio_x
	pos.z = y * ratio_y

	pos.y = 0.0
	if not ignore_y_axis:
		pos.y = data[y * size.y + x] * height_scale + height_offset

	pos += transform.origin

	return pos


func get_point(x: int, y: int) -> float:
	return data[y * size.y + x]


func set_point(x: int, y: int, height: float) -> void:
	data[y * size.y + x] = height


func get_index(i: int) -> float:
	return data[i]


func set_index(i: int, height: float) -> void:
	data[i] = height
