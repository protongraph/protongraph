extends MarginContainer
class_name GraphNodeComponent

# A graph node component is a piece of UI displayed on the graphnode itself.
# There's usually two of them per row (one for the input, another one for the
# output).

signal value_changed


var label: Label
var icon: TextureRect
var icon_container: CenterContainer
var index: int


func create(label_name: String, type: int, opts := {}):
	if not label:
		label = Label.new()

	if not icon:
		icon = TextureRect.new()
		icon_container = CenterContainer.new()
		icon_container.add_child(icon)

	label.text = label_name
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	icon.visible = opts["show_type_icon"] if opts.has("show_type_icon") else true
	
	size_flags_horizontal = SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	if type != -1:
		label.hint_tooltip = DataType.get_type_name(type)
		icon.texture = TextureUtil.get_slot_icon(type)
		icon.modulate = DataType.COLORS[type]


func get_value():
	return null


# If the data to store on disk is different than the one used in core.
func get_value_for_export():
	return get_value()


func set_value(_val) -> void:
	pass


func notify_connection_changed(_connected: bool) -> void:
	pass


func _on_value_changed(value) -> void:
	emit_signal("value_changed", value)
