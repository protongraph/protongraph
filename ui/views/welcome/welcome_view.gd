extends PanelContainer


export var links_root: NodePath
export var history_panel: NodePath

var _links_root: Control
var _history_panel: Control


func _ready() -> void:
	_links_root = get_node(links_root)
	_history_panel = get_node(history_panel)
	GlobalEventBus.register_listener(self, "file_history_changed", "_on_file_history_changed")
	_rebuild_history_view()


func _rebuild_history_view() -> void:
	var history: Array = FileHistory.get_list()
	
	if not history or history.empty():
		_history_panel.visible = false
		return

	_history_panel.visible = true
	for c in _links_root.get_children():
		_links_root.remove_child(c)
		c.queue_free()

	for path in history:
		var link = LinkButton.new()
		link.text = _shorten_path(path)
		Signals.safe_connect(link, "pressed", self, "_on_link_pressed", [path])
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


func _on_file_history_changed() -> void:
	_rebuild_history_view()


func _on_link_pressed(path: String) -> void:
	GlobalEventBus.dispatch("load_template", path)


func _on_new_template_pressed() -> void:
	GlobalEventBus.dispatch("create_template")


func _on_load_template_pressed() -> void:
	GlobalEventBus.dispatch("load_template")
