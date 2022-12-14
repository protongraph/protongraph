class_name InspectorProperty
extends HBoxContainer


# A node property displayed on the node Sidebar.
# Each property matches a slot in the selected ProtonNode. It displays the name,
# current value (if applicable) and a visibility checkbox to control the
# slot visibility on the graphnode itself.


signal value_changed
signal property_visibility_changed


var _index
var _ui

@onready var _root: Control = $Component
@onready var _visibility_box: CheckBox = $VisibilityBox


func _ready() -> void:
	_visibility_box.toggled.connect(_on_visibility_box_toggled)


func create_input(p_name: String, type: int, value, idx, opts := SlotOptions.new()) -> void:
	match type:
		DataType.BOOLEAN:
			_ui = BooleanComponent.new()
		DataType.NUMBER:
			_ui = ScalarComponent.new()
		DataType.STRING:
			_ui = StringComponent.new()
		DataType.VECTOR2:
			_ui = VectorComponent.new()
		DataType.VECTOR3:
			_ui = VectorComponent.new()
		_:
			create_generic(p_name, type)
			return

	_root.add_child(_ui)
	p_name = _sanitize_name(p_name, type)
	_ui.initialize(p_name, type, opts)

	if value != null:
		_ui.set_value(value)

	_ui.notify_connection_changed(false)
	_index = idx
	_ui.value_changed.connect(_on_value_changed)


func create_generic(p_name: String, type: int) -> void:
	p_name = _sanitize_name(p_name, type)
	var ui = GenericInputComponent.new()
	ui.initialize(p_name, type, null)
	_root.add_child(ui)


func set_value(value) -> void:
	if _ui:
		_ui.set_value(value)


func get_slot_index() -> Variant:
	return _index


func set_property_visibility(v: bool) -> void:
	_visibility_box.button_pressed = v
	_on_visibility_box_toggled(_visibility_box.button_pressed)


func _sanitize_name(p_name: String, type: int) -> String:
	if p_name != null and p_name != "":
		return p_name

	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)


func _on_value_changed(value) -> void:
	value_changed.emit(value, _index)


func _on_visibility_box_toggled(pressed: bool) -> void:
	property_visibility_changed.emit(pressed)
