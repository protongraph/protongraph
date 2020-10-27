extends HBoxContainer
class_name SidebarProperty


signal value_changed


var _slot_index: int
var _ui

onready var _root: Control = $Component


func create_input(name: String, type: int, value, idx: int) -> void:
	match type:
		DataType.BOOLEAN:
			_ui = preload("../inspector/bool_property.tscn").instance()
		DataType.SCALAR:
			_ui = preload("../inspector/scalar_property.tscn").instance()
		DataType.STRING:
			_ui = preload("../inspector/string_property.tscn").instance()
		DataType.VECTOR2:
			_ui = preload("../inspector/vector2_property.tscn").instance()
		DataType.VECTOR3:
			_ui = preload("../inspector/vector3_property.tscn").instance()
		_:
			create_generic(name, type)
			return
	
	_root.add_child(_ui)
	name = _sanitize_name(name, type)
	_ui.init(name, value)
	_slot_index = idx
	Signals.safe_connect(_ui, "value_changed", self, "_on_value_changed")


func create_generic(name: String, type: int) -> void:
	name = _sanitize_name(name, type)
	var label = Label.new()
	label.text = name
	_root.add_child(label)


func set_value(value) -> void:
	if _ui:
		_ui.set_value(value)


func get_index() -> int:
	return _slot_index


func _sanitize_name(name: String, type: int) -> String:
	if name != null and name != "":
		return name.capitalize()
	
	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)


func _on_value_changed() -> void:
	var value = _ui.get_value()
	emit_signal("value_changed", value, _slot_index)
