tool
extends ConceptNode

"""
This node allows the user to save the input as a scene file by using ResourceSaver
"""


var directory := Directory.new()

var _label: Label


func _init() -> void:
	unique_id = "save_tscn_output"
	display_name = "Export Godot Scene"
	category = "Output"
	description = "Saves the output as a scene file"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_SAVE_FILE,
			"filters": ["*.scn", "*.tscn"]
		},
		"expand": false
	}

	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Path", ConceptGraphDataType.STRING, opts)
	set_input(2, "Auto Export", ConceptGraphDataType.BOOLEAN, {"value": false})


func _ready() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_connect(get_parent(), "force_export", self, "_force_export")


func is_final_output_node() -> bool:
	return true


func _set_children_owner(root: Node, node: Node):
	for child in node.get_children():
		child.set_owner(root)
		if child.get_children().size() > 0:
			_set_children_owner(root, child)


func _save_scene(scene, path: String):
	# sets the owner of all the children to scene
	_set_children_owner(scene, scene)

	var packed_scene := PackedScene.new()
	if packed_scene.pack(scene) != OK:
		print("Failed to pack resource")
		return

	ResourceSaver.save(path, packed_scene)


func _force_export() -> void:
	var out = get_input_single(0)
	var path: String = get_input_single(1, "")
	path = get_parent().get_absolute_path(path)

	if path and path != "" and out:
		_save_scene(out, path)
		print("Exported ", path)


func _generate_outputs() -> void:
	var auto_export: bool = get_input_single(2, false)
	if auto_export:
		_force_export()


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)


func _on_default_gui_interaction(value, _control: Control, slot: int) -> void:
	if slot == 0:
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
