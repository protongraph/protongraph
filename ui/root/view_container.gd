class_name ViewContainer
extends CustomTabContainer


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
