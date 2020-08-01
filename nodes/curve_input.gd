tool
class_name ConceptGraphCurveInput
extends Path


signal input_changed


func _ready() -> void:
	add_user_signal("input_changed", [{"name": "Node", "type": "Node"}])
	connect("curve_changed", self, "_on_curve_changed")


func _notification(type: int):
	if type == NOTIFICATION_TRANSFORM_CHANGED:
		_on_curve_changed()


func add_child(node, legible_unique_name := false) -> void:
	.add_child(node, legible_unique_name)
	if node is Path:
		node.connect("curve_changed", self, "_on_curve_changed")


func _on_curve_changed() -> void:
	emit_signal("input_changed", self)
