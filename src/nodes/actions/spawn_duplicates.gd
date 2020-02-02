tool
extends ConceptNode

class_name ConceptNodeSpawnDuplicates

"""
Spawns many copies of a node at the specified positions and returns an array of nodes.
"""


func _ready() -> void:
	# node_source, output
	set_slot(0,
		true, ConceptGraphDataType.NODE_SINGLE, ConceptGraphColor.NODE_SINGLE,
		true, ConceptGraphDataType.NODE_ARRAY, ConceptGraphColor.NODE_ARRAY)

	# positions
	set_slot(1,
		true, ConceptGraphDataType.TRANSFORM_ARRAY, ConceptGraphColor.TRANSFORM_ARRAY,
		false, 0, Color(0))


func get_node_name() -> String:
	return "Spawn Duplicates"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Spawns many copies of a node at the specified positions and returns an array of nodes"


func has_custom_gui() -> bool:
	return true


func get_output(idx: int) -> Array:
	print("In spawn duplicates get_output")
	var source = get_input(0)
	print("Source node : ", source)
	var transforms = get_input(1)
	print("Transforms : ", transforms)
	if not source or not transforms:
		return [] #No valid source node or positions array provided
	
	print(transforms.size(), " tranforms found from input 1")
	var nodes = []
	for t in transforms:
		var n = source.duplicate() as Spatial
		n.global_transform = t
		nodes.append(n)
	print(nodes.size(), " nodes generated")
	return nodes


func _clear_cache() -> void:
	for n in _cache[0]:
		n.queue_free()
