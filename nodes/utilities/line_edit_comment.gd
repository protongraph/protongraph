extends MarginContainer

var text: String setget set_text, get_text
var _line_edit: LineEdit


func set_text(value: String) -> void:
	if not _line_edit:
		_line_edit = get_node("LineEditComment")

	_line_edit.text = value


func get_text() -> String:
	if not _line_edit:
		_line_edit = get_node("LineEditComment")

	return _line_edit.text
