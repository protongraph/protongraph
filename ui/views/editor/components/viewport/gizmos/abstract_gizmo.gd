class_name AbstractGizmo
extends Node3D

signal gizmo_changed


@export var gizmo_scale := 1.0

var editable := false


func enable_for(_node) -> void:
	pass


func disable() -> void:
	pass
