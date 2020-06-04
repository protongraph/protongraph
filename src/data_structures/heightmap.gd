extends Object
class_name ConceptGraphHeightmap


var size: Vector2
var data: Array
var transform: Transform
var mesh_size := Vector2(50, 50)


func init(_size: Vector2) -> void:
	size = _size
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
	return res


func to_global_space(x: int, y: int, ignore_y: bool = true) -> Vector3:
	var pos = Vector3.ZERO
	var ratio = mesh_size.x / size.x

	pos.x = x * ratio
	pos.y = 0.0
	if not ignore_y:
		pos.y = data[y * size.y + x]
	pos.z = y * ratio
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
