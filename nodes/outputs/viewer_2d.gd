extends ProtonNode


func _init() -> void:
	unique_id = "viewer_2d"
	display_name = "Viewer 2D"
	category = "Output"
	description = "Display a preview of a 2D node output"

	set_input(0, "2D Object", DataType.NODE_2D)
	set_extra(0, Constants.UI_PREVIEW_2D, {"output_index": 0})


func _ready() -> void:
	Signals.safe_connect(self, "input_changed", self, "_on_input_changed")


func _generate_outputs() -> void:
	output[0] = get_input_single(0)


func is_final_output_node() -> bool:
	return true
