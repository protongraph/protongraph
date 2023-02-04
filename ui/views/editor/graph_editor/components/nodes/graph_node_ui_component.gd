class_name GraphNodeUiComponent
extends MarginContainer


# A graph node component is a piece of UI displayed on the graphnode itself.
# There's usually two of them per row (one for the input, another one for the
# output).

signal value_changed


var label: Label
var icon: TextureRect
var icon_container: CenterContainer
var ignored_overlay: TextureRect
var index # As defined in the ProtonNode
var slot: int # The GraphEdit slot (actual control row)
var port: int # The GraphEdit port (consecutive enabled slots)


func initialize(label_name: String, type: int, opts := SlotOptions.new()):
	if not label:
		label = Label.new()

	if not opts:
		opts = SlotOptions.new()

	if not icon:
		icon = TextureRect.new()
		icon_container = CenterContainer.new()
		icon_container.add_child(icon)

	if not ignored_overlay:
		ignored_overlay = TextureRect.new()
		ignored_overlay.texture = TextureUtil.get_texture("res://ui/icons/stripes.png")
		ignored_overlay.stretch_mode = TextureRect.STRETCH_TILE
		ignored_overlay.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ignored_overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
		ignored_overlay.modulate = Color(Color.WHITE, 0.20)
		ignored_overlay.visible = opts.ignored
		add_child(ignored_overlay)

	label.text = label_name
	icon.visible = opts.show_type_icon

	size_flags_horizontal = SIZE_EXPAND_FILL

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
