class_name EditorViewport
extends Control


@onready var _output_root: Node3D = $%OutputRoot
@onready var _camera: ViewportCamera = $%ViewportCamera
@onready var _gizmos_manager: GizmosManager = $%GizmosManager
@onready var _tree: Tree = $%Tree

var _just_wrapped := false


func _ready() -> void:
	GlobalEventBus.show_on_viewport.connect(display)
	$%HelpButton.toggled.connect(_on_help_button_toggled)
	$%ResetCameraButton.pressed.connect(_camera.reset_camera)
	$%HelpPanel.visible = false


func clear() -> void:
	NodeUtil.remove_children(_output_root)
	_gizmos_manager.clear()
	_tree.update()


func display(list: Array) -> void:
	if not _output_root or not is_visible_in_tree():
		return

	for node in list:
		if is_instance_valid(node) and node is Node3D:
			_output_root.add_child(node)
			_gizmos_manager.add_gizmo_for(node)
		else:
			list.erase(node)

	_tree.update()


# Forward all inputs happening on top of this viewport to the camera node.
# Handle mouse wrapping when appropriate
func _input(event: InputEvent) -> void:
	if _just_wrapped:
		_just_wrapped = false
		return

	var current_mouse_pos := get_viewport().get_mouse_position()
	var rect = Rect2i(global_position, size)

	if rect.has_point(current_mouse_pos):
		_camera.process_input(event)

	elif _camera.is_input_captured():
		var margin := 2.0
		var local_pos: Vector2 = event.position - global_position

		if local_pos.x < 0 + margin:
			local_pos.x = size.x - margin

		if local_pos.x > size.x - margin:
			local_pos.x = 0 + margin

		if local_pos.y < 0 + margin:
			local_pos.y = size.y - margin

		if local_pos.y > size.y - margin:
			local_pos.y = 0 + margin

		warp_mouse(local_pos)
		_just_wrapped = true
		_camera.process_input(event)


func _on_help_button_toggled(pressed: bool) -> void:
	$%HelpPanel.visible = pressed
