extends CustomGraphEdit
class_name TemplateEditor



func _ready():
	pass # Replace with function body.


func load_template(path: String) -> void:
	pass


func _on_create_node(node_id):
	var graphnode = NodeFactory.create_graph_node(node_id)
	add_child(graphnode)
