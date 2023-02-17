class_name NodeGraph
extends Resource


signal graph_changed


var nodes: Dictionary
var connections: Array
var save_file_path: String
var external_data: Dictionary
var pending_changes := false

var _leaf_nodes: Array[ProtonNode]
var _thread := Thread.new()
var _rebuild_queued := false


func _init():
	clear()
	graph_changed.connect(_on_graph_changed)


func clear() -> void:
	nodes = {}
	connections = []
	external_data = {}
	_leaf_nodes.clear()


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


func rebuild(clean_rebuild := false) -> void:
	if is_thread_running():
		_rebuild_queued = true
		return

	if _thread and _thread.is_started():
		_thread.wait_to_finish()

	_thread = Thread.new()
	_thread.start(_rebuild.bind(clean_rebuild), Thread.PRIORITY_NORMAL)


func _rebuild(clean_rebuild := false) -> void:
	if clean_rebuild:
		for node in nodes.values():
			node.clear_values()

	# TODO: split the loop in half, merge all paths, remove duplicates from the
	# end, traverse the path once instead of how many leaves there are.
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

	_on_rebuild_completed.call_deferred()


func is_thread_running() -> bool:
	return _thread != null and _thread.is_alive()


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


func _on_node_changed(node: ProtonNode) -> void:
	node.clear_values()

	for n in _get_right_connected_flat(node):
		n.clear_values()

	graph_changed.emit()


func _on_graph_changed() -> void:
	pending_changes = true


# Restart the build process if another rebuild was requested before this one finished.
func _on_rebuild_completed() -> void:
	if _rebuild_queued:
		_rebuild_queued = false
		rebuild()
