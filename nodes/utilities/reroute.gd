extends ProtonNode


func _init() -> void:
	unique_id = "reroute_graph"
	display_name = "Reroute"
	category = "Utilities"
	description = "Used to organize the connections between GraphNodes"

	set_input(0, "", DataType.ANY, {"show_type_icon": false})
	set_output(0, "", DataType.ANY, {"show_type_icon": false})
	mirror_slots_type(0, 0)


func _on_default_gui_ready() -> void:
	title = ""
	show_close = false

	var frame = get_stylebox("frame")
	frame.border_width_top = frame.border_width_bottom
	add_stylebox_override("frame", frame)

	var selected = get_stylebox("selectedframe")
	selected.border_width_top = selected.border_width_bottom
	add_stylebox_override("selectedframe", selected)

	rect_size = Vector2.ZERO


func _generate_outputs() -> void:
	output[0] = get_input(0)
