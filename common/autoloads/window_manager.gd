extends Node

# Handles external windows

signal window_created(String)
signal window_closed(String)


var _windows := {}


func has_window(id: String) -> bool:
	return id in _windows


func request_window(id: String) -> void:
	_get_or_create(id)


func close_window(id: String) -> void:
	if id in _windows:
		_on_close_requested(id)


func add_control_to(id: String, control: Control) -> void:
	var w := _get_or_create(id)
	var root = w.get_node("ContentRoot")
	NodeUtil.set_parent(control, root)
	if w.size == Vector2i.ZERO:
		w.size = control.size


func get_parent_window(node: Node) -> Window:
	if node is Window:
		return node

	if not node.is_inside_tree():
		return get_tree().get_root()

	return get_parent_window(node.get_parent())


func _get_or_create(id: String) -> Window:
	if id in _windows:
		return _windows[id]

	var w := Window.new()
	_windows[id] = w
	_add_default_ui(w, id)
	w.size = Vector2i.ZERO
	w.theme = ThemeManager.get_current_theme()
	w.close_requested.connect(_on_close_requested.bind(id))

	add_child(w)
	window_created.emit(id)
	return w


func _on_close_requested(id: String) -> void:
	var window: Window = _windows[id]
	NodeUtil.remove_children(window, false)
	_windows.erase(id)
	window.queue_free()
	window_closed.emit(id)


func _add_default_ui(window: Window, id: String) -> void:
	var panel_container := PanelContainer.new()
	panel_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	window.add_child(panel_container)

	var label := Label.new()
	label.set_text(id.capitalize())
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel_container.add_child(label)

	var root := MarginContainer.new()
	root.add_theme_constant_override("margin_top", 0)
	root.add_theme_constant_override("margin_bottom", 0)
	root.add_theme_constant_override("margin_left", 0)
	root.add_theme_constant_override("margin_right", 0)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.name = "ContentRoot"

	window.add_child(root, true)
