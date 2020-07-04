extends HBoxContainer


func init(name: String, value: float):
	var s = get_node("Spinbox")
	s.set_label_value(name)
	s.set_value_no_undo(value)


func set_value(value: float) -> void:
	var s = get_node("Spinbox")
	s.value = value
