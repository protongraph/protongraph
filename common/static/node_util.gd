class_name NodeUtil
extends RefCounted


# Get child node of a specific type. If multiple children share the same class,
# use the counter parameter to specific which one to return. (Index starts at 1)
static func get_child_by_class(node: Node, child_class: String, counter: int = 1) -> Node:
	var match_counter = 0

	for child in node.get_children():
		if child.get_class() == child_class:
			match_counter += 1
		if match_counter == counter:
			return child

	return null


static func get_child_by_name(node: Node, child_name: String) -> Node:
	for child in node.get_children():
		if child.name == child_name:
			return child

	return null


# Remove all children of a given node and free them by default.
static func remove_children(node: Node, free := true) -> void:
	if not node:
		return

	for child in node.get_children():
		node.remove_child(child)
		if free:
			child.queue_free()


static func remove_parent(node: Node) -> void:
	var parent = node.get_parent()
	if parent:
		parent.remove_child(node)


static func set_parent(node: Node, new_parent: Node, force_legible_name := false) -> void:
	remove_parent(node)
	new_parent.add_child(node, force_legible_name)
