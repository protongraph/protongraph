class_name Polyline3D
extends Node3D


@export var points: PackedVector3Array
@export var up_axes: PackedVector3Array


func add_point(pos: Vector3, up := Vector3.ZERO, index: int = -1) -> void:
	if points.size() != up_axes.size():
		up_axes.resize(points.size())

	if index == -1:
		points.push_back(pos)
		up_axes.push_back(up)
	else:
		points.insert(index, pos)
		up_axes.insert(index, up)


func size() -> int:
	return points.size()
