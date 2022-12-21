class_name GraphNodeUiComponent
extends MarginContainer


# A graph node component is a piece of UI displayed on the graphnode itself.
# There's usually two of them per row (one for the input, another one for the
# output).

signal value_changed


var label: Label
var icon: TextureRect
var icon_container: CenterContainer
var index # As defined in the ProtonNode
var slot: int # The actual GraphEdit slot


func initialize(label_name: String, type: int, opts := SlotOptions.new()):
	if not label:
		label = Label.new()

	if not opts:
		opts = SlotOptions.new()

	if not icon:
		icon = TextureRect.new()
		icon_container = CenterContainer.new()
		icon_container.add_child(icon)

	label.text = label_name
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.visible = opts.show_type_icon

	size_flags_horizontal = SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

	if type != -1:
		label.tooltip_text = DataType.get_type_name(type)
		icon.texture = TextureUtil.get_slot_icon(type)
		icon.modulate = DataType.COLORS[type]


func get_value():
	return null


func set_value(_val) -> void:
	pass


func notify_connection_changed(_connected: bool) -> void:
	pass


func _on_value_changed(value) -> void:
	value_changed.emit(value)
