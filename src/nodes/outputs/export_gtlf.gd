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
	set_input(1, "Path", ConceptGraphDataType.STRING, opts)
	set_input(2, "Auto Export", ConceptGraphDataType.BOOLEAN, {"value": false})


func _ready() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_connect(get_parent(), "force_export", self, "_force_export")


func _generate_outputs() -> void:
	var auto_export: bool = get_input_single(2, false)
	if auto_export:
		_force_export()


func _force_export() -> void:
	var node: Spatial = get_input_single(0, null)
	var path: String = get_input_single(1, "")
	path = get_parent().get_absolute_path(path)
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

	var text: String = get_input_single(1, "")

	_label.text = "Target: "
	if text != "":
		_label.text += text.get_file()
	else:
		_label.text += "None"

	if not resizable:
		rect_size = Vector2.ZERO
		_redraw()
