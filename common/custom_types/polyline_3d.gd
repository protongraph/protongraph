class_name Polyline3D
extends Node3D


var points: Array[Vector3]
var up_axes: Array[Vector3]


func add_point(pos: Vector3, up := Vector3.ZERO) -> void:
	points.push_back(pos)
	up_axes.push_back(up)
