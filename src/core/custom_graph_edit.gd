extends GraphEdit


"""
This GraphEdit class handles all the editor interactions, undo redo and so on.
The addon specific logic happens in the child class ConceptGraphTemplate.
"""

signal graph_changed
signal connection_changed
signal node_created
signal node_deleted
signal update_minimap


var undo_redo: UndoRedo

var _copy_buffer := []
var _connections_buffer := []
var _ui_style_ready := false
var _minimap = preload("../../views/editor/graph_minimap.tscn").instance()


func _init() -> void:
	undo_redo = GlobalUndoRedo.get_undo_redo()

	_setup_gui()
	ConceptGraphDataType.setup_valid_connection_types(self)

	Signals.safe_connect(self, "connection_request", self, "_on_connection_request")
	Signals.safe_connect(self, "disconnection_request", self, "_on_disconnection_request")
	Signals.safe_connect(self, "copy_nodes_request", self, "_on_copy_nodes_request")
	Signals.safe_connect(self, "paste_nodes_request", self, "_on_paste_nodes_request")
	Signals.safe_connect(self, "delete_nodes_request", self, "_on_delete_nodes_request")
	Signals.safe_connect(self, "duplicate_nodes_request", self, "_on_duplicate_nodes_request")
	Signals.safe_connect(self, "_end_node_move", self, "_on_node_changed_zero")
	Signals.safe_connect(self, "node_selected", self, "_on_node_selected")
	Signals.safe_connect(self, "graph_changed", self, "_on_graph_changed")

	_minimap.graph_edit = self
	call_deferred("add_child", _minimap)


func clear_editor() -> void:
	clear_connections()
	for c in get_children():
		if c is GraphNode:
			remove_child(c)
			c.queue_free()


func duplicate_node(_node):
	pass


func delete_node(node) -> void:
	_disconnect_node_signals(node)
	_disconnect_active_connections(node)
	remove_child(node)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
	update() # Force the GraphEdit to redraw to hide the old connections to the deleted node
	emit_signal("node_deleted", node)


func restore_node(node) -> void:
	_connect_node_signals(node)
	add_child(node, true)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
	emit_signal("node_created", node)


func regenerate_graphnodes_style() -> void:
	if _ui_style_ready:
		return

	for child in get_children():
		if child is ConceptNode:
			if child.requires_full_gui_rebuild:
				child.regenerate_default_ui()
			else:
				child._generate_default_gui_style()
	_ui_style_ready = true


"""
Returns an array of GraphNodes connected to the left of the given slot, including the slot index
the connection originates from
"""
func get_left_nodes(node: GraphNode, slot: int) -> Array:
	var result = []
	for c in get_connection_list():
		if c["to"] == node.get_name() and c["to_port"] == slot:
			var data = {
				"node": get_node(c["from"]),
				"slot": c["from_port"]
			}
			result.append(data)
	return result


"""
Returns an array of GraphNodes connected to the right of the given slot.
"""
func get_right_nodes(node: GraphNode, slot: int) -> Array:
	var result = []
	for c in get_connection_list():
		if c["from"] == node.get_name() and c["from_port"] == slot:
			result.append(get_node(c["to"]))
	return result


"""
Returns an array of all the GraphNodes on the left, regardless of the slot.
"""
func get_all_left_nodes(node) -> Array:
	var result = []
	for c in get_connection_list():
		if c["to"] == node.get_name():
			result.append(get_node(c["from"]))
	return result


"""
Returns an array of all the GraphNodes on the right, regardless of the slot.
"""
func get_all_right_nodes(node) -> Array:
	var result = []
	for c in get_connection_list():
		if c["from"] == node.get_name():
			result.append(get_node(c["to"]))
	return result


"""
Returns true if the given node is connected to the given slot
"""
func is_node_connected_to_input(node: GraphNode, idx: int) -> bool:
	var name = node.get_name()
	for c in get_connection_list():
		if c["to"] == name and c["to_port"] == idx:
			return true
	return false


# TMP hack because GraphEdit just love getting in my way. Update() alone won't redraw the connections
# and there's nothing exposed to do that so we force a full redraw by moving the view just enough
# to invalidate the previous view render but not enough to actually move the view
func force_redraw() -> void:
	scroll_offset.x += 0.001


func _setup_gui() -> void:
	right_disconnects = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	anchor_right = 1.0
	anchor_bottom = 1.0


func _connect_node_signals(node) -> void:
	node.connect("node_changed", self, "_on_node_changed")
	node.connect("close_request", self, "_on_delete_nodes_request", [node])
	node.connect("dragged", self, "_on_node_dragged", [node])


