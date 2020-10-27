extends HBoxContainer
class_name SidebarProperty


onready var _root: Control = $Component


func create_input(name: String, type: int, value) -> void:
	var ui
	match type:
		DataType.BOOLEAN:
			ui = preload("../inspector/bool_property.tscn").instance()
		DataType.SCALAR:
			ui = preload("../inspector/scalar_property.tscn").instance()
		DataType.STRING:
			ui = preload("../inspector/string_property.tscn").instance()
		DataType.VECTOR2:
			ui = preload("../inspector/vector2_property.tscn").instance()
		DataType.VECTOR3:
			ui = preload("../inspector/vector3_property.tscn").instance()
		_:
			create_generic(name, type)
			return
	
	_root.add_child(ui)
	name = _sanitize_name(name, type)
	ui.init(name, value)


func create_generic(name: String, type: int) -> void:
	name = _sanitize_name(name, type)
	var label = Label.new()
	label.text = name
	_root.add_child(label)


func _sanitize_name(name: String, type: int) -> String:
	if name != null and name != "":
		return name
	
	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)
	
