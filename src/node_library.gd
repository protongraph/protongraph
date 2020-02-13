tool
extends Node

class_name ConceptNodeLibrary

"""
This script parses the node folder to retrieve a list of all the available ConceptNodes
"""

var _nodes: Dictionary


func get_list() -> Dictionary:
	if not _nodes:
		refresh_list()
	return _nodes


func refresh_list() -> void:
	_nodes = Dictionary() # Do we manually free() the stored nodes or is it done automatically ?
	_find_all_nodes("res://addons/concept_graph/src/nodes/") # TODO: Find why relative paths doesn't work


func _find_all_nodes(path) -> void:
	"""
	Recursively search for all the scripts that inherits the ConceptNode base class and store
	them in the _nodes variable
	"""
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
		print("Loading ", file)
		var node = load(full_path).new()
		var name = node.node_title

		# ConceptNode is abstract, don't add it to the list
		if not (node is ConceptNode) or name == "ConceptNode":
			continue

		# If the interface is defined in a separate file, load it instead
		if node.has_custom_gui():
			node = load(path_root + file.replace(".gd", ".tscn")).instance()

		_nodes[name] = node
	dir.list_dir_end()
