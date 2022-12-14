class_name EditorViewport
extends Control


var _output_root: Node3D = $SubViewportContainer/SubViewport/OutputRoot


func _ready() -> void:
	GlobalDirectory.register(self, "EditorViewport3D")


func clear() -> void:
	for c in _output_root.get_children():
		c.queue_free()


func display(output: Array) -> void:
	if not _output_root:
		return

	for node in output:
		if node is Node3D:
			_output_root.add_child(node)
