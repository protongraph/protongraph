extends CustomGraphEdit
class_name TemplateEditor



func _ready():
	pass # Replace with function body.


func load_template(path: String) -> void:
	pass


func create_node(type, data, notify := true):
	var node: GenericNodeUi = NodeFactory.create_graph_node(type)
	if not node:
		return
	
	node.inline_vectors = Settings.get_setting(Settings.INLINE_VECTOR_FIELDS)
	add_child(node)
	node.regenerate_default_ui()
	connect_node_signals(node)
	
	# Make sure the new node is within the view
	if data.has("offset"):
		node.offset = data["offset"]
	else:
		node.offset = scroll_offset + Vector2(250, 150)
	
	if data.has("name"):
		node.name = data["name"]
	if data.has("editor"):
		node.restore_editor_data(data["editor"])
	if data.has("data"):
		node.restore_custom_data(data["data"])

	if notify:
		emit_signal("graph_changed")
		emit_signal("simulation_outdated")


func _on_node_changed(node: GraphNode, force_regeneration := false) -> void:
	pass
