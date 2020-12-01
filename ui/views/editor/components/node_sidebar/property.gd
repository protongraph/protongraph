extends HBoxContainer
class_name SidebarProperty


signal value_changed
signal property_visibility_changed


var _slot_index: int
var _ui

onready var _root: Control = $Component
onready var _button: Button = $VBoxContainer/VisibilityButton


func create_input(name: String, type: int, value, idx: int, opts := {}) -> void:
	match type:
		DataType.BOOLEAN:
			_ui = BooleanComponent.new()
		DataType.SCALAR:
			_ui = ScalarComponent.new()
		DataType.STRING:
			_ui = StringComponent.new()
		DataType.VECTOR2:
			_ui = VectorComponent.new()
		DataType.VECTOR3:
			_ui = VectorComponent.new()
		_:
			create_generic(name, type)
			return
	
	_root.add_child(_ui)
	name = _sanitize_name(name, type)
	_ui.create(name, type, opts)
	if value:
		_ui.set_value(value)
	_ui.notify_connection_changed(false)
	_slot_index = idx
	Signals.safe_connect(_ui, "value_changed", self, "_on_value_changed")


func create_generic(name: String, type: int) -> void:
	name = _sanitize_name(name, type)
	var ui = GenericInputComponent.new()
	ui.create(name, type, {})
	_root.add_child(ui)


func set_value(value) -> void:
	if _ui:
		_ui.set_value(value)


func get_index() -> int:
	return _slot_index


func set_property_visibility(hidden: bool) -> void:
	_button.pressed = !hidden
	_on_visibility_button_toggled(_button.pressed)


func _sanitize_name(name: String, type: int) -> String:
	if name != null and name != "":
		return name
	
	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)


func _on_value_changed(value) -> void:
	emit_signal("value_changed", value, _slot_index)


func _on_visibility_button_toggled(pressed: bool) -> void:
	emit_signal("property_visibility_changed", pressed)
