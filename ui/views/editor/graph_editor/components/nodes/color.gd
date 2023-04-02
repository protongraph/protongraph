class_name ColorComponent
extends GenericInputComponent


var _color_picker: ColorPickerButton


func initialize(label_name: String, type: int, opts := SlotOptions.new()):
	super(label_name, type, opts)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_color_picker = ColorPickerButton.new()
	_color_picker.text = "Color"
	_color_picker.custom_minimum_size = Vector2(54, 24) * EditorUtil.get_editor_scale()
	_color_picker.color = opts.value if opts.value is Color else Color.WHITE

	add_ui(_color_picker)
	_color_picker.color_changed.connect(_on_value_changed)


func get_value() -> Color:
	return _color_picker.color


func set_value(value: Color) -> void:
	_color_picker.color = value


func notify_connection_changed(connected: bool) -> void:
	_color_picker.visible = !connected


func _on_value_changed(val: Color) -> void:
	super(val)
