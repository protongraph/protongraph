class_name GenericOutputComponent
extends GraphNodeUiComponent


var _row: HBoxContainer


func initialize(label_name: String, type: int, opts := SlotOptions.new()):
	super(label_name, type, opts)

	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGNMENT_END
	_row.mouse_filter = Control.MOUSE_FILTER_PASS
	_row.add_child(label)
	_row.add_child(icon_container)
	add_child(_row)
