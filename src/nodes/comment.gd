tool
extends ConceptNode


func _init() -> void:
	unique_id = "comment"
	display_name = "Comment"
	category = "Utilities"
	description = "Insert comment in concept graph editor"
	resizable = true


func export_custom_data() -> Dictionary:
	return {"comment_text": $LineEditComment.text}


func restore_custom_data(data: Dictionary) -> void:
	if not data.has("comment_text"):
		return
	$LineEditComment.text = data["comment_text"]


func has_custom_gui() -> bool:
	return true


"""
Emmit signal for saving data, when comment was changed
"""
func _on_LineEditComment_text_changed(new_text: String) -> void:
	emit_signal("node_changed", self, false)
