"""
Spawns many copies of a node at the specified positions and returns an array of nodes.
"""

tool
class_name ConceptNodeSpawnDuplicates
extends ConceptNode


func _init() -> void:
	set_input(0, "Source", ConceptGraphDataType.NODE)
	set_input(1, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_output(0, "Duplicates", ConceptGraphDataType.NODE)


func get_node_name() -> String:
	return "Spawn Duplicates"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Spawns many copies of a node at the specified positions and returns an array of nodes"


func get_output(idx: int) -> Array:
	var source = get_input(0)
	var transforms = get_input(1)
	if not source or not transforms:
		return [] #No valid source node or positions array provided

	var nodes = []
	for t in transforms:
		var n = source.duplicate() as Spatial
		n.global_transform = t
		nodes.append(n)
	return nodes


func _clear_cache() -> void:
	if not _cache.has("0"):
		return
	for n in _cache["0"]:
		n.queue_free()
