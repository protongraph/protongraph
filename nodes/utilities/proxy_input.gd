extends ProtonNode


func _init() -> void:
	unique_id = "proxy_in"
	display_name = "Proxy (In)"
	category = "Utilities"
	description = "When you need to access the same node from parts of the graph that are far away"

	set_input(0, "Source", DataType.ANY)
	set_input(1, "Name", DataType.STRING)

	Signals.safe_connect(self, "connection_changed", self, "_on_connection_changed_custom")
	Signals.safe_connect(self, "gui_value_changed", self, "_on_gui_value_changed")


func _exit_tree() -> void:
	_deregister_as_proxy()


func _generate_outputs() -> void:
	output[0] = get_input(0)


func _register_as_proxy(name) -> void:
	var parent = get_parent()
	if parent:
		parent.register_proxy(self, name)


func _deregister_as_proxy() -> void:
	var parent = get_parent()
	if parent:
		parent.deregister_proxy(self)


func _on_editor_data_restored() -> void:
	_register_as_proxy(get_input_single(1))


func _on_gui_value_changed(value, slot: int) -> void:
	if slot == 1:
		_register_as_proxy(value)


func _on_connection_changed_custom():
	if is_input_connected(0):
		var connected_type = get_connected_input_type(0)
		set_input(0, "Source", connected_type)
	else:
		set_input(0, "Source", DataType.ANY)
	_setup_slots()
