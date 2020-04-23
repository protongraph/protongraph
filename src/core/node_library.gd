tool
class_name ConceptNodeLibrary
extends Node

"""
This script parses the node folder to retrieve a list of all the available ConceptNodes
"""


var _nodes: Dictionary


func get_list() -> Dictionary:
	if not _nodes:
		refresh_list()
	return _nodes


func create_node(type: String) -> ConceptNode:
	if _nodes.has(type):
		return _nodes[type].duplicate()
	return null


func refresh_list() -> void:
	for node in _nodes.values():
		node.queue_free()
	_nodes = Dictionary()

	# Current folder path points at the root project from here so we can't feed the Directory object
	# with a relative path. Instead we get the script path and build an absolute path from there.
	# Writing res://addons/concept_graph/src/nodes isn't an option because the end user can rename
	# the plugin folder.
	var script_path = get_script().get_path()
	var nodes_dir = script_path.replace("node_library.gd", "") + "../nodes/"
	_find_all_nodes(nodes_dir)


"""
Recursively search all the scripts that inherits from ConceptNode and store them in the dictionnary
"""
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
		if not file.ends_with(".gd"):
			continue

		var full_path = path_root + file

		var node = load(full_path).new()
		var name = node.display_name
		var id = node.unique_id
		print("Loaded ", name, " (", file, ")")

		# ConceptNode is abstract, don't add it to the list
		if not (node is ConceptNode) or name == "ConceptNode":
			continue

		# If the interface is defined in a separate file, load it instead
		if node.has_custom_gui():
			node = load(path_root + file.replace(".gd", ".tscn")).instance()

		if _nodes.has(id):
			print("Warning: Node ", name, " has duplicate id ", full_path)
		else:
			_nodes[id] = node
	dir.list_dir_end()
