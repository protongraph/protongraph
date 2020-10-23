extends GraphNodeComponent
class_name GenericOutputComponent


var _row: HBoxContainer


func create(label_name: String, type: int, _opts := {}):
	.create(label_name, type)

	label.align = Label.ALIGN_RIGHT
	
	_row = HBoxContainer.new()
	_row.alignment = BoxContainer.ALIGN_END
	_row.add_child(label)
	_row.add_child(icon_container)
	add_child(_row)
