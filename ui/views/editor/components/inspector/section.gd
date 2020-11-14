extends VBoxContainer

export var root: NodePath
var _root: Control


func set_name(name: String) -> void:
	var label = get_node("SectionName")
	label.text = name


func add_control(control) -> void:
	if not _root:
		_root = get_node(root)

	_root.add_child(control)
