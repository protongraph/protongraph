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
	for c in get_children():
		if c is EditorView and c.get_edited_file_path() == path:
			return true
	return false


func get_current_view() -> Control:
	return get_child(current_tab)


func _on_tab_closed() -> void:
	# Make sure there's always at least one opened tab.
	if get_child_count() == 0:
		var welcome_view = preload("res://ui/views/welcome/welcome_view.tscn").instantiate()
		add_tab(welcome_view, true)
