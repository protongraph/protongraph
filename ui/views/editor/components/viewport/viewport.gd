class_name EditorViewport
extends Control


@onready var _output_root: Node3D = $SubViewportContainer/SubViewport/OutputRoot
@onready var _camera: ViewportCamera = $SubViewportContainer/SubViewport/ViewportCamera
@onready var _gizmos_manager: GizmosManager = $%GizmosManager


func _ready() -> void:
	GlobalEventBus.show_on_viewport.connect(display)


func clear() -> void:
	NodeUtil.remove_children(_output_root)
	_gizmos_manager.clear()


func display(list: Array) -> void:
	if not _output_root or not is_visible_in_tree():
		return

	for node in list:
		if node is Node3D:
			_output_root.add_child(node)
			_gizmos_manager.add_gizmo_for(node)


# Forward all inputs happening on top of this viewport to the camera node.
func _input(event: InputEvent) -> void:
	var current_mouse_pos := get_viewport().get_mouse_position()
	var rect = Rect2i(global_position, size)
	if rect.has_point(current_mouse_pos):
		_camera.process_input(event)
