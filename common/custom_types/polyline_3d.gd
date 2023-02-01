class_name Polyline3D
extends Node3D


@export var points: PackedVector3Array
@export var up_axes: PackedVector3Array


func add_point(pos: Vector3, up := Vector3.ZERO) -> void:
	points.push_back(pos)
	up_axes.push_back(up)


func size() -> int:
	return points.size()
