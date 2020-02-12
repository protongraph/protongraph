tool
class_name ConceptNodeGuiVectorInput
extends HBoxContainer


signal value_changed

var _x: SpinBox
var _y: SpinBox
var _z: SpinBox


func _ready() -> void:
	_x = _create_spinbox("x")
	_y = _create_spinbox("y")
	_z = _create_spinbox("z")
	set_spinbox_options()	# Set default values for spinboxes
	name = "VectorInput"


func get_value() -> Array:
	var result = []
	result.append(_x.value)
	result.append(_y.value)
	result.append(_z.value)
	return result


func get_vector() -> Vector3:
	var val = get_value()
	return Vector3(val[0], val[1], val[2])


func set_value(val) -> void:
	if not val:
		return
	_x.value = val[0]
	_y.value = val[1]
	_z.value = val[2]


func set_from_vector(val: Vector3) -> void:
	if not val:
		return
	_x.value = val.x
	_y.value = val.y
	_z.value = val.z


func set_spinbox_options(opts: Dictionary = {}) -> void:
	for s in get_children():	# TODO : this is duplicated from concept node, fix
		s.max_value = opts["max"] if opts.has("max") else 1000
		s.min_value = opts["min"] if opts.has("min") else 0
		s.value = opts["value"] if opts.has("value") else 0
		s.step = opts["step"] if opts.has("step") else 0.001
		s.exp_edit = opts["exp"] if opts.has("exp") else true
		s.allow_greater = opts["allow_greater"] if opts.has("allow_greater") else true
		s.rounded = opts["rounded"] if opts.has("rounded") else false


func _create_spinbox(name: String) -> SpinBox:
	var spinbox = SpinBox.new()
	spinbox.connect("value_changed", self, "_on_value_changed")
	add_child(spinbox)
	return spinbox


func _on_value_changed(val) -> void:
	emit_signal("value_changed")
