extends ViewportContainer


signal scene_updated


export var root: NodePath
export var camera_root: NodePath
export var static_light: NodePath
export var camera_light: NodePath
export var legend: NodePath

var _viewport: Viewport
var _root: Spatial
var _camera_root: Spatial
var _camera_light: Light
var _static_light: Light
var _legend: Control


func _ready() -> void:
	_root = get_node(root)
	_camera_root = get_node(camera_root)
	_camera_light = get_node(camera_light)
	_static_light = get_node(static_light)
	_viewport = get_node("Viewport")
	_legend = get_node(legend)


func _input(event: InputEvent) -> void:
	return
	_viewport.input(event.xformed_by(get_transform(), get_global_transform().origin))


func display(nodes: Array) -> void:
	for c in _root.get_children():
		_root.remove_child(c)
		c.queue_free()

	for node in nodes:
		_root.add_child(node, true)
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
