extends ProtonNode


var _proxy_in
var _template_signals_connected := false


func _init() -> void:
	unique_id = "proxy_out"
	display_name = "Proxy (Out)"
	category = "Utilities"
	description = "When you need to access the same node from parts of the graph that are far away"

	set_input(0, "Name", DataType.STRING)
	set_output(0, "", DataType.ANY, {"show_type_icon": false})


func _enter_tree() -> void:
	if not _template_signals_connected:
		var template = get_parent()
		if not template:
			return

		Signals.safe_connect(template, "proxy_list_updated", self, "_link_proxy")
		Signals.safe_connect(self, "gui_value_changed", self, "_on_gui_value_changed")
		_template_signals_connected = true
	
	_link_proxy()


func _generate_outputs() -> void:
	_update_output_type()
	var proxy_name: String = get_input_single(0, null)
	var proxy = get_parent().get_proxy(proxy_name)
	if proxy:
		output[0] = proxy.get_output(0)


func _on_gui_value_changed(_value, slot: int) -> void:
	if slot == 0:
		_link_proxy()


func _link_proxy() -> void:
	if _proxy_in:
		Signals.safe_disconnect(_proxy_in, "connection_changed", self, "_update_output_type")
		Signals.safe_disconnect(_proxy_in, "cache_cleared", self, "reset")
		_proxy_in = null

	var proxy_name = get_input_single(0, "")
	var template = get_parent()
	if not template:
		return # Not in the scene tree

	_proxy_in = template.get_proxy(proxy_name)
	if _proxy_in:
		Signals.safe_connect(_proxy_in, "connection_changed", self, "_update_output_type")
		Signals.safe_connect(_proxy_in, "cache_cleared", self, "reset")
	
	_update_output_type()


func _update_output_type() -> void:
	var type = DataType.ANY
	if _proxy_in:
		if _proxy_in.is_input_connected(0):
			type = _proxy_in.get_connected_input_type(0)
		else:
			type = _proxy_in.get_local_input_type(0)
		if type == -1:
			type = DataType.ANY
	
	set_output(0, "", type)
	_setup_slots()
	force_redraw()
