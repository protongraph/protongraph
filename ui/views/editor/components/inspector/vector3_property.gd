extends VBoxContainer


signal value_changed


var label: Label
var x_spinbox: CustomSpinBox
var y_spinbox: CustomSpinBox
var z_spinbox: CustomSpinBox


func init(name: String, value):
	label = get_node("Label")
	label.text = name

	x_spinbox = get_node("HBoxContainer/SpinBox")
	y_spinbox = get_node("HBoxContainer/SpinBox2")
	z_spinbox = get_node("HBoxContainer/SpinBox3")

	set_value(value)

	Signals.safe_connect(x_spinbox, "value_changed", self, "_on_value_changed")
	Signals.safe_connect(y_spinbox, "value_changed", self, "_on_value_changed")
	Signals.safe_connect(z_spinbox, "value_changed", self, "_on_value_changed")


func set_value(vec) -> void:
	if vec is Vector3:
		x_spinbox.value = vec.x
		y_spinbox.value = vec.y
		z_spinbox.value = vec.z

	elif vec is Array:
		x_spinbox.value = vec[0]
		y_spinbox.value = vec[1]
		z_spinbox.value = vec[2]


func get_value(_storage := false):
	var vec := Vector3.ZERO
	vec.x = x_spinbox.value
	vec.y = y_spinbox.value
	vec.z = z_spinbox.value

	if not _storage:
		return vec
	else:
		return [vec.x, vec.y, vec.z]


func _on_value_changed(_text) -> void:
	emit_signal("value_changed")
