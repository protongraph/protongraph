extends HBoxContainer


var spinbox


func init(name: String, value: float):
	spinbox = get_node("Spinbox")
	spinbox.set_label_value(name)
	spinbox.set_value_no_undo(value)


func set_value(value: float) -> void:
	spinbox.value = value


func get_value() -> float:
	return spinbox.value
