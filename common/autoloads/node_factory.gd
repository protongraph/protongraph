extends Node


# This script parses the node folder to retrieve a list of all the
# available ProtonNodes.


var _nodes: Dictionary
var _node_search_index: Dictionary


func _exit_tree() -> void:
	clear()


func get_available_nodes() -> Array:
	if not _nodes:
		refresh_list()
	return _nodes.values()


func get_index_list() -> Dictionary:
	if not _node_search_index:
		refresh_list()
	return _node_search_index


func clear() -> void:
	for node in _nodes.values():
		node.queue_free()


func create(type: String) -> ProtonNode:
	if not _node_search_index:
		refresh_list()

	if _nodes.has(type):
		return _nodes[type].duplicate(7)

	return null


func refresh_list() -> void:
	_node_search_index = Dictionary()
	clear()
	_nodes = Dictionary()
	_find_all_nodes("res://nodes/")


# Recursively search all the scripts that inherits from ProtonNode and store
# them in the dictionnary
func _find_all_nodes(path) -> void:
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin(true, true)
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
		if not script or not script.can_instance():
			print("Error: Failed to load script ", file)
			continue

		var node = script.new()
		if not node is ProtonNode:
			continue

		if node.ignore:
			node.queue_free()
			continue

		var name = node.display_name
		var id = node.unique_id

		# ProtonNode is abstract, don't add it to the list
		if not (node is ProtonNode) or name == "ProtonNode":
			continue

		# If the interface is defined in a separate file, load it instead
		if node.has_custom_gui():
			var scene = load(path_root + file.replace(".gd", ".tscn"))
			if not scene is PackedScene:
				continue # Scene file does not exists
			node = scene.instance()

		if _nodes.has(id):
			print("Warning: Node ", name, " has duplicate id ", full_path)
		else:
			node.name = id
			_nodes[id] = node
			_node_search_index[node.display_name] = id

	dir.list_dir_end()
