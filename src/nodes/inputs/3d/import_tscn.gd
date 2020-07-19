tool
extends ConceptNode


var _label: Label
var _data

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
	set_input(1, "Auto Import", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_output(0, "", ConceptGraphDataType.NODE_3D)


func _ready() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_connect(get_parent(), "force_import", self, "_force_import")


func _generate_outputs() -> void:
	var auto_import: bool = get_input_single(1, false)
	#if _no_data_available():
	#	_trigger_import(auto_import)
	_trigger_import(true)
	print(_data)
	output[0] = _data


func _trigger_import(no_cache := false) -> void:
	var path: String = get_input_single(0, "")
	var scene := ResourceLoader.load(path, "", no_cache)
	print("scene : ", scene)
	if scene.can_instance():
		_data = scene.instance()


func _force_import() -> void:
	_trigger_import(true)
	reset()


func _no_data_available() -> bool:
	var wr = weakref(_data)
	return not _data or not wr.get_ref()


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
