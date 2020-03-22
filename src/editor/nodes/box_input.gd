tool
class_name ConceptBoxInput
extends Spatial


signal input_changed
signal property_changed


export var size := Vector3.ONE setget set_size
export var auto_center := true setget set_auto_center
var center := Vector3.ZERO setget set_center


func _ready() -> void:
	add_user_signal('input_changed')


func _get_property_list() -> Array:
	if not auto_center:
		return [{"name": "Center", "type": TYPE_VECTOR3}]
	return []


func set_size(val: Vector3) -> void:
	size = val
	_on_box_changed()


func set_auto_center(val: bool) -> void:
	auto_center = val
	property_list_changed_notify()


func set_center(val: Vector3) -> void:
	center = val
	_on_box_changed()


func _on_box_changed() -> void:
	emit_signal("input_changed", self)
	emit_signal("property_changed")
