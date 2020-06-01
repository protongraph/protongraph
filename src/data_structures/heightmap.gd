extends Object
class_name ConceptGraphHeightmap

var size: Vector2
var data: Array

func init(_size: Vector2) -> void:
	size = _size
	data = Array()
	data.resize(size.x * size.y)


func get_point(x: int, y: int) -> float:
	return data[y * size.y + x]

func set_point(x: int, y: int, height: float) -> void:
	data[y * size.y + x] = height


func get_index(i: int) -> float:
	return data[i]

func set_index(i: int, height: float) -> void:
	data[i] = height