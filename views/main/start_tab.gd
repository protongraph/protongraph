extends PanelContainer

signal template_requested


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
		link.connect("pressed", self, "_on_link_pressed", [path])
		link.text = path
		link.size_flags_horizontal = SIZE_SHRINK_END
		_links_root.add_child(link)


func _on_link_pressed(path: String) -> void:
	emit_signal("template_requested", path)
