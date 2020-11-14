extends ProtonNode
class_name GenericExportNode


func _init(filters := ["*.*"]) -> void:
	ignore = true
	unique_id = "generic_export_node"
	display_name = "Generic Export Node"
	category = "Output"
	description = "Abstract export node. Inherit this class to do something useful"

	var opts = {
		"file_dialog": {
			"mode": FileDialog.MODE_SAVE_FILE,
			"filters": filters
		},
		"expand": false,
	}
	
	set_input(0, "Node", DataType.ANY)
	set_input(1, "Path", DataType.STRING, opts)
	set_input(2, "Auto Export", DataType.BOOLEAN, {"value": false})


func _enter_tree() -> void:
	Signals.safe_connect(get_parent(), "force_export", self, "_trigger_export")


func _exit_tree() -> void:
	Signals.safe_disconnect(get_parent(), "force_export", self, "_trigger_export")


func _generate_outputs() -> void:
	var auto_export: bool = get_input_single(2, false)
	if auto_export:
		_trigger_export()


# Override this method in the derived class
func _trigger_export() -> void:
	pass


func get_resource_path() -> String:
	var path: String = get_input_single(1, "")
	return PathUtil.get_absolute_path(path, template_path)


func is_final_output_node() -> bool:
	return true
