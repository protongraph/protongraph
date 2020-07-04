extends HBoxContainer


func init(name: String, value: bool) -> void:
	var l = get_node("Label")
	var c = get_node("CheckBox")
	l.text = name
	c.pressed = value


func set_value(value: bool) -> void:
	get_node("CheckBox").pressed = value
