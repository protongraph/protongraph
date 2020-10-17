extends GraphNode
class_name GenericNodeUi


var ref: ConceptNode
var requires_full_gui_rebuild := false


func _ready() -> void:
	pass


func create_from(node: ConceptNode) -> void:
	ref = node
