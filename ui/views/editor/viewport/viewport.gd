class_name EditorViewport
extends Control


var _graph: NodeGraph
var _just_wrapped := false
var _display_queue: Array[Node3D] = []

@onready var _output_root: Node3D = $%OutputRoot
@onready var _camera: ViewportCamera = $%ViewportCamera
@onready var _gizmos_manager: GizmosManager = $%GizmosManager
@onready var _tree: Tree = $%Tree
@onready var _rebuilding_panel: Control = $%RebuildingPanel


func _ready() -> void:
	GlobalEventBus.show_on_viewport.connect(_on_show_on_viewport)
	$%HelpButton.toggled.connect(_on_help_button_toggled)
	$%ResetCameraButton.pressed.connect(_camera.reset_camera)
	$%HelpPanel.visible = false


func clear() -> void:
	_display_queue.clear()
	NodeUtil.remove_children(_output_root)
	_gizmos_manager.clear()
	_tree.update()


func set_node_graph(graph: NodeGraph) -> void:
	if _graph:
		_graph.rebuild_started.disconnect(_on_rebuild_started)
		_graph.rebuild_completed.disconnect(_on_rebuild_completed)

	_graph = graph
	_graph.rebuild_started.connect(_on_rebuild_started)
	_graph.rebuild_completed.connect(_on_rebuild_completed)
	_rebuilding_panel.visible = false


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


# Called from the GlobalEventBus, if the request matches the currently edited graph,
# store the requested nodes in a queue and display them once the rebuild is complete.
func _on_show_on_viewport(graph: NodeGraph, list: Array) -> void:
	if graph != _graph:
		return

	_display_queue.append_array(list)


func _on_rebuild_started() -> void:
	_display_queue.clear()
	_rebuilding_panel.visible = true


# Node graph is done rebuilding the scene, display the queued results.
func _on_rebuild_completed() -> void:
	NodeUtil.remove_children(_output_root)
	_gizmos_manager.clear()

	for node in _display_queue:
		if is_instance_valid(node) and node is Node3D:
			NodeUtil.set_parent(node, _output_root, true)
			_gizmos_manager.add_gizmo_for(node)

	_tree.update()
	_display_queue.clear()
	_rebuilding_panel.visible = false
