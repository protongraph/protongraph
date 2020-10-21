extends GenericInputComponent
class_name ScalarComponent


var _spinbox: CustomSpinBox


func create(label_name: String, type: int, opts := {}) -> void:
	.create(label_name, type, opts)
	_spinbox = create_spinbox(label_name, opts)
	add_ui(_spinbox)
	Signals.safe_connect(_spinbox, "value_changed", self, "_on_value_changed")


# Defined as static because it's also used in VectorComponent.
# TODO: Maybe find a cleaner way to do this.
static func create_spinbox(label_name: String, opts := {}) -> CustomSpinBox:
	var spinbox = preload("res://ui/views/editor/components/spinbox/spinbox.tscn").instance()
	spinbox.set_label_text(label_name)
	spinbox.name = "SpinBox"
	spinbox.max_value = opts["max"] if opts.has("max") else 1000
	spinbox.min_value = opts["min"] if opts.has("min") else 0
	spinbox.value = opts["value"] if opts.has("value") else 0
	spinbox.step = opts["step"] if opts.has("step") else 0.001
	spinbox.exp_edit = opts["exp"] if opts.has("exp") else false
	spinbox.allow_greater = opts["allow_greater"] if opts.has("allow_greater") else true
	spinbox.allow_lesser = opts["allow_lesser"] if opts.has("allow_lesser") else true
	spinbox.rounded = opts["rounded"] if opts.has("rounded") else false
	return spinbox


func get_value():
	return _spinbox.value


func set_value(value: float) -> void:
	_spinbox.set_value_no_undo(value)


func notify_connection_changed(connected: bool) -> void:
	label.visible = connected
	icon.visible = connected
	_spinbox.visible = !connected
