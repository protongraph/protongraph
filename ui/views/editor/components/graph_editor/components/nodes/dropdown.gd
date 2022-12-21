class_name DropdownComponent
extends GenericInputComponent


var _dropdown: OptionButton


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	_dropdown = OptionButton.new()
	add_ui(_dropdown)
	_dropdown.focus_mode = Control.FOCUS_NONE
	_dropdown.name = "OptionButton"
	for item in opts.dropdown_items:
		_dropdown.add_item(item.label, item.id)

	_dropdown.item_selected.connect(_on_value_changed)


func get_value() -> int:
	return _dropdown.selected


func set_value(value: int) -> void:
	_dropdown.selected = _dropdown.get_item_index(value)


func _on_value_changed(val) -> void:
	super(val)


func notify_connection_changed(connected: bool) -> void:
	_dropdown.visible = !connected
