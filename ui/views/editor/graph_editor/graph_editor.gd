class_name NodeGraphEditor
extends GraphEdit


signal node_deleted(ProtonNodeUi)


const AddNodePopup := preload("./components/popup/add_node_popup.tscn")

var _graph: NodeGraph
var _add_node_popup: Window
var _new_node_position: Vector2
var _rebuild_ui_complete := false


func _ready() -> void:
	popup_request.connect(_show_add_node_popup)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)
	scroll_offset_changed.connect(_on_scroll_offset_changed)

	# Setup connections types
	var c = DataType.get_valid_connections()
	for target in c.keys():
		var sources = c[target]
		for source in sources:
			add_valid_connection_type(source, target)

	# Add UI to move the graphedit to an external window
	var box := get_zoom_hbox()
	var button := FloatButton.new()
	button.subwindow_id = "graph_editor"
	box.add_child(button)
	var auto_scale := AutoScale.new()
	button.add_child(auto_scale)


func connect_node_and_notify(from, from_port, to, to_port):
	var err = connect_node(from, from_port, to, to_port)
	if err == OK:
		var from_node = get_node(NodePath(from))
		var to_node = get_node(NodePath(to))
		from_node.notify_output_connection_changed(int(from_port), true)
		to_node.notify_input_connection_changed(int(to_port), true)
	return err


func disconnect_node_and_notify(from, from_port, to, to_port):
	disconnect_node(from, from_port, to, to_port)
	var from_node = get_node(NodePath(from))
	var to_node = get_node(NodePath(to))
	from_node.notify_output_connection_changed(int(from_port), false)
	to_node.notify_input_connection_changed(int(to_port), false)


func set_node_graph(graph: NodeGraph) -> void:
	_graph = graph
	rebuild_ui()
	_graph.rebuild(true)


func clear() -> void:
	NodeUtil.remove_children(self)
	_rebuild_ui_complete = false


# Creates the visual representation of the NodeGraph item.
func rebuild_ui() -> void:
	clear()

	for n in _graph.nodes.values():
		_create_proton_node_ui(n)

	for c in _graph.connections:
		var from: ProtonNodeUi = get_node(NodePath(c.from))
		var to: ProtonNodeUi = get_node(NodePath(c.to))
		if not from or not to:
			continue

		var from_port := from.output_idx_to_port(c.from_idx)
		var to_port := to.input_idx_to_port(c.to_idx)
		connect_node_and_notify(c.from, from_port, c.to, to_port)

	await(get_tree().process_frame)

	# Restore scroll offset after all nodes are created, otherwise the target
	# offset might not be available yet
	if "scroll_offset" in _graph.external_data:
		scroll_offset = _graph.external_data["scroll_offset"]

	_rebuild_ui_complete = true


# TMP hack because calling update alone doesn't update the connections which
# are in another layer.
func force_redraw() -> void:
	await get_tree().process_frame
	$CLAYER.queue_redraw()
	queue_redraw()


func delete_node(node: ProtonNodeUi) -> void:
	for c in get_connection_list():
		if c.to == node.name or c.from == node.name:
			disconnect_node_and_notify(c.from, c.from_port, c.to, c.to_port)

	remove_child(node)
	_graph.delete_node(node.proton_node)
	node_deleted.emit(node)
	force_redraw.call_deferred()


func disconnect_inputs(node: ProtonNodeUi, port: int):
	for c in get_connection_list():
		if c.to == node.name and c.to_port == port:
			disconnect_node_and_notify(c.from, c.from_port, c.to, c.to_port)


func disconnect_outputs(node: ProtonNodeUi, port: int):
	for c in get_connection_list():
		if c.from == node.name and c.from_port == port:
			disconnect_node_and_notify(c.from, c.from_port, c.to, c.to_port)


func get_left_connected(node: ProtonNodeUi, port: int) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	for c in get_connection_list():
		if c.to == node.name and c.to_port == port:
			res.push_back({
				"node": get_node(NodePath(c.from)),
				"port": c.from_port,
			})
	return res


