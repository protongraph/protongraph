class_name EditorViewport
extends Control


@onready var _output_root: Node3D = $SubViewportContainer/SubViewport/OutputRoot


func _ready() -> void:
	GlobalEventBus.show_on_viewport.connect(display)


func clear() -> void:
	NodeUtil.remove_children(_output_root)


func display(output: Array) -> void:
	if not _output_root:
		return

	for node in output:
		if node is Node3D:
			_output_root.add_child(node)
