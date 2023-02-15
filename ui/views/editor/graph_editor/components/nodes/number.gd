class_name ScalarComponent
extends GenericInputComponent


var _spinbox: CustomSpinBox


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	opts.expand = true
	_spinbox = UserInterfaceUtil.create_spinbox(label_name, opts)
	add_ui(_spinbox)
	_spinbox.value_changed.connect(_on_value_changed)


func get_value():
	return _spinbox.value


func set_value(value: float) -> void:
	_spinbox.set_value_no_undo(value)


func notify_connection_changed(connected: bool) -> void:
	label.visible = connected
	icon_container.visible = connected
	_spinbox.visible = !connected


func _on_value_changed(val) -> void:
	super(val)
