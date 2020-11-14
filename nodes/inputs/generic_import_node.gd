extends ProtonNode
class_name GenericImportNode


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
	Signals.safe_connect(_template, "force_import", self, "_trigger_import")


func _exit_tree() -> void:
	Signals.safe_disconnect(_template, "force_import", self, "_trigger_import")


func _generate_outputs() -> void:
	var auto_import: bool = get_input_single(1, false)
	if auto_import or not _data:
		_trigger_import()

	if _data:
		output[0] = _data.duplicate(7)


# Override this method
func _trigger_import() -> void:
	pass


func get_resource_path() -> String:
	var path: String = get_input_single(0, "")
	return PathUtil.get_absolute_path(path, template_path)


func _force_import() -> void:
	_trigger_import()
	reset()


func _on_default_gui_interaction(_value, _control: Control, slot: int) -> void:
	if slot == 0:
		_trigger_import()
