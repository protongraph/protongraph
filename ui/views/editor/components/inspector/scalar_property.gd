extends HBoxContainer


signal value_changed


var spinbox


func init(name: String, value: float):
	spinbox = get_node("Spinbox")
	spinbox.set_label_text(name)
	spinbox.set_value_no_undo(value)
	spinbox.connect("value_changed", self, "_on_value_changed")


func set_value(value: float) -> void:
	spinbox.value = value


func get_value(_storage := false) -> float:
	return spinbox.value


func _on_value_changed(_value) -> void:
	emit_signal("value_changed")
