class_name SettingsParameter
extends Node


signal value_changed(value)


@onready var _title: Label = $%TitleLabel
@onready var _description: Label = $%DescriptionLabel
@onready var _warning: Label = $%WarningLabel
@onready var _important_warning: Label = $%ImportantWarningLabel
@onready var _checkbox: CheckBox = $%CheckBox
@onready var _spinbox: SpinBox = $%SpinBox


func _ready():
	_description.visible = false
	_warning.visible = false
	_important_warning.visible = false
	_checkbox.visible = false
	_spinbox.visible = false

	_checkbox.toggled.connect(_on_value_changed)
	_spinbox.value_changed.connect(_on_value_changed)


func set_title(text: String) -> void:
	_title.text = text


func set_description(text: String) -> void:
	_description.text = text
	_description.visible = not text.is_empty()


func set_warning(text: String) -> void:
	_warning.text = text
	_warning.visible = not text.is_empty()


func set_important_warning(text: String) -> void:
	_important_warning.text = text
	_important_warning.visible = not text.is_empty()


func set_value(val) -> void:
	if val is bool:
		_checkbox.button_pressed = val

	else:
		_spinbox.set_value(val)


func get_value() -> Variant:
	if _checkbox.visible:
		return _checkbox.button_pressed

	if _spinbox.visible:
		return _spinbox.get_value()

	return null


func mark_as_bool() -> void:
	_checkbox.visible = true
	_spinbox.visible = false


func mark_as_float() -> void:
	_checkbox.visible = false
	_spinbox.visible = true


func _on_value_changed(val) -> void:
	value_changed.emit(val)
