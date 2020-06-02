tool
class_name ConceptBoxInput
extends Spatial


signal input_changed
signal property_changed


export var size := Vector3.ONE setget set_size
var auto_center := false setget set_auto_center # TODO: implement standard AABB behavior
export var center := Vector3.ZERO setget set_center


func _ready() -> void:
	add_user_signal('input_changed')
	set_notify_local_transform(true)


func _get_property_list() -> Array:
	#if not auto_center:
	#	return [{"name": "Center", "type": TYPE_VECTOR3}]
	return []


func _notification(type: int):
	if type == NOTIFICATION_TRANSFORM_CHANGED:
		_on_box_changed()


func is_inside(pos: Vector3) -> bool:
	var local = transform.xform_inv(pos)
	var aabb = AABB(global_transform.origin + center - (size / 2.0), size)
	return aabb.has_point(local)


func set_size(val: Vector3) -> void:
	size = val
	_on_box_changed()


func set_auto_center(val: bool) -> void:
	auto_center = val
	property_list_changed_notify()


func set_center(val: Vector3) -> void:
	center = val
	property_list_changed_notify()
	_on_box_changed()


func _on_box_changed() -> void:
	emit_signal("input_changed", self)	# That tell the ConceptGraph to rerun the simulation
	emit_signal("property_changed")
