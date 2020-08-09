extends ViewportContainer


signal scene_updated


export var input_root: NodePath
export var output_root: NodePath
export var camera_root: NodePath
export var static_light: NodePath
export var camera_light: NodePath
export var legend: NodePath

var _viewport: Viewport
var _input_root: Spatial
var _output_root: Spatial
var _camera_root: Spatial
var _camera_light: Light
var _static_light: Light
var _legend: Control


func _ready() -> void:
	_output_root = get_node(output_root)
	_input_root = get_node(input_root)
	_camera_root = get_node(camera_root)
	_camera_light = get_node(camera_light)
	_static_light = get_node(static_light)
	_viewport = get_node("Viewport")
	_legend = get_node(legend)


func add_input_node(node: Spatial) -> void:
	var parent = node.get_parent()
	if parent:
		parent.remove_child(node)

	Signals.safe_connect(node, "input_changed", self, "_on_input_changed")
	_input_root.add_child(node)
	emit_signal("scene_updated")


func remove_input_node(node: Spatial) -> void:
	_input_root.remove_child(node)
	Signals.safe_disconnect(node, "input_changed", self, "_on_input_changed")
	emit_signal("scene_updated")


func display(nodes: Array) -> void:
	for c in _output_root.get_children():
		_output_root.remove_child(c)
		c.queue_free()

	for node in nodes:
		_output_root.add_child(node, true)
	emit_signal("scene_updated")


func enable_static_light() -> void:
	_static_light.visible = true
	_camera_light.visible = false


func enable_camera_light() -> void:
	_static_light.visible = false
	_camera_light.visible = true


func set_normal_display() -> void:
	_viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED


func set_wireframe_display() -> void:
	_viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME


func display_legend(val) -> void:
	_legend.visible = val


func _on_input_changed(_input) -> void:
	emit_signal("scene_updated")
