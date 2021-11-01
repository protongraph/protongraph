class_name NodeGraphEditor
extends GraphEdit


var _graph: NodeGraph
var _add_node_popup: Popup


func _ready() -> void:
	popup_request.connect(_show_add_node_popup)
	
	_add_node_popup = get_node("AddNodePopup")
	_add_node_popup.create_node_request.connect(_on_create_node_request)


func set_node_graph(graph: NodeGraph) -> void:
	_graph = graph


func clear() -> void:
	for c in get_children():
		c.queue_free()


# Creates the visual representation of the NodeGraph item.
func rebuild() -> void:
	clear()
	for n in _graph.nodes.values():
		var proton_node = n as ProtonNode
		var graph_node := GraphNode.new()
		add_child(graph_node)
		graph_node.name = proton_node.unique_name
		graph_node.title = proton_node.title
		graph_node.position_offset = proton_node.external_data.position
	
	for c in _graph.connections:
		pass


func _show_add_node_popup(position: Vector2) -> void:
	_add_node_popup.position = position
	_add_node_popup.popup()


func _on_create_node_request(node_type_id: String) -> void:
	var data = {
		"position": scroll_offset + Vector2(_add_node_popup.position)
	}
	_graph.create_node(node_type_id, data)
	rebuild()
	pass
