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
	name = "VectorInput"


func get_value() -> Array:
	var result = []
	result.append(_x.value)
	result.append(_y.value)
	result.append(_z.value)
	return result


func set_value(val) -> void:
	if not val:
		return
	_x.value = val[0]
	_y.value = val[1]
	_z.value = val[2]


func _create_spinbox(name: String) -> SpinBox:
	var spinbox = SpinBox.new()
	spinbox.allow_greater = true
	spinbox.prefix = name
	spinbox.connect("value_changed", self, "_on_value_changed")
	add_child(spinbox)
	return spinbox


func _on_value_changed() -> void:
	emit_signal("value_changed")
