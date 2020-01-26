tool
extends ConceptNode

class_name ConceptNodeSpawnDuplicates

"""
Spawns many copies of a node at the specified positions and returns an array of nodes.
"""


func _ready() -> void:
	# node_source, output
	set_slot(0,
		true, ConceptGraphDataType.SPATIAL_SINGLE, ConceptGraphColor.SPATIAL_SINGLE,
		true, ConceptGraphDataType.SPATIAL_ARRAY, ConceptGraphColor.SPATIAL_ARRAY)

	# positions
	set_slot(1,
		true, ConceptGraphDataType.POINT_ARRAY, ConceptGraphColor.POINT_ARRAY,
		false, 0, Color(0))


func get_name() -> String:
	return "Spawn Duplicates"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Spawns many copies of a node at the specified positions and returns an array of nodes"


func has_custom_gui() -> bool:
	return true
