extends Node


# The SceneTreeManager handles the graphs input and output trees.
#
# This class does NOT operate on SceneTree objects, but regular Node3D.
#
# + The input tree is a collection of input nodes (the ones directly manipulated
#   by the user). These nodes are automatically added to the input tree.
#
# + The output tree is a collection of nodes generated by the graph that were
#   explictely added to the tree. If the user does not add a node to the tree,
#   it won't be displayed, or taken account by physics operations in the case of
#   colliders.
#
# ProtonGraph can edit multiple graphs at once, so it's important to disable
# nodes from other graphs than the one being edited and build. Results might
# be wrong otherwise. (Raycast hitting colliders from other graphs, etc).


var _active_tree: Node3D


func _ready() -> void:
	pass


func get_editor_scene_tree() -> SceneTree:
	return get_tree()


func add_to_tree(graph: NodeGraph, node: Node3D, is_input := false) -> void:
	if not is_instance_valid(node):
		return

	if not is_instance_valid(graph.input_tree):
		graph.input_tree = Node3D.new()

	if not is_instance_valid(graph.output_tree):
		graph.output_tree = Node3D.new()

	var root: Node3D = graph.input_tree if is_input else graph.output_tree
	root.add_child(node)
	node.set_owner(root)
