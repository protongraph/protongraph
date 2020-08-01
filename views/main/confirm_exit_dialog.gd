extends WindowDialog


func _ready() -> void:
	rect_min_size *= ConceptGraphEditorUtil.get_editor_scale()
