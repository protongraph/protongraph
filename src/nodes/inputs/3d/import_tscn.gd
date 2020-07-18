tool
extends ConceptNode


var _label: Label


func _init() -> void:
	unique_id = "import_tscn"
	display_name = "Import Godot Scene"
	category = "Inputs"
	description = "Load a Godot scene file (scn or tscn)"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_OPEN_FILE,
			"filters": ["*.scn", "*.tscn"]
		},
		"expand": false
	}
	set_input(0, "Path", ConceptGraphDataType.STRING, opts)
	set_output(0, "", ConceptGraphDataType.NODE_3D)


func _ready() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")


func _generate_outputs() -> void:
	var path: String = get_input_single(0, "")
	var scene := load(path)
	if scene.can_instance():
		output[0] = scene.instance()


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

	var text: String = get_input_single(0, "")

	_label.text = "Source: "
	if text != "":
		_label.text += text.get_file()
	else:
		_label.text += "None"
