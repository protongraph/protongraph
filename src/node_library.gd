tool
extends Node

class_name ConceptNodeLibrary

"""
This script parses the node folder to retrieve a list of all the available ConceptNodes
"""

var _nodes: Array


func refresh() -> void:
	_nodes = []
	_find_all_nodes("./nodes")
	print(_nodes)


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
		var object = load(full_path)
		if object is ConceptNode:
			_nodes.append(full_path)

	dir.list_dir_end()
