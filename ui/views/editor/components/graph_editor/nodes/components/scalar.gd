extends GenericInputComponent
class_name ScalarComponent


var _spinbox: CustomSpinBox


func create(label_name: String, type: int, opts := {}) -> void:
	.create(label_name, type, opts)

	_spinbox = preload("res://ui/views/editor/components/spinbox/spinbox.tscn").instance()
	
	_spinbox.set_label_text(label_name)
	_spinbox.name = "SpinBox"
	_spinbox.max_value = opts["max"] if opts.has("max") else 1000
	_spinbox.min_value = opts["min"] if opts.has("min") else 0
	_spinbox.value = opts["value"] if opts.has("value") else 0
	_spinbox.step = opts["step"] if opts.has("step") else 0.001
	_spinbox.exp_edit = opts["exp"] if opts.has("exp") else false
	_spinbox.allow_greater = opts["allow_greater"] if opts.has("allow_greater") else true
	_spinbox.allow_lesser = opts["allow_lesser"] if opts.has("allow_lesser") else true
	_spinbox.rounded = opts["rounded"] if opts.has("rounded") else false

	Signals.safe_connect(_spinbox, "value_changed", self, "_on_value_changed")


func get_value():
	return _spinbox.value


func set_value(value: float) -> void:
	_spinbox.set_value_no_undo(value)


func _on_value_changed(value: float) -> void:
	emit_signal("value_changed", value)
