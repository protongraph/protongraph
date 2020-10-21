extends GraphNodeComponent
class_name GenericInputComponent


var _hbox: HBoxContainer


func create(label_name: String, type: int, _opts := {}):
	.create(label_name, type)

	_hbox = HBoxContainer.new()
	_hbox.add_child(_icon)
	_hbox.add_child(_label)
	add_child(_hbox)
