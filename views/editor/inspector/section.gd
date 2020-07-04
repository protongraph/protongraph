extends VBoxContainer


func set_name(name: String) -> void:
	var label = get_node("SectionName")
	label.text = name
