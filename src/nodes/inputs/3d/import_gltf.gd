tool
extends ConceptNode


var _label: Label
var _data


func _init() -> void:
	unique_id = "import_gltf"
	display_name = "Import GLTF"
	category = "Inputs"
	description = "Load a gltf or glb file"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_OPEN_FILE,
			"filters": ["*.glb", "*.gltf"]
		},
		"expand": false
	}
	set_input(0, "Path", ConceptGraphDataType.STRING, opts)
	set_input(1, "Auto Import", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_output(0, "", ConceptGraphDataType.NODE_3D)


func _ready() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_connect(get_parent(), "force_import", self, "_trigger_import", [true])


func _generate_outputs() -> void:
	var auto_import: bool = get_input_single(1, false)
	if auto_import or not _data:
		_trigger_import()

	output[0] = _data


func _trigger_import(reset := true) -> void:
	var path: String = get_input_single(0, "")
	var gltf = PackedSceneGLTF.new()
	gltf.pack_gltf(path)
	_data = gltf.instance()

	if reset:
		reset()


func _on_default_gui_interaction(_value, _control: Control, slot: int) -> void:
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
