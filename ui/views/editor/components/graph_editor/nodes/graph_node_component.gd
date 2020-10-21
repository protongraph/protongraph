extends MarginContainer
class_name GraphNodeComponent

# A graph node component is a piece of UI displayed on the graphnode itself.
# There's usually two of them per row (one for the input, another one for the
# output).

signal value_changed


var _label: Label
var _icon: TextureRect


func create(label_name: String, type: int, opts := {}):
	if not _label:
		_label = Label.new()
	if not _icon:
		_icon = TextureRect.new()
	if opts.has("show_type_icon") and not opts["show_type_icon"]:
		_icon.visible = false
	
	_label.text = label_name
	_label.hint_tooltip = ConceptGraphDataType.Types.keys()[type].capitalize()
	_icon.texture = TextureUtil.get_slot_icon(type)
	_icon.modulate = ConceptGraphDataType.COLORS[type]
	_icon.mouse_filter = Control.MOUSE_FILTER_PASS


func get_value():
	return null


func set_value(_val) -> void:
	pass
