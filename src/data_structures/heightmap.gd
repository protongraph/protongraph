extends Object
class_name ConceptGraphHeightmap

export var size: Vector2
export var data: PoolRealArray

func init(_size: Vector2) -> void:
	size = _size
	data = PoolRealArray()
	data.resize(size.x * size.y)


func get_data(x: int, y: int) -> float:
	return data[y * size.y + x]
