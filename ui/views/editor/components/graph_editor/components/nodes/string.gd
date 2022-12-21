class_name StringComponent
extends GenericInputComponent


var template_path: String

var _line_edit: LineEdit
var _file_dialog: FileDialog
var _compact_display := false	# TODO: only show the file name in the unselected line_edit if this is true


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	_line_edit = LineEdit.new()
	add_ui(_line_edit)
	_line_edit.custom_minimum_size.x = 120
	_line_edit.size_flags_horizontal = SIZE_EXPAND_FILL
	_line_edit.name = "LineEdit"
	_line_edit.placeholder_text = opts.placeholder
	_line_edit.expand_to_text_length = opts.expand
	_line_edit.text = opts.value if opts.value is String else ""
	_compact_display = opts.compact_display
	_line_edit.text_changed.connect(_on_value_changed)

	if opts.dialog_options:
		var folder_button = Button.new()
		folder_button.icon = TextureUtil.get_texture("res://ui/icons/icon_folder.svg")
		folder_button.pressed.connect(_show_file_dialog.bind(opts.dialog_options))
		add_ui(folder_button)


func get_value() -> String:
	return _line_edit.text


func set_value(value: String) -> void:
	_line_edit.text = value


# Shows a FileDialog window and write the selected path to the line_edit.
func _show_file_dialog(opts: SlotOptions.DialogOptions) -> void:
	if not _file_dialog:
		_file_dialog = FileDialog.new()
		add_child(_file_dialog)

	_file_dialog.custom_minimum_size = Vector2(500, 500)
	_file_dialog.mode = opts.mode
	_file_dialog.resizable = true
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.set_filters(opts.filters)

	_file_dialog.file_selected.connect(_on_file_selected)
	_file_dialog.popup_centered()


# Called from _show_file_dialog when confirming the selection
func _on_file_selected(path) -> void:
	_line_edit.text = PathUtil.get_relative_path(path, template_path)


func _on_value_changed(val) -> void:
	super(val)


func notify_connection_changed(connected: bool) -> void:
	_line_edit.visible = !connected
