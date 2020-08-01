extends MarginContainer

var text: String setget set_text
var _line_edit: LineEdit


func set_text(value: String) -> void:
	if not _line_edit:
		_line_edit = get_node("LineEditComment")

	_line_edit.text = value
	text = value
