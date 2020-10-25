tool
extends ConceptNode

var _line_edit_comment


func _init() -> void:
	unique_id = "comment"
	display_name = "Comment"
	category = "Utilities"
	description = "Insert comment in concept graph editor"
	resizable = true
	comment = true

	_line_edit_comment = preload("line_edit_comment.tscn").instance()
	call_deferred("add_child", _line_edit_comment)


func export_custom_data() -> Dictionary:
	return {"comment_text": _line_edit_comment.text}


func restore_custom_data(data: Dictionary) -> void:
	if not data.has("comment_text"):
		return
	_line_edit_comment.text = data["comment_text"]


"""
Emmit signal for saving data, when comment was changed
"""
func _on_LineEditComment_text_changed(new_text: String) -> void:
	emit_signal("node_changed", self, false)
