class_name UserInterfaceUtil
extends RefCounted


const SpinboxScene := preload("res://ui/common/spinbox/spinbox.tscn")


# Creates a default spinbox. Don't use CustomSpinBox.new() or it won't use the
# custom scene associated with this class. There's probably a better way though.
static func create_spinbox(label_name: String, opts := SlotOptions.new()) -> CustomSpinBox:
	var spinbox = SpinboxScene.instantiate()

	spinbox.set_label_text(label_name)
	if not opts.label_override.is_empty():
		spinbox.set_label_text(opts.label_override)

	spinbox.name = "SpinBox"
	spinbox.max_value = opts.max_value
	spinbox.min_value = opts.min_value
	spinbox.value = opts.get_default_value(0)
	spinbox.set_custom_step(opts.step)
	spinbox.exp_edit = opts.exp_edit
	spinbox.allow_greater = opts.allow_greater
	spinbox.allow_lesser = opts.allow_lesser
	spinbox.rounded = opts.rounded
	spinbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL if opts.expand else Control.SIZE_FILL
	return spinbox


static func create_component(name: String, type: int, opts: SlotOptions) -> GraphNodeUiComponent:
	var component: GraphNodeUiComponent
	match type:
		DataType.BOOLEAN:
			component = BooleanComponent.new()
		DataType.NUMBER:
			if opts.has_dropdown():
				component = DropdownComponent.new()
			else:
				component = ScalarComponent.new()
		DataType.STRING:
			component = StringComponent.new()
		DataType.VECTOR2, DataType.VECTOR3, DataType.VECTOR4:
			component = VectorComponent.new()
		DataType.CURVE_FUNC:
			component = CurveComponent.new()
		DataType.MISC:
			if opts.has_dropdown():
				component = DropdownComponent.new()

	if not component:
		component = GenericInputComponent.new()

	component.initialize(name, type, opts)

	return component


static func create_output_component(name: String, type: int, opts: SlotOptions) -> GenericOutputComponent:
	var component := GenericOutputComponent.new()
	component.initialize(name, type, opts)
	return component


# Some nested Godot popups have a panel with a style box override that doesn't
# fit with the rest of the theme, so we remove them here.
static func fix_popup_theme_recursive(node) -> void:
	for c in node.get_children(true):
		if c is Panel:
			c.remove_theme_stylebox_override("panel")

		fix_popup_theme_recursive(c)
