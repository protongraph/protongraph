extends Control
class_name EditorViewport


signal scene_updated


onready var _viewport: Viewport = $MarginContainer/ViewportContainer/Viewport
onready var _input_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Input
onready var _output_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Output
onready var _camera_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Pivot
onready var _camera_light: Light = $MarginContainer/ViewportContainer/Viewport/Pivot/Camera/DirectionalLight
onready var _static_light: Light = $MarginContainer/ViewportContainer/Viewport/Lighting/DirectionalLight
onready var _legend: Control = $MarginContainer/ViewportUI/HBoxContainer/LeftColumn/Legend


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
