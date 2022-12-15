class_name NodeGraph
extends Resource


signal graph_changed


var nodes: Dictionary
var connections: Array
var save_file_path: String

var _leaf_nodes: Array[ProtonNode]


func _init():
	clear()


func clear() -> void:
	nodes = {}
	connections = []
	_leaf_nodes.clear()


func create_node(type_id: String, data := {}, notify := true) -> ProtonNode:
	var new_node: ProtonNode = NodeFactory.create(type_id)
	if not new_node:
		return null

	if "name" in data:
		new_node.unique_name = data.name
		data.erase("name") # TODO: check if this is required
	else:
		new_node.unique_name = _get_unique_name(new_node)

	new_node.external_data = data

	nodes[new_node.unique_name] = new_node
	new_node.graph = self
	new_node.changed.connect(_on_node_changed)

	if new_node.leaf_node:
		_leaf_nodes.push_back(new_node)

	if notify:
		graph_changed.emit()

	return new_node


func delete_node(node: ProtonNode) -> void:
	nodes.erase(node.unique_name)
	for c in connections:
		if c.from == node.unique_name or c.to == node.unique_name:
			connections.erase(c)
	graph_changed.emit()


func connect_node(from: StringName, from_idx, to: StringName, to_idx) -> void:
	var c := {}
	c.from = from
	c.from_idx = from_idx
	c.to = to
	c.to_idx = to_idx
	connections.push_back(c)


func disconnect_node(from: StringName, from_idx, to: StringName, to_idx) -> void:
	for c in connections:
		if c.from == from and c.from_idx == from_idx and c.to == to and c.to_idx == to_idx:
			connections.erase(c)
			return


func clean_rebuild() -> void:
	for node in nodes.values():
		node.clear_values()

	rebuild()


func rebuild() -> void:
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
			dependencies = next

		# Generate outputs from the begining
		for node in path:
			if not node.is_output_ready():
				node._generate_outputs()

			# Push the computed outputs on the next nodes
			for idx in node.outputs:
				var value = node.outputs[idx].get_computed_value_copy()

				for data in _get_right_connected(node, idx):
					var right_node: ProtonNode = data.to
					right_node.inputs[data.idx].computed_value = value
					right_node.inputs[data.idx].computed_value_ready = true


func _get_unique_name(node: ProtonNode) -> String:
	var unique_name := node.type_id
	var counter := 0

	while unique_name in nodes:
		counter += 1
		unique_name = node.type_id + str(counter)

	return unique_name


func _get_left_connected_flat(node: ProtonNode, idx = null) -> Array[ProtonNode]:
	var res: Array[ProtonNode] = []

	for c in connections:
		if c.to == node.unique_name:
			if idx == null or idx == c.to_idx:
				res.push_back(nodes[c.from])

	return res


func _get_right_connected(node: ProtonNode, idx) -> Array[Dictionary]:
	var res: Array[Dictionary] = []

	for c in connections:
		if c.from == node.unique_name and idx == c.from_idx:
			res.push_back({
				"to": nodes[c.to],
				"idx": c.to_idx
			})

	return res


func _on_node_changed() -> void:
	rebuild()
