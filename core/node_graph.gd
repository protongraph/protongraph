class_name NodeGraph
extends Resource


signal graph_changed
signal rebuild_started
signal thread_completed
signal rebuild_completed


var nodes: Dictionary
var connections: Array
var save_file_path: String
var external_data: Dictionary
var pending_changes := false

var input_tree: Node3D:
	set(val):
		MemoryUtil.safe_free(input_tree)
		input_tree = val
		input_tree.name = "InputTree"

var output_tree: Node3D:
	set(val):
		MemoryUtil.safe_free(output_tree)
		output_tree = val
		output_tree.name = "OutputTree"

var _leaf_nodes: Array[ProtonNode]
var _thread := Thread.new()
var _rebuild_queued := false


func _init():
	clear()
	graph_changed.connect(_on_graph_changed)
	thread_completed.connect(_on_thread_completed, CONNECT_DEFERRED)


func clear() -> void:
	nodes = {}
	connections = []
	external_data = {}
	_leaf_nodes.clear()
	input_tree = Node3D.new()
	output_tree = Node3D.new()


# Ensure every nodes and their connections slots exists. Otherwise, remove them
# from the connections list. This happens if a node changes its layout declaration
# between two versions or if the node script file was not found when loading a graph.
func validate_connections() -> void:
	var invalid_connections := []

	for c in connections:
		if not c.from in nodes or not c.to in nodes:
			invalid_connections.push_back(c)
			continue

		var from = nodes[c.from]
		var to = nodes[c.to]

		if not c.from_idx in from.outputs or not c.to_idx in to.inputs:
			invalid_connections.push_back(c)

	for c in invalid_connections:
		connections.erase(c)


func create_node(type_id: String, data := {}, notify := true) -> ProtonNode:
	var new_node: ProtonNode = NodeFactory.create(type_id)
	if not new_node:
		return null

	if "name" in data:
		new_node.unique_name = data.name
		data.erase("name")
	else:
		new_node.unique_name = _get_unique_name(new_node)

	new_node.external_data = data

	nodes[new_node.unique_name] = new_node
	new_node.graph = self
	new_node.changed.connect(_on_node_changed.bind(new_node))

	if new_node.leaf_node:
		_leaf_nodes.push_back(new_node)

	if notify:
		graph_changed.emit()

	return new_node


func delete_node(node: ProtonNode) -> void:
	# Remove the node from the list
	nodes.erase(node.unique_name)

	# Remove every related connections to this node
	var i := 0
	while i < connections.size():
		var c: Dictionary = connections[i]
		if c.from == node.unique_name or c.to == node.unique_name:
			connections.erase(c)
		else:
			i += 1

	graph_changed.emit()


func connect_node(from: String, from_idx: String, to: String, to_idx: String) -> void:
	var c := {}
	c.from = from
	c.from_idx = from_idx
	c.to = to
	c.to_idx = to_idx
	connections.push_back(c)
	graph_changed.emit()


func disconnect_node(from: String, from_idx: String, to: String, to_idx: String) -> void:
	for c in connections:
		if c.from == from and c.from_idx == from_idx and c.to == to and c.to_idx == to_idx:
			connections.erase(c) # Okay to erase in a for loop because we break right after
			break
	graph_changed.emit()


# Update the local value of inputs pinned to the graph inspector.
# Pinned variable names as keys, variables values as dictionary values.
func override_pinned_variables_values(parameters: Dictionary) -> void:
	if parameters.is_empty():
		return

	for node_name in nodes.keys():
		var node: ProtonNode = nodes[node_name]
		if not "pinned" in node.external_data:
			continue

		var ext_data: Dictionary = node.external_data["pinned"]

		for idx in ext_data.keys():
			var pinned_name = ext_data[idx]
			if pinned_name in parameters:
				node.inputs[idx].local_value = parameters[pinned_name]


func rebuild(clean_rebuild := false) -> void:
	if Settings.get_value(Settings.DISABLE_MULTITHREADING, false):
		_rebuild(clean_rebuild)
		return

	if _rebuild_queued:
		return

	if _is_thread_running():
		_rebuild_queued = true
		return

	if _is_thread_joinable():
		_thread.wait_to_finish()

	_thread = Thread.new()
	_thread.start(_rebuild.bind(clean_rebuild), Thread.PRIORITY_NORMAL)
	rebuild_started.emit()


func _rebuild(clean_rebuild := false) -> void:
	if clean_rebuild:
		for node in nodes.values():
			node.clear_values()

	# Cleanup both trees
	NodeUtil.remove_children(input_tree)
	NodeUtil.remove_children(output_tree)

	# TODO - Optimization: split the loop in half, merge all paths, remove
	# duplicates from the end, traverse the path once instead of how many
	# leaves there are.
	for leaf in _leaf_nodes:
		# Compute the leaf node dependency graph traversal path.
		var path: Array[ProtonNode] = [leaf]
		var dependencies := _get_left_connected_flat(leaf)
		var next: Array[ProtonNode] = []

		while not dependencies.is_empty():
			next.clear()
			for dep in dependencies:
				path.push_front(dep)
				next.append_array(_get_left_connected_flat(dep))
			dependencies = next.duplicate(false)

		# Generate outputs from the begining
		for node in path:
			if not node.is_output_ready():
				node._generate_outputs()

				# Push the computed outputs on the next nodes
				for idx in node.outputs:
					for data in _get_right_connected(node, idx):
						var value = node.outputs[idx].get_computed_value_copy()
						var right_node: ProtonNode = data.to
						right_node.set_input(data.idx, value)

	thread_completed.emit()


func _is_thread_running() -> bool:
	return _thread != null and _thread.is_alive()


func _is_thread_joinable() -> bool:
	return _thread != null and _thread.is_started() and not _thread.is_alive()


func _get_unique_name(node: ProtonNode) -> String:
	var unique_name := node.type_id
	var counter := 0

	while unique_name in nodes:
		counter += 1
		unique_name = node.type_id + str(counter)

	return unique_name


func _get_left_connected_flat(node: ProtonNode, idx: String = "") -> Array[ProtonNode]:
	var res: Array[ProtonNode] = []

	for c in connections:
		if c.to != node.unique_name:
			continue

		if idx.is_empty() or idx == c.to_idx:
			var n = nodes[c.from]
			if not n in res:
				res.push_back(nodes[c.from])

	return res


func _get_right_connected_flat(node: ProtonNode, idx: String = "") -> Array[ProtonNode]:
	var res: Array[ProtonNode] = []

	for c in connections:
		if c.from == node.unique_name:
			if idx.is_empty() or idx == c.from_idx:
				res.push_back(nodes[c.from])

	return res


func _get_right_connected(node: ProtonNode, idx: String) -> Array[Dictionary]:
	var res: Array[Dictionary] = []

	for c in connections:
		if c.from == node.unique_name and idx == c.from_idx:
			res.push_back({
				"to": nodes[c.to],
				"idx": c.to_idx
			})

	return res


# TODO: should recursively invalidate everything on the right side of the connected slots
func _on_node_changed(node: ProtonNode) -> void:
	node.clear_values()

	for n in _get_right_connected_flat(node):
		n.clear_values()

	graph_changed.emit()


func _on_graph_changed() -> void:
	pending_changes = true


# Restart the build process if another rebuild was requested before this one finished.
func _on_thread_completed() -> void:
	if _rebuild_queued:
		_rebuild_queued = false
		rebuild.call_deferred()
	else:
		rebuild_completed.emit()
