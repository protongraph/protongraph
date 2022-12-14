class_name GenericInputComponent
extends GraphNodeUiComponent


var _row: HBoxContainer


func initialize(label_name: String, type: int, opts := SlotOptions.new()):
	super(label_name, type, opts)

	_row = HBoxContainer.new()
	_row.mouse_filter = Control.MOUSE_FILTER_PASS
	_row.add_child(icon_container)
	_row.add_child(label)
	add_child(_row)


func add_ui(ui) -> void:
	_row.add_child(ui)
