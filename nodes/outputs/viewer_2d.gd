extends ConceptNode


func _init() -> void:
	unique_id = "viewer_2d"
	display_name = "Viewer 2D"
	category = "Output"
	description = "Display a preview of a 2D node output"

	set_input(0, "2D Object", DataType.NODE_2D)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	var input = get_input_single(0)


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func is_final_output_node() -> bool:
	return true