func _disconnect_node_signals(node) -> void:
	node.disconnect("node_changed", self, "_on_node_changed")
	node.disconnect("close_request", self, "_on_delete_nodes_request")
	node.disconnect("dragged", self, "_on_node_dragged")


func _disconnect_active_connections(node: GraphNode) -> void:
	var name = node.get_name()
	for c in get_connection_list():
		var to = c["to"]
		var from = c["from"]
		if to == name or from == name:
			disconnect_node(from, c["from_port"], to, c["to_port"])
			if to != name:
				get_node(to).emit_signal("connection_changed")


func _disconnect_input(node: GraphNode, idx: int) -> void:
	var name = node.get_name()
	for c in get_connection_list():
		if c["to"] == name and c["to_port"] == idx:
			disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
			return


func _get_selected_nodes() -> Array:
	var nodes = []
	for c in get_children():
		if c is GraphNode and c.selected:
			nodes.append(c)
	return nodes


func _on_connection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	# Prevent connecting the node to itself
	if from_node == to_node:
		return

	# Disconnect any existing connection to the input slot first unless multi connection is enabled
	var node = get_node(to_node)
	if not node.is_multiple_connections_enabled_on_slot(to_slot):
		for c in get_connection_list():
			if c["to"] == to_node and c["to_port"] == to_slot:
				disconnect_node(c["from"], c["from_port"], c["to"], c["to_port"])
				break

	connect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
	get_node(to_node).emit_signal("connection_changed")


func _on_disconnection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	disconnect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
	get_node(to_node).emit_signal("connection_changed")


func _on_node_selected(_node) -> void:
	# Make sure the minimap always stays on top
	_minimap.raise()


func _on_graph_changed() -> void:
	_minimap.raise()


func _on_node_dragged(from: Vector2, to: Vector2, node: GraphNode) -> void:
	undo_redo.create_action("Move " + node.display_name)
	undo_redo.add_do_method(node, "set_offset", to)
	undo_redo.add_undo_method(node, "set_offset", from)
	undo_redo.commit_action()


func _on_copy_nodes_request() -> void:
	_copy_buffer = []
	_connections_buffer = get_connection_list()

	for node in _get_selected_nodes():
		var new_node = duplicate_node(node)
		new_node.name = node.name	# Needed to retrieve active connections later
		new_node.offset -= scroll_offset
		_copy_buffer.append(new_node)
		node.selected = false


func _on_paste_nodes_request() -> void:
	if _copy_buffer.empty():
		return

	var tmp = []

	undo_redo.create_action("Copy " + String(_copy_buffer.size()) + " GraphNode(s)")
	for node in _copy_buffer:
		var new_node = duplicate_node(node)
		tmp.append(new_node)
		new_node.selected = true
		new_node.offset += scroll_offset + Vector2(80, 80)
		undo_redo.add_do_method(self, "restore_node", new_node)
		undo_redo.add_do_method(new_node, "regenerate_default_ui")
		undo_redo.add_undo_method(self, "remove_child", new_node)
	undo_redo.commit_action()

	# I couldn't find a way to merge these in a single action because the connect_node can't be called
	# if the child was not added to the tree first. TODO : Merge this in a single undoredo action
	undo_redo.create_action("Create connections")
	for co in _connections_buffer:
		var from := -1
		var to := -1

		for i in _copy_buffer.size():
			var name = _copy_buffer[i].get_name()
			if name == co["from"]:
				from = i
			elif name == co["to"]:
				to = i

		if from != -1 and to != -1:
			undo_redo.add_do_method(self, "connect_node", tmp[from].get_name(), co["from_port"], tmp[to].get_name(), co["to_port"])
			undo_redo.add_undo_method(self, "disconnect_node", tmp[from].get_name(), co["from_port"], tmp[to].get_name(), co["to_port"])
	undo_redo.commit_action()


func _on_delete_nodes_request(selected = null) -> void:
	if not selected:
		selected = _get_selected_nodes()
	elif not selected is Array:
		selected = [selected]
	if selected.size() == 0:
		return

	undo_redo.create_action("Delete " + String(selected.size()) + " GraphNode(s)")
	for node in selected:
		undo_redo.add_do_method(self, "delete_node", node)
		undo_redo.add_undo_method(self, "restore_node", node)

	undo_redo.commit_action()
	update()


func _on_duplicate_nodes_request() -> void:
	_on_copy_nodes_request()
	_on_paste_nodes_request()
