class_name BooleanComponent
extends GenericInputComponent


var _checkbox: CheckBox


func create(label_name: String, type: int, opts: SlotOptions = null):
	super(label_name, type, opts)

	if not opts:
		opts = SlotOptions.new()

	_checkbox = CheckBox.new()
	_checkbox.focus_mode = Control.FOCUS_NONE
	_checkbox.name = "CheckBox"
	_checkbox.button_pressed = opts.get_default_value(false)
	add_ui(_checkbox)
	_checkbox.toggled.connect(_on_value_changed)


func get_value() -> bool:
	return _checkbox.button_pressed


func set_value(value: bool) -> void:
	_checkbox.button_pressed = value


func notify_connection_changed(connected: bool) -> void:
	_checkbox.visible = !connected


func _on_value_changed(val: bool) -> void:
	super(val)
