class_name UserInterfaceUtil
extends RefCounted


# Creates a default spinbox. Don't use CustomSpinBox.new() or it won't use the
# custom scene associated with this class. There's probably a better way though.
static func create_spinbox(label_name: String, opts := {}) -> CustomSpinBox:
	var spinbox = preload("res://ui/common/spinbox/spinbox.tscn").instantiate()
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
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL if opts.has("expand") else Control.SIZE_FILL
	return spinbox
