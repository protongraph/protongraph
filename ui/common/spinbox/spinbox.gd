extends ProgressBar
class_name CustomSpinBox


@export var spinbox_name: String
@export var enforce_step: bool
@export_enum("Top", "Middle", "Bottom", "Single") var style = 3:
	set(val):
		style = val
		_update_style()

@onready var _name_label: Label = $HBoxContainer/Control/Label
@onready var _line_edit: LineEdit = $HBoxContainer/Control/LineEdit
@onready var _increase_button: Button = $HBoxContainer/Increase
@onready var _decrease_button: Button = $HBoxContainer/Decrease
@onready var _edit_popup: PopupPanel = $EditPopup


var _clicked := false
var _acc := 0.0
var _previous_value := 0.0
var _is_edited := false

var _bg = preload("styles/progress_bar_bg.tres")
var _bg_top = preload("styles/progress_bar_bg_top.tres")
var _bg_middle = preload("styles/progress_bar_bg_middle.tres")
var _bg_bottom = preload("styles/progress_bar_bg_bottom.tres")
var _fg = preload("styles/progress_bar_fg.tres")
var _fg_top = preload("styles/progress_bar_fg_top.tres")
var _fg_middle = preload("styles/progress_bar_fg_middle.tres")
var _fg_bottom = preload("styles/progress_bar_fg_bottom.tres")


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	value_changed.connect(_update_line_edit_value)

	# Connect the two < and > buttons clicks
	_increase_button.connect("pressed", _on_button_pressed, [true])
	_decrease_button.connect("pressed", _on_button_pressed, [false])

	# Listen to the line_edit changes to sync the progress bar value
	_line_edit.text_submitted.connect(_on_line_edit_changed)
	_line_edit.focus_exited.connect(_on_line_edit_changed)
	_line_edit.gui_input.connect(_on_value_gui_input)

	_edit_popup.edit_value.connect(_on_edit_value)
	_edit_popup.edit_value_started.connect(_on_edit_value_started)
	_edit_popup.edit_value_ended.connect(_on_edit_value_ended)

	set_label_text(spinbox_name)
	_update_line_edit_value(value)
	_update_style()


func get_line_edit() -> LineEdit:
	return _line_edit


func set_label_text(text) -> void:
	if text == null:
		return

	spinbox_name = text if text is String else String(text)
	if _name_label:
		_name_label.text = spinbox_name
		rect_min_size.x = spinbox_name.length() * 8 + 80
		rect_min_size.x *= EditorUtil.get_editor_scale()


func get_label_text() -> String:
	return _name_label.text


func set_value_no_undo(new_value) -> void:
	value = new_value


func _update_line_edit_value(value) -> void:
	_line_edit.text = str(value)


func _update_style() -> void:
	match style:
		0:
			add_theme_stylebox_override("bg", _bg_top)
			add_theme_stylebox_override("fg", _fg_top)
		1:
			add_theme_stylebox_override("bg", _bg_middle)
			add_theme_stylebox_override("fg", _fg_middle)
		2:
			add_theme_stylebox_override("bg", _bg_bottom)
			add_theme_stylebox_override("fg", _fg_bottom)
		3:
			add_theme_stylebox_override("bg", _bg)
			add_theme_stylebox_override("fg", _fg)


func _create_undo_redo_action(new, old) -> void:
	new = snapped(new, step)
	if new == old:
		return

	var ur: UndoRedo = GlobalUndoRedo.get_undo_redo()

	if not ur:
		value = new
		return

	ur.create_action("Change " + _name_label.text + " value")
	ur.add_do_property(self, "value", new)
	ur.add_undo_property(self, "value", old)
	ur.commit_action()


func _show_extra_controls() -> void:
	var pos := get_tree().get_root().position + Vector2i(get_global_transform().origin)
	pos.y -= _edit_popup.size.y / 2 - int(rect_size.y / 2)
	pos.x -= _edit_popup.size.x
	_edit_popup.position = pos
	_edit_popup.popup()


func _on_button_pressed(increase: bool) -> void:
	if increase:
		_create_undo_redo_action(value + step, value)
	else:
		_create_undo_redo_action(value - step, value)
	_update_line_edit_value(value)


func _on_line_edit_changed(text = "") -> void:
	# For initialisation purpose
	if text == "":
		text = _line_edit.text

	var new_value = value

	# If the text entered is a number
	if text.is_valid_float() or text.is_valid_int():
		new_value = text.to_float()

	else:	# Check if the text is an expression
		var expression := Expression.new()
		if expression.parse(text, []) != OK:
			return

		var result = expression.execute([], null, true)
		if not expression.has_execute_failed():
			new_value = result

	_create_undo_redo_action(new_value, value)
	if text != str(value):
		_line_edit.text = str(value)


func _on_value_gui_input(event) -> void:
	# Another edit box is being dragged, ignore all events
	if _is_edited:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_clicked = event.pressed
		_acc = 0.0
		if _clicked:
			_previous_value = value
		else:
			_create_undo_redo_action(value, _previous_value)

	elif event is InputEventMouseMotion and _clicked:
		if sign(_acc) != sign(event.relative.x):
			_acc = 0.0

		_acc += event.relative.x
		if abs(_acc) >= 5 * EditorUtil.get_editor_scale():
			value += sign(_acc) * step
			_acc = 0.0
		_line_edit.text = str(value)


# Called when the user starts dragging the extra control
func _on_edit_value_started() -> void:
	_is_edited = true
	_previous_value = value


# Called when the user stops dragging the extra control
func _on_edit_value_ended() -> void:
	if _is_edited:
		_is_edited = false
		_create_undo_redo_action(value, _previous_value)


# Called when the value is updated from the extra controls
func _on_edit_value(step: float) -> void:
	if not _is_edited: # + or - button was clicked
		_create_undo_redo_action(value + step, value)
	else:
		value += step


func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_show_extra_controls()
