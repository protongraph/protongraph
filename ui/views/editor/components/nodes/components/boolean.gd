extends GenericInputComponent
class_name BooleanComponent


var _checkbox


func create(label_name: String, type: int, opts := {}):
	.create(label_name, type, opts)
	
	_checkbox = CheckBox.new()
	_checkbox.focus_mode = Control.FOCUS_NONE
	_checkbox.name = "CheckBox"
	_checkbox.pressed = opts["value"] if opts.has("value") else false
	_checkbox.connect("toggled", self, "_on_value_changed")
	add_ui(_checkbox)


func get_value() -> bool:
	return _checkbox.pressed


func set_value(value: bool) -> void:
	_checkbox.pressed = value


func notify_connection_changed(connected: bool) -> void:
	_checkbox.visible = !connected
