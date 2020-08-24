extends ConceptNode
class_name GenericExportNode


var _label: Label


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
	
	#set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Path", ConceptGraphDataType.STRING, opts)
	set_input(2, "Auto Export", ConceptGraphDataType.BOOLEAN, {"value": false})


func _enter_tree() -> void:
	Signals.safe_connect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_connect(get_parent(), "force_export", self, "_trigger_export")

func _exit_tree() -> void:
	Signals.safe_disconnect(get_parent(), "template_loaded", self, "_update_preview")
	Signals.safe_disconnect(get_parent(), "force_export", self, "_trigger_export")


func _generate_outputs() -> void:
	var auto_export: bool = get_input_single(2, false)
	if auto_export:
		_trigger_export()


"""
Override this method in the child class
"""
func _trigger_export() -> void:
	pass


func get_resource_path() -> String:
	var path: String = get_input_single(1, "")
	return get_parent().get_absolute_path(path)


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
