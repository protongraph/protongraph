tool
extends ConceptNode


var _label: Label


func _init() -> void:
	unique_id = "export_gltf"
	display_name = "Export GLTF"
	category = "Output"
	description = "The final node of any template"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_SAVE_FILE,
			"filters": ["*.gltf", "*.glb"]
		},
		"expand": false,
	}
	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Export path", ConceptGraphDataType.STRING, opts)


func _generate_outputs() -> void:
	var node: Spatial = get_input_single(0, null)
	var path: String = get_input_single(1, "")
	if node and path != "":
		var gltf := PackedSceneGLTF.new()
		gltf.export_gltf(node, path)


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func is_final_output_node() -> bool:
	return true


func _on_default_gui_interaction(value, _control: Control, slot: int) -> void:
	if slot == 1:
		_update_preview()


func _on_connection_changed() -> void:
	._on_connection_changed()
	_update_preview()


func _update_preview() -> void:
	if not _label:
		_label = Label.new()
		add_child(_label)

	var text: String = get_input_single(0, "")

	_label.text = "Target: "
	if text != "":
		_label.text += text.get_file()
	else:
		_label.text += "None"

	if not resizable:
		rect_size = Vector2.ZERO
		_redraw()
