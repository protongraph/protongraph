tool
extends GraphEdit

class_name ConceptGraphTemplate

"""
Load and edit graph templates. The internal graph is then stored back in the template file.
"""


signal graph_changed
signal simulation_outdated

var _output_node: ConceptNodeOutput
var _selected_node: GraphNode


func _ready() -> void:
	_setup_gui()
	connect("connection_request", self, "_on_connection_request")
	connect("disconnection_request", self, "_on_disconnection_request")
	connect("node_selected", self, "_on_node_selected")
	connect("_end_node_move", self, "_on_node_changed")


func load_from_file(path: String) -> void:
	_reset_editor_view()
	var file = File.new()
	file.open(path, File.READ)
	var graph: Dictionary = JSON.parse(file.get_line()).result
	if not graph.has("nodes"):
		return

	for node in graph["nodes"]:
		var node_instance = load(node["type"]).new()
		node_instance.name = node["name"]
		node_instance.restore_editor_data(node["editor"])
		node_instance.restore_custom_data(node["data"])
		_connect_node_signals(node_instance)
		add_child(node_instance)

	for c in graph["connections"]:
		connect_node(c["from"], c["from_port"], c["to"], c["to_port"])


func save_to_file(path: String) -> void:
	var graph := {}
	graph["connections"] = get_connection_list()
	graph["nodes"] = []

	for c in get_children():
		if c is ConceptNode:
			var node = {}
			node["name"] = c.get_name()
			node["type"] = c.get_script().resource_path
			node["editor"] = c.export_editor_data()
			node["data"] = c.export_custom_data()
			graph["nodes"].append(node)

	print("graph saved")
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_line(to_json(graph))
	file.close()


func create_node(node: ConceptNode, emit := true) -> ConceptNode:
	var new_node: ConceptNode = node.duplicate()
	new_node.offset = scroll_offset + Vector2(250, 150)
	_connect_node_signals(new_node)
	add_child(new_node)

	if emit:
		emit_signal("graph_changed")
		emit_signal("simulation_outdated")

	return new_node


func delete_node(node) -> void:
	_disconnect_node_signals(node)
	remove_child(node)
	node.queue_free()
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
	update()


func get_output() -> Spatial:
	return _output_node.get_output(0)


func _setup_gui() -> void:
	right_disconnects = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	anchor_right = 1.0
	anchor_bottom = 1.0


func _reset_editor_view() -> void:
	clear_connections()
	for c in get_children():
		if c is GraphNode:
			remove_child(c)
			c.queue_free()


func _connect_node_signals(node) -> void:
	node.connect("node_changed", self, "_on_node_changed")
	node.connect("delete_node", self, "delete_node")


func _disconnect_node_signals(node) -> void:
	node.disconnect("node_changed", self, "_on_node_changed")
	node.disconnect("delete_node", self, "delete_node")


func _on_node_selected(node: GraphNode) -> void:
	_selected_node = node


func _on_node_changed() -> void:
	emit_signal("graph_changed")


func _on_connection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	connect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")


func _on_disconnection_request(from_node: String, from_slot: int, to_node: String, to_slot: int) -> void:
	disconnect_node(from_node, from_slot, to_node, to_slot)
	emit_signal("graph_changed")
	emit_signal("simulation_outdated")
