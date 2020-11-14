extends Spatial

signal node_added
signal node_removed


func add_child(node: Node, legible_unique_name := false) -> void:
	if not node:
		return
	.add_child(node, legible_unique_name)
	emit_signal("node_added", node)


func remove_child(node: Node) -> void:
	if not node:
		return
	.remove_child(node)
	emit_signal("node_removed", node)


func _on_node_added():
	pass # Replace with function body.
