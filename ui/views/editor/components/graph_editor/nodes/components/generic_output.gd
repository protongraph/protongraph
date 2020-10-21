extends GraphNodeComponent
class_name GenericOutputComponent


var _row: HBoxContainer


func create(label_name: String, type: int, _opts := {}):
	.create(label_name, type)
	
	label.size_flags_horizontal = SIZE_FILL
	label.align = Label.ALIGN_RIGHT
	
	_row = HBoxContainer.new()
	_row.add_child(label)
	_row.add_child(icon)
	add_child(_row)
