class_name InspectorProperty
extends Control


# A node property displayed on the node Sidebar.
# Each property matches a slot in the selected ProtonNode. It displays the name,
# current value (if applicable) and a visibility checkbox to control the
# slot visibility on the graphnode itself.


signal value_changed
signal property_visibility_changed
signal pinned


var _index
var _ui

@onready var _root: Control = $%Component
@onready var _visibility_box: CheckBox = $%VisibilityBox
@onready var _pin_button: Button = $%PinButton
@onready var _pin_options_container: Control = $%PinOptionsContainer
@onready var _pin_path_edit: LineEdit = $%PinPathEdit


func _ready() -> void:
	_visibility_box.toggled.connect(_on_visibility_box_toggled)
	_pin_button.toggled.connect(_on_pin_button_toggled)
	_pin_options_container.visible = false
	_pin_button.visible = false


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


func enable_pin() -> void:
	_pin_button.visible = true


func set_value(value) -> void:
	if _ui:
		_ui.set_value(value)


func set_property_visibility(v: bool) -> void:
	_visibility_box.set_pressed_no_signal(v)


func set_pinned(pinned: bool, pin_path: String) -> void:
	_pin_path_edit.set_text(pin_path)
	_pin_button.set_pressed(pinned)


func get_slot_index() -> Variant:
	return _index


func get_pin_path() -> String:
	return _pin_path_edit.get_text()


func _sanitize_name(p_name: String, type: int) -> String:
	if p_name != null and p_name != "":
		return p_name

	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)


func _on_value_changed(value) -> void:
	value_changed.emit(value, _index)


func _on_visibility_box_toggled(pressed: bool) -> void:
	property_visibility_changed.emit(pressed)


func _on_pin_button_toggled(pressed: bool) -> void:
	_pin_options_container.visible = pressed
	pinned.emit(pressed)
