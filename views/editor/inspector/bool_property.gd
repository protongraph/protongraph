extends HBoxContainer


var checkbox: CheckBox


func init(name: String, value: bool) -> void:
	var label = get_node("Label")
	checkbox = get_node("CheckBox")
	label.text = name
	checkbox.pressed = value


func set_value(value: bool) -> void:
	checkbox.pressed = value


func get_value() -> bool:
	return checkbox.pressed
