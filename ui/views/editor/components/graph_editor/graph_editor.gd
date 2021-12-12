class_name NodeGraphEditor
extends GraphEdit


const AddNodePopup = preload("./components/popup/add_node_popup.tscn")

var _graph: NodeGraph
var _add_node_popup: Popup
var _right_click_position: Vector2
var _previous_scroll_offset: Vector2


func _ready() -> void:
	popup_request.connect(_show_add_node_popup)
	connection_request.connect(_on_connection_request)
	disconnection_request.connect(_on_disconnection_request)
	delete_nodes_request.connect(_on_delete_nodes_request)

	# Setup connections types
	var c = DataType.get_valid_connections()
	for target in c.keys():
		var sources = c[target]
		for source in sources:
			add_valid_connection_type(source, target)


# Overriding parent functions.
func connect_node(from, from_port, to, to_port):
	var err = super(from, from_port, to, to_port)
	if err == OK:
		var from_node = get_node(NodePath(from))
		var to_node = get_node(NodePath(to))
		from_node.notify_output_connection_changed(int(from_port), true)
		to_node.notify_input_connection_changed(int(to_port), true)
	return err


func disconnect_node(from, from_port, to, to_port):
	super(from, from_port, to, to_port)
	var from_node = get_node(NodePath(from))
	var to_node = get_node(NodePath(to))
	from_node.notify_output_connection_changed(int(from_port), false)
	to_node.notify_input_connection_changed(int(to_port), false)


func set_node_graph(graph: NodeGraph) -> void:
	_graph = graph
	rebuild_ui()


func clear() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()


# Creates the visual representation of the NodeGraph item.
func rebuild_ui() -> void:
	_previous_scroll_offset = scroll_offset
	clear()

	for n in _graph.nodes.values():
		var proton_node = n as ProtonNode
		var graph_node := ProtonNodeUi.new()
		add_child(graph_node)
		graph_node.close_request.connect(_on_close_request.bind(graph_node))
		graph_node.proton_node = proton_node
		graph_node.name = proton_node.unique_name
		graph_node.rebuild_ui()

	for c in _graph.connections:
		var _err = self.connect_node(c.from, c.from_port, c.to, c.to_port)


	await(get_tree().process_frame)
	scroll_offset = _previous_scroll_offset


# TMP hack because calling update alone doesn't update the connections which
# are in another layer.
func force_redraw() -> void:
	$CLAYER.update()
	update()


func delete_node(node: ProtonNodeUi) -> void:
	remove_child(node)
	_graph.delete_node(node.proton_node)
	force_redraw()


func _show_add_node_popup(position: Vector2i) -> void:
	if not is_instance_valid(_add_node_popup):
		_add_node_popup = AddNodePopup.instantiate()
		add_child(_add_node_popup)
		_add_node_popup.create_node_request.connect(_on_create_node_request)

	_right_click_position = position - get_tree().get_root().position
	_add_node_popup.position = position
	_add_node_popup.popup()


func _on_create_node_request(node_type_id: String) -> void:
	var node_position: Vector2 = -get_global_transform().origin
	node_position += scroll_offset + _right_click_position
	node_position /= get_zoom()
	var data = {
		"position": node_position
	}
	_graph.create_node(node_type_id, data)
	rebuild_ui()


func _on_connection_request(from, from_slot: int, to, to_slot: int) -> void:
	if from == to:
		return

	# Disconnect any existing connection to the input slot first unless multi connection is enabled
	var node = get_node(to)
	if not node.is_multiple_connections_enabled_on_slot(to_slot):
		for c in get_connection_list():
			if c.to == to and c.to_port == to_slot:
				self.disconnect_node(c.from, c.from_port, c.to, c.to_port)
				break

	var err = self.connect_node(from, from_slot, to, to_slot)
	if err != OK:
		print("Error ", err, " - Could not connect node ", from, ":", from_slot, " to ", to, ":", to_slot)
		return

	_graph.connect_node(from, from_slot, to, to_slot)


func _on_disconnection_request(from: StringName, from_slot: int, to: StringName, to_slot: int) -> void:
	self.disconnect_node(from, from_slot, to, to_slot)
	_graph.disconnect_node(from, from_slot, to, to_slot)


func _on_delete_nodes_request(selected = null) -> void:
	if not selected:
		return


func _on_close_request(node: GraphNode) -> void:
	delete_node(node)
