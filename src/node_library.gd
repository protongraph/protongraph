tool
extends Node

class_name ConceptNodeLibrary

"""
This script parses the node folder to retrieve a list of all the available ConceptNodes
"""

var _nodes: Array


func get_list() -> Array:
	if not _nodes:
		refresh_list()
	return _nodes


func refresh_list() -> void:
	_nodes = [] # Do we manually free() the stored nodes or is it done automatically ?
	_find_all_nodes("res://addons/concept_graph/src/nodes") # TODO: Find why relative paths doesn't work
	_nodes.sort()


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
		var node = load(full_path).new()
		if node is ConceptNode:
			_nodes.append(node)

	dir.list_dir_end()
