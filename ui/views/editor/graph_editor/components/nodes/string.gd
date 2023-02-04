class_name StringComponent
extends GraphNodeUiComponent


var _line_edit: LineEdit
var _file_dialog: FileDialog

# TODO: only show the file name in the unselected line_edit if opts.compact_display is enabled


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	var col := VBoxContainer.new()
	add_child(col)

	var header_row := HBoxContainer.new()
	header_row.add_child(icon_container)
	header_row.add_child(label)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if opts.is_file:
		var folder_button = Button.new()
		folder_button.icon = TextureUtil.get_texture("res://ui/icons/icon_folder.svg")
		folder_button.pressed.connect(_show_file_dialog.bind(opts.file_mode, opts.file_filters))
		header_row.add_child(folder_button)

	col.add_child(header_row)

	_line_edit = LineEdit.new()
	_line_edit.custom_minimum_size.x = 40
	_line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_line_edit.name = "LineEdit"
	_line_edit.placeholder_text = opts.placeholder
	_line_edit.expand_to_text_length = opts.expand
	_line_edit.text = opts.value if opts.value is String else ""
	_line_edit.text_changed.connect(_on_value_changed)
	col.add_child(_line_edit)


func get_value() -> String:
	return _line_edit.text


func set_value(value: String) -> void:
	_line_edit.text = value


# Shows a FileDialog window and write the selected path to the line_edit.
func _show_file_dialog(mode, filters: PackedStringArray) -> void:
	if not _file_dialog:
		_file_dialog = FileDialog.new()
		add_child(_file_dialog)
		UserInterfaceUtil.fix_popup_theme_recursive(_file_dialog)

	_file_dialog.mode = mode
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.set_filters(filters)

	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.popup_centered(Vector2i(720, 600))


# Called from _show_file_dialog when confirming the selection
func _on_file_selected(path) -> void:
	_line_edit.text = path # PathUtil.get_relative_path(path, graph_path)
	_on_value_changed(path)


func _on_value_changed(val) -> void:
	super(val)


func notify_connection_changed(connected: bool) -> void:
	_line_edit.visible = !connected
