class_name ViewContainer
extends CustomTabContainer


func _ready() -> void:
	super()
	tab_closed.connect(_on_tab_closed)


func is_view_opened(type) -> bool:
	for c in get_children():
		if c is type:
			return true
	return false


func is_graph_loaded(path: String) -> bool:
	return _get_graph_index(path) != -1


func get_current_view() -> Control:
	return get_child(current_tab)


func focus_graph(path: String) -> void:
	var index = _get_graph_index(path)
	if index != -1:
		change_tab(index)


# Returns true if it could open the view, false otherwise
func focus_view(type) -> bool:
	for c in get_children():
		if c is type:
			change_tab(c.get_index())
			return true

	return false


func _get_graph_index(path: String) -> int:
	for c in get_children():
		if c is EditorView and c.get_edited_file_path() == path:
			return c.get_index()
	return -1


func _on_tab_closed() -> void:
	# Make sure there's always at least one opened tab.
	if get_child_count() == 0:
		var welcome_view = preload("res://ui/views/welcome/welcome_view.tscn").instantiate()
		add_tab(welcome_view, true)
