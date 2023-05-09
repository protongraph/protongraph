class_name EditorViewport
extends Control


var _graph: NodeGraph
var _just_wrapped := false
var _node_to_preview: ProtonNode

@onready var _viewport: SubViewport = %SubViewport
@onready var _input_root: Node3D = %InputRoot
@onready var _output_root: Node3D = %OutputRoot
@onready var _preview_root: Node3D = %PreviewRoot
@onready var _camera: ViewportCamera = %ViewportCamera
@onready var _gizmos_manager: GizmosManager = %GizmosManager
@onready var _tree: Tree = %Tree
@onready var _rebuilding_panel: Control = %RebuildingPanel
@onready var _shading_button: Button = %ShadingButton
@onready var _shading_panel: ViewportShadingPanel = %ShadingPanel
@onready var _camera_light: DirectionalLight3D = %CameraLight
@onready var _static_light: DirectionalLight3D = %StaticLight


func _ready() -> void:
	%HelpButton.toggled.connect(_on_help_button_toggled)
	%ResetCameraButton.pressed.connect(_camera.reset_camera)
	_shading_button.toggled.connect(_on_shading_button_toggled)
	_shading_panel.debug_draw_selected.connect(_on_debug_draw_selected)
	_shading_panel.light_mode_selected.connect(_on_light_mode_selected)
	%HelpPanel.visible = false
	_shading_panel.visible = false
	_camera_light.visible = false

	GlobalEventBus.preview_on_viewport.connect(_on_preview_requested)


func clear_all() -> void:
	NodeUtil.remove_children(_input_root)
	NodeUtil.remove_children(_output_root)
	_gizmos_manager.clear()
	_tree.update()


func clear_preview() -> void:
	NodeUtil.remove_children(_preview_root)
	_gizmos_manager.clear()
	_node_to_preview = null
	show_scene_trees()
	_tree.update()


func show_scene_trees() -> void:
	clear_all()
	for node in _graph.output_tree.get_children():
		NodeUtil.set_parent(node.duplicate(), _output_root, true)
		_gizmos_manager.add_gizmo_for(node)

	_input_root.visible = true
	_output_root.visible = true
	_preview_root.visible = false
	_tree.update()


func show_preview(pnode: ProtonNode) -> void:
	if not is_instance_valid(pnode):
		_node_to_preview = null
		show_scene_trees()
		return

	# Get the provided 3D data
	var data_to_preview: Array[Node3D] = pnode._get_preview_3d()

	# If the node doesn't explicitely provide preview data, scan all the outputs for 3D nodes.
	if data_to_preview.is_empty():
		for idx in pnode.outputs.keys():
			for item in pnode.outputs[idx].get_computed_value_copy():
				if item is Node3D:
					data_to_preview.push_back(item)

	# No 3D nodes found, cancel preview
	if data_to_preview.is_empty():
		clear_preview()
		return

	_gizmos_manager.clear()
	for node in data_to_preview:
		NodeUtil.set_parent(node.duplicate(), _preview_root, true)
		_gizmos_manager.add_gizmo_for(node)

	_input_root.visible = false
	_output_root.visible = false
	_preview_root.visible = true
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

	if not is_visible_in_tree():
		return

	var current_mouse_pos := get_viewport().get_mouse_position()
	var rect = Rect2i(global_position, size)

	if rect.has_point(current_mouse_pos):
		_camera.process_input(event)

	elif _camera.is_input_captured() and event is InputEventMouseMotion:
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
	%HelpPanel.visible = pressed


func _on_rebuild_started() -> void:
	_rebuilding_panel.visible = true


# Node graph is done rebuilding the scene, display the queued results.
func _on_rebuild_completed() -> void:
	clear_all()
	_rebuilding_panel.visible = false

	if _node_to_preview:
		show_preview(_node_to_preview)
	else:
		show_scene_trees()


func _on_shading_button_toggled(enabled: bool) -> void:
	_shading_panel.visible = enabled


func _on_debug_draw_selected(draw_mode) -> void:
	_viewport.debug_draw = draw_mode


func _on_light_mode_selected(follow: bool) -> void:
	_camera_light.visible = follow
	_static_light.visible = not follow


func _on_preview_requested(graph: NodeGraph, pnode: ProtonNode) -> void:
	if _graph != graph:
		return

	if not pnode: # Cancel preview
		clear_preview()
		return

	_node_to_preview = pnode
	show_preview(pnode)
