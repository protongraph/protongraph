"""
The InputManager listen for changes in the Input nodes attached to the concept graph and notify
it to its parent so it can rerun the simulation in real time as changes happens. Right now
this is a naive approach where we reset the whole graph anytime something change but we may need
a way to only reset the associated Input node sometime in the future.
"""

tool
class_name ConceptGraphInputManager
extends Spatial


signal input_changed


func _ready() -> void:
	for c in get_children():
		if c.has_user_signal("input_changed"):
			c.connect("input_changed", self, "_on_input_changed")


func add_child(node, legible_unique_name = false) -> void:
	.add_child(node, legible_unique_name)
	if node.has_user_signal("input_changed"):
		node.connect("input_changed", self, "_on_input_changed")


func _on_input_changed(node) -> void:
	emit_signal("input_changed", node)
