extends ConceptNode


var _preview: NoisePreview
var _is_preview_outdated = true


func _init() -> void:
	unique_id = "viewer_2d"
	display_name = "Viewer 2D"
	category = "Output"
	description = "Display a preview of a 2D node output"

	set_input(0, "2D Object", ConceptGraphDataType.NODE_2D)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _on_default_gui_ready() -> void:
	_preview = preload("res://views/nodes/noise_preview.tscn").instance()
	_preview.connect("preview_requested", self, "_on_preview_requested")
	_preview.connect("preview_hidden", self, "_on_preview_hidden")
	add_child(_preview)


func _generate_outputs() -> void:
	var input = get_input_single(0)
	if _preview.is_displayed and _is_preview_outdated:
		if input is ConceptGraphNoise:
			_preview.create_from_noise(input)
		elif input is ConceptGraphHeightmap:
			_preview.create_from_heightmap(input)
		elif input is Image:
			_preview.create_from_image(input)


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func is_final_output_node() -> bool:
	return true


func _on_input_changed(slot: int, _value) -> void:
	_is_preview_outdated = true
	if _preview.is_displayed:
		_generate_outputs()


func _on_preview_requested() -> void:
	_generate_outputs()
	emit_signal("raise_request")


func _on_preview_hidden() -> void:
	rect_size = Vector2.ZERO
	update()
