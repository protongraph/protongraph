class_name BooleanComponent
extends GenericInputComponent


var _checkbox: CheckBox


func create(label_name: String, type: int, opts := {}):
	super(label_name, type, opts)
	
	_checkbox = CheckBox.new()
	_checkbox.focus_mode = Control.FOCUS_NONE
	_checkbox.name = "CheckBox"
	_checkbox.pressed = opts["value"] if opts.has("value") else false
	add_ui(_checkbox)
	_checkbox.toggled.connect(_on_value_changed)


func get_value() -> bool:
	return _checkbox.pressed


func set_value(value: bool) -> void:
	_checkbox.pressed = value


func notify_connection_changed(connected: bool) -> void:
	_checkbox.visible = !connected


func _on_value_changed(val: bool) -> void:
	super(val)
