extends Node


# This script parses the node folder to retrieve a list of all the
# available ProtonNodes.


var _nodes: Dictionary
var _node_search_index: Dictionary


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
	_nodes.clear()


func create(type_id: String) -> ProtonNode:
	if _node_search_index.is_empty():
		refresh_list()

	if type_id in _nodes:
		return _nodes[type_id].duplicate(true)

	return null


func refresh_list() -> void:
	clear()
	_node_search_index = Dictionary()
	_nodes = Dictionary()
	_find_all_nodes("res://nodes/")


# Recursively search all the scripts that inherits from ProtonNode and store
# them in the dictionnary
func _find_all_nodes(path) -> void:
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(false, true)
	var path_root = dir.get_current_dir() + "/"

	while true:
		var file = dir.get_next()
		if file == "":
			break

		if dir.current_is_dir():
			_find_all_nodes(path_root + file)
			continue

		if not file.ends_with(".gd") and not file.ends_with(".gdc"):
			continue

		var full_path = path_root + file
		var script = load(full_path)
		if not script:
			print("Error: Failed to load script ", file)
			continue

		var node = script.new()
		if not _is_node_valid(node):
			MemoryUtil.free(node)
			continue

		# If the interface is defined in a separate file, load it instead
		# TODO: Redo this later. It's not the ProtonNode responsibility to provide this info
#		if node.has_custom_gui():
#			var scene = load(path_root + file.replace(".gd", ".tscn"))
#			if not scene is PackedScene:
#				continue # Scene file does not exists
#			node = scene.instantiate()

		_nodes[node.type_id] = node
		_node_search_index[node.title] = node.type_id

	dir.list_dir_end()


func _is_node_valid(node) -> bool:
		if not node is ProtonNode:
			return false

		if node.ignore:
			return false

		# Abstract node, don't add this to the list
		if node.title == "ProtonNode":
			return false

		if _nodes.has(node.type_id):
			printerr("Node ", node.title, " has duplicate id ", node.get_script().resource_path)
			return false

		return true
