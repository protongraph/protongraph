extends Control
class_name EditorViewport


signal scene_updated


onready var _viewport: Viewport = $MarginContainer/ViewportContainer/Viewport
onready var _input_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Input
onready var _output_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Output
onready var _camera_root: Spatial = $MarginContainer/ViewportContainer/Viewport/Pivot
onready var _camera_light: Light = $MarginContainer/ViewportContainer/Viewport/Pivot/Camera/DirectionalLight
onready var _static_light: Light = $MarginContainer/ViewportContainer/Viewport/Lighting/DirectionalLight
onready var _help_panel: Control = $MarginContainer/ViewportUI/HBoxContainer/LeftColumn/HelpPanel
onready var _overlay = $MarginContainer/ViewportUI/HBoxContainer/RightColumn/MonitorOverlay


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


func set_normal_display() -> void:
	_viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED


func set_wireframe_display() -> void:
	_viewport.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME


func _on_input_changed(_input) -> void:
	emit_signal("scene_updated")


func _on_show_help_panel(val) -> void:
	_help_panel.visible = val


func _on_show_fps(val):
	_overlay.fps = val
	_overlay.rebuild_ui()


func _on_use_static_light(val):
	_static_light.visible = val
	_camera_light.visible = not val
