class_name StringComponent
extends GenericInputComponent


var template_path: String

var _line_edit: LineEdit
var _dropdown: OptionButton
var _file_dialog: FileDialog
var _compact_display := false	# TODO: only show the file name in the unselected line_edit if this is true


func initialize(label_name: String, type: int, opts := SlotOptions.new()) -> void:
	super(label_name, type, opts)

	if opts.has_dropdown():
		_dropdown = OptionButton.new()
		add_ui(_dropdown)
		#_dropdown.add_stylebox_override("normal", load("res://ui/themes/styles/graphnode_button_normal.tres"))
		#_dropdown.add_stylebox_override("hover", load("res://ui/themes/styles/graphnode_button_hover.tres"))
		_dropdown.focus_mode = Control.FOCUS_NONE
		_dropdown.name = "OptionButton"
		for item in opts.dropdown_items:
			_dropdown.add_item(item.label, item.id)

		_dropdown.item_selected.connect(_on_value_changed)

	else:
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


func get_value():
	if _line_edit:
		return _line_edit.text

	if _dropdown:
		return _dropdown.get_item_text(_dropdown.selected)


func get_value_for_export():
	if _dropdown:
		return _dropdown.get_item_id(_dropdown.selected)

	return get_value()


func set_value(value) -> void:
	# Extra comparison needed because there's a feedback loop I don't know how
	# to fix when the node is updated from the sidebar, causing the cursor
	# to be put back at position 0 automatically.
	if _line_edit and _line_edit.text != value:
		_line_edit.text = value

	elif _dropdown:
		_dropdown.selected = _dropdown.get_item_index(int(value))


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
	if _dropdown:
		_dropdown.visible = !connected
	if _line_edit:
		_line_edit.visible = !connected
