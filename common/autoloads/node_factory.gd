extends Node


# This script parses the node folder to retrieve a list of all the
# available ProtonNodes.

var _nodes: Dictionary
var _node_search_index: Dictionary


func _ready() -> void:
	refresh_list()


func _exit_tree() -> void:
	clear()


func get_available_nodes() -> Array:
	if _nodes.is_empty():
		refresh_list()
	return _nodes.values()


func get_index_list() -> Dictionary:
	if _node_search_index.is_empty():
		refresh_list()
	return _node_search_index


func clear() -> void:
	for type_id in _nodes:
		MemoryUtil.safe_free(_nodes[type_id])
	_nodes.clear()


func create(type_id: String) -> ProtonNode:
	if _node_search_index.is_empty():
		refresh_list()

	if type_id in _nodes:
		return _nodes[type_id].duplicate()

	push_error("Could not create a node of type ", type_id)
	return null


func refresh_list() -> void:
	clear()
	_node_search_index = Dictionary()
	_nodes = Dictionary()

	var node_path: String
	if OS.has_feature("editor"):
		node_path = "res://nodes/"
	else:
		node_path = OS.get_executable_path().get_base_dir().path_join("nodes")

	_find_all_nodes(node_path)


# Recursively search all the scripts that inherits from ProtonNode and store
# them in the dictionnary
func _find_all_nodes(path) -> void:
	var is_script_valid := func (node) -> bool:
		if not node is ProtonNode:
			return false

		if node.ignore:
			return false

		# Abstract node, don't add this to the list
		if node.title == "ProtonNode":
			return false

		if node.type_id in _nodes:
			printerr("Node ", node.title, " has duplicate id ", node.get_script().resource_path)
			return false

		return true

	var scripts := DirectoryUtil.get_all_valid_scripts_in(path, true)
	for script in scripts:
		var node = script.new()
		if not is_script_valid.call(node):
			MemoryUtil.safe_free(node)
			continue

		_nodes[node.type_id] = node
		_node_search_index[node.title] = node.type_id
