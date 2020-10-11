extends PanelContainer

signal template_requested
signal menu_action


export var links_root: NodePath
export var parent: NodePath

var _links_root: Control
var _parent: Control


func set_file_history(history: Array) -> void:
	_links_root = get_node(links_root)
	_parent = get_node(parent)

	if not history or history.empty():
		_parent.visible = false
		return

	_parent.visible = true
	for c in _links_root.get_children():
		_links_root.remove_child(c)
		c.queue_free()

	for path in history:
		var link = LinkButton.new()
		link.text = _shorten_path(path)
		link.connect("pressed", self, "_on_link_pressed", [path])
		_links_root.add_child(link)


func _shorten_path(path: String) -> String:
	if path.length() > 80:
		var tokens = path.split("/", false)
		var total_size = path.length()

		while total_size > 80 and tokens.size() > 4:
			tokens.remove(2)
			total_size = tokens.size()
			for token in tokens:
				total_size += token.length()

		tokens.insert(2, "...")
		var res = ""

		for token in tokens:
			res += "/" + token
		return res
	return path


func _on_link_pressed(path: String) -> void:
	emit_signal("template_requested", path)


func _on_new_template_pressed() -> void:
	emit_signal("menu_action", "new")


func _on_load_template_pressed() -> void:
	emit_signal("menu_action", "load")
