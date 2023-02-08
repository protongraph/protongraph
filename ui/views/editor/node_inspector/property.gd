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
var _can_be_pinned := true
var _ignore_updates := false

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
	_pin_path_edit.text_submitted.connect(_notify_pin_changes)
	_pin_path_edit.focus_exited.connect(_notify_pin_changes)


func create_input(p_name: String, type: int, value, idx, opts := SlotOptions.new()) -> void:
	p_name = _sanitize_name(p_name, type)
	_ui = UserInterfaceUtil.create_component(p_name, type, opts)
	_root.add_child(_ui)

	if value != null:
		_ui.set_value(value)

	_ui.notify_connection_changed(false)
	_index = idx
	_set_pin_capabilities(type)
	_ui.value_changed.connect(_on_value_changed)


func create_generic(p_name: String, type: int) -> void:
	p_name = _sanitize_name(p_name, type)
	var ui = GenericInputComponent.new()
	ui.initialize(p_name, type, null)
	_root.add_child(ui)
	_can_be_pinned = false


func set_value(value) -> void:
	if not _ui:
		return

	_ignore_updates = true
	_ui.set_value(value)
	_ignore_updates = false


func set_property_visibility(v: bool) -> void:
	_visibility_box.set_pressed_no_signal(v)


func set_pinned(enabled: bool, pin_path: String) -> void:
	if _can_be_pinned:
		_pin_button.visible = true
		_pin_path_edit.set_text(pin_path)
		_pin_button.set_pressed(enabled)


func get_slot_index() -> Variant:
	return _index


func get_pin_path() -> String:
	return _pin_path_edit.get_text()


func _sanitize_name(p_name: String, type: int) -> String:
	if p_name != null and p_name != "":
		return p_name

	# Empty name, often happens with outputs. Show the type name instead.
	return DataType.get_type_name(type)


func _set_pin_capabilities(type: int):
	var valid_types := [
		DataType.BOOLEAN,
		DataType.NUMBER,
		DataType.STRING,
		DataType.VECTOR2,
		DataType.VECTOR3,
		DataType.VECTOR4,
		DataType.CURVE_FUNC,
		DataType.MISC,
	]
	_can_be_pinned = type in valid_types


func _notify_pin_changes(_name := "") -> void:
	var pin_name = _pin_path_edit.get_text()
	if not pin_name.is_empty():
		pinned.emit(_pin_button.button_pressed, pin_name)


func _on_value_changed(value) -> void:
	if not _ignore_updates:
		value_changed.emit(value, _index)


func _on_visibility_box_toggled(pressed: bool) -> void:
	property_visibility_changed.emit(pressed)


func _on_pin_button_toggled(pressed: bool) -> void:
	_pin_options_container.visible = pressed
	_notify_pin_changes()

