tool
class_name ConceptBoxInput
extends Spatial


signal input_changed

export var size: Vector3


func _ready() -> void:
	pass


func _on_box_changed() -> void:
	emit_signal("input_changed", self)
