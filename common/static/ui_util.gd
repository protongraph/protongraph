class_name UserInterfaceUtil
extends RefCounted

const SpinboxScene := preload("res://ui/common/spinbox/spinbox.tscn")

# Creates a default spinbox. Don't use CustomSpinBox.new() or it won't use the
# custom scene associated with this class. There's probably a better way though.
static func create_spinbox(label_name: String, opts: SlotOptions = null) -> CustomSpinBox:
	if not opts:
		opts = SlotOptions.new()

	var spinbox = SpinboxScene.instantiate()

	spinbox.set_label_text(label_name)
	spinbox.name = "SpinBox"
	spinbox.max_value = opts.max_value
	spinbox.min_value = opts.min_value
	spinbox.value = opts.get_default_value(0)
	spinbox.step = opts.step
	spinbox.exp_edit = opts.exp_edit
	spinbox.allow_greater = opts.allow_greater
	spinbox.allow_lesser = opts.allow_lesser
	spinbox.rounded = opts.rounded
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL if opts.expand else Control.SIZE_FILL
	return spinbox
