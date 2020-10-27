extends PanelContainer
class_name NodeSidebar


var _current: ConceptNode

onready var _default: Control = $DefaultContent


func set_node(node: ConceptNode) -> void:
	if not node:
		return
		
	clear()
	_current = node
	_rebuild_ui()


func clear() -> void:
	for c in get_children():
		c.queue_free()
	_current = null


func toggle() -> void:
	visible = !visible


func _rebuild_ui() -> void:
	
	pass
