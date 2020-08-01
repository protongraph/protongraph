extends Control


export var min_size_x := false
export var min_size_y := false
export var const_separation := false


func _ready() -> void:
	var scale = ConceptGraphEditorUtil.get_editor_scale()

	if min_size_x:
		rect_min_size.x *= scale

	if min_size_y:
		rect_min_size.y *= scale

	if const_separation:
		var s = get_constant("separation")
		add_constant_override("separation", s * scale)
