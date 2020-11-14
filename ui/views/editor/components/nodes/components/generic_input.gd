extends GraphNodeComponent
class_name GenericInputComponent


var _row: HBoxContainer


func create(label_name: String, type: int, opts := {}):
	.create(label_name, type, opts)

	_row = HBoxContainer.new()
	_row.mouse_filter = Control.MOUSE_FILTER_PASS
	_row.add_child(icon_container)
	_row.add_child(label)
	add_child(_row)


func add_ui(ui) -> void:
	_row.add_child(ui)
