tool
extends ConceptNode


func _init() -> void:
	unique_id = "proxy_in"
	display_name = "Proxy (In)"
	category = "Utilities"
	description = "When you need to access the same node from parts of the graph that are far away"

	set_input(0, "Source", ConceptGraphDataType.ANY)
	set_input(1, "Name", ConceptGraphDataType.STRING)

	connect("connection_changed", self, "_on_connection_changed_custom")


func _on_editor_data_restored() -> void:
	get_parent().register_proxy(self, get_input_single(1, ""))


func _generate_outputs() -> void:
	output.resize(1) # Little trick to avoid showing an output socket but still have the output array the valid size
	output[0] = get_input(0)


func _exit_tree() -> void:
	get_parent().deregister_proxy(self)


func _on_default_gui_interaction(value, _control: Control, slot: int) -> void:
	if slot == 1:
		get_parent().register_proxy(self, value)


func _on_connection_changed_custom():
	if is_input_connected(0):
		var connected_type = get_connected_input_type(0)
		set_input(0, "Source", connected_type)
	else:
		set_input(0, "Source", ConceptGraphDataType.ANY)
	_setup_slots()