func get_right_connected(node: ProtonNodeUi, port: int) -> Array[Dictionary]:
	var res: Array[Dictionary] = []
	for c in get_connection_list():
		if c.from == node.name and c.from_port == port:
			res.push_back({
				"node": get_node(NodePath(c.to)),
				"port": c.to_port,
			})
	return res


func get_right_connected_flat(node: ProtonNodeUi, port: int = -1) -> Array[ProtonNodeUi]:
	var res: Array[ProtonNodeUi] = []
	for c in get_connection_list():
		if c.from != node.name:
			continue

		if c.from_port == port or port == -1:
			res.push_back(get_node(NodePath(c.to)))

	return res


func _create_proton_node_ui(proton_node: ProtonNode) -> void:
	var graph_node := ProtonNodeUi.new()
	add_child(graph_node)
	graph_node.graph_editor = self
	graph_node.proton_node = proton_node
	graph_node.name = proton_node.unique_name
	graph_node.close_request.connect(_on_close_request.bind(graph_node))
	graph_node.rebuild_ui()


func _show_add_node_popup(click_position: Vector2i) -> void:
	if not is_instance_valid(_add_node_popup):
		_add_node_popup = AddNodePopup.instantiate()
		add_child(_add_node_popup)
		_add_node_popup.create_node_request.connect(_on_create_node_request)

	var global_click_position: Vector2i = get_global_mouse_position()
	var window_position := WindowManager.get_parent_window(self).position

	# Necessary because sub windows are not embedded.
	_add_node_popup.position = global_click_position + window_position
	_add_node_popup.popup()

	_new_node_position = Vector2i(global_position) + click_position


func _on_create_node_request(node_type_id: String) -> void:
	var node_position: Vector2 = -get_global_transform().origin
	node_position += scroll_offset + _new_node_position
	node_position /= get_zoom()
	var data = {
		"position": node_position
	}
	var node := _graph.create_node(node_type_id, data)
	_create_proton_node_ui(node)


func _on_connection_request(from, from_port: int, to, to_port: int) -> void:
	if from == to:
		return

	var from_node: ProtonNodeUi = get_node_or_null(NodePath(from))
	var to_node: ProtonNodeUi = get_node_or_null(NodePath(to))

	if not from_node or not to_node:
		return

	# Disconnect any existing connection to the input slot first unless multi connection is enabled
	if not to_node.is_multiple_connections_enabled_on_port(to_port):
		disconnect_inputs(to_node, to_port)

	var err = connect_node_and_notify(from, from_port, to, to_port)
	if err != OK:
		print_debug("Error ", err, " - Could not connect node ", from, ":", from_port, " to ", to, ":", to_port)
		return

	var from_idx = from_node.output_port_to_idx(from_port)
	var to_idx = to_node.input_port_to_idx(to_port)
	_graph.connect_node(from, from_idx, to, to_idx)
	force_redraw.call_deferred()


func _on_disconnection_request(from: StringName, from_port: int, to: StringName, to_port: int) -> void:
	disconnect_node_and_notify(from, from_port, to, to_port)

	var from_node: ProtonNodeUi = get_node_or_null(NodePath(from))
	var to_node: ProtonNodeUi = get_node_or_null(NodePath(to))
	if not from_node or not to_node:
		return

	var from_idx = from_node.output_port_to_idx(from_port)
	var to_idx = to_node.input_port_to_idx(to_port)
	_graph.disconnect_node(from, from_idx, to, to_idx)
	force_redraw.call_deferred()


func _on_delete_nodes_request(selected: Array = []) -> void:
	for node in selected:
		_on_close_request(get_node(NodePath(node)))


func _on_close_request(node: GraphNode) -> void:
	delete_node(node)


func _on_scroll_offset_changed(new_offset: Vector2i) -> void:
	if _graph and _rebuild_ui_complete:
		_graph.external_data["scroll_offset"] = new_offset
