class_name GenericOutputComponent
extends GraphNodeUiComponent


var _row: HBoxContainer


func create(label_name: String, type: int, opts := {}):
	super(label_name, type, opts)

	label.align = Label.ALIGN_RIGHT
	
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGN_END
	_row.mouse_filter = Control.MOUSE_FILTER_PASS
	_row.add_child(label)
	_row.add_child(icon_container)
	add_child(_row)
