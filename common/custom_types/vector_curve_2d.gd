tool
extends Spatial
class_name VectorCurve2D


export var points: Array


func get_center() -> Vector2:
	var res := Vector2.ZERO
	for p in points:
		res += p
	res /= points.size()
	return res
