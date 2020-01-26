tool
extends ConceptNode

class_name ConceptNodeSpawnSingle

"""
Spawns a single node in the graph
"""


var _node_label: LineEdit


func _ready() -> void:
	set_slot(0,
		false, 0, Color(0),
		true, ConceptGraphDataType.SPATIAL_SINGLE, ConceptGraphColor.SPATIAL_SINGLE)
	resizable = false

	_node_label = LineEdit.new()
	_node_label.text = "Spatial"
	add_child(_node_label)


func get_name() -> String:
	return "Spawn Node"


func get_category() -> String:
	return "Nodes"


func get_description() -> String:
	return "Spawns a node in the graph"
