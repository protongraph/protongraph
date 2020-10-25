extends ConceptNode
class_name GenericImportNode


var _label: Label
var _data
var _template


func _init(filters := ["*.*"]) -> void:
	ignore = true
	unique_id = "generic_import_node"
	display_name = ""
	category = "Inputs"
	description = "Abstract class for import nodes"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_OPEN_FILE,
			"filters": filters
		},
		"expand": false
	}
	set_input(0, "Path", DataType.STRING, opts)
	set_input(1, "Auto Import", DataType.BOOLEAN, {"value": false})


func _enter_tree() -> void:
	_template = get_parent()
	Signals.safe_connect(_template, "template_loaded", self, "_update_preview")
	Signals.safe_connect(_template, "force_import", self, "_trigger_import")


func _exit_tree() -> void:
	Signals.safe_disconnect(_template, "template_loaded", self, "_update_preview")
	Signals.safe_disconnect(_template, "force_import", self, "_trigger_import")


func _generate_outputs() -> void:
	var auto_import: bool = get_input_single(1, false)
	if auto_import or not _data:
		_trigger_import()

	if _data:
		output[0] = _data.duplicate(7)


"""
Override this method
"""
func _trigger_import() -> void:
	pass


func get_resource_path() -> String:
	var path: String = get_input_single(0, "")
	return get_parent().get_absolute_path(path)


func _force_import() -> void:
	_trigger_import()
	reset()


func _on_default_gui_interaction(_value, _control: Control, slot: int) -> void:
	if slot == 0:
		_update_preview()
		_trigger_import()


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
