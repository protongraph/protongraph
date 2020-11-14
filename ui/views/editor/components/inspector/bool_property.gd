extends HBoxContainer


signal value_changed


var label: Label
var checkbox: CheckBox


func init(name: String, value: bool) -> void:
	label = get_node("Label")
	checkbox = get_node("CheckBox")
	Signals.safe_connect(checkbox, "pressed", self, "_on_pressed")

	label.text = name
	checkbox.pressed = value


func set_value(value: bool) -> void:
	checkbox.pressed = value


func get_value(_storage := false) -> bool:
	return checkbox.pressed


func _on_pressed() -> void:
	emit_signal("value_changed")
