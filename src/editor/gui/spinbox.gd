tool
extends ProgressBar


export var decrease_button: NodePath
export var increase_button: NodePath
export var name_label: NodePath
export var value_edit: NodePath
export(int, "Top", "Middle", "Bottom", "Single") var style = 3 setget set_style


var _increase_btn: Button
var _decrease_btn: Button
var _name_label: Label
var _line_edit: LineEdit
var _name

var _bg = preload("styles/progress_bar_bg.tres")
var _bg_top = preload("styles/progress_bar_bg_top.tres")
var _bg_middle = preload("styles/progress_bar_bg_middle.tres")
var _bg_bottom = preload("styles/progress_bar_bg_bottom.tres")
var _fg = preload("styles/progress_bar_fg.tres")
var _fg_top = preload("styles/progress_bar_fg_top.tres")
var _fg_middle = preload("styles/progress_bar_fg_middle.tres")
var _fg_bottom = preload("styles/progress_bar_fg_bottom.tres")


func _ready() -> void:
	_increase_btn = get_node(increase_button)
	_decrease_btn = get_node(decrease_button)
	_name_label = get_node(name_label)
	_line_edit = get_node(value_edit)

	_increase_btn.connect("pressed", self, "_on_button_pressed", [true])
	_decrease_btn.connect("pressed", self, "_on_button_pressed", [false])
	connect("value_changed", self, "_update_line_edit_value")
	_line_edit.connect("text_entered", self, "_on_line_edit_changed")
	_line_edit.connect("focus_exited", self, "_on_line_edit_changed")

	set_label_value(_name)
	_update_line_edit_value(value)
	_update_style()


func get_recommended_x() -> float:
	if _name_label:
		return _name_label.rect_size.x + 50
	return 0.0


func get_line_edit() -> LineEdit:
	return _line_edit


func set_label_value(text) -> void:
	_name = text
	if _name_label:
		_name_label.text = String(text).capitalize()
		_update_ui_size()


func set_style(val) -> void:
	style = val
	_update_style()


func _update_line_edit_value(value) -> void:
	_line_edit.text = String(value)


func _update_ui_size() -> void:
	rect_min_size = get_child(0).rect_size
	update()


func _update_style() -> void:
	match style:
		0:
			add_stylebox_override("bg", _bg_top)
			add_stylebox_override("fg", _fg_top)
		1:
			add_stylebox_override("bg", _bg_middle)
			add_stylebox_override("fg", _fg_middle)
		2:
			add_stylebox_override("bg", _bg_bottom)
			add_stylebox_override("fg", _fg_bottom)
		3:
			add_stylebox_override("bg", _bg)
			add_stylebox_override("fg", _fg)


func _on_button_pressed(increase: bool) -> void:
	if increase:
		value += step
	else:
		value -= step
	_update_line_edit_value(value)


func _on_line_edit_changed(text = "") -> void:
	if text == "":
		text = _line_edit.text
	value = stepify(float(text), step)
	if text != String(value):
		_line_edit.text = String(value)
	_update_ui_size()
