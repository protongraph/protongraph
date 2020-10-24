extends PanelContainer
class_name WelcomeView


export var links_root: NodePath
export var history_panel: NodePath

var _file_entry = preload("res://ui/views/welcome/file_entry.tscn")
var _links_root: Control
var _history_panel: Control


func _ready() -> void:
	_links_root = get_node(links_root)
	_history_panel = get_node(history_panel)
	GlobalEventBus.register_listener(self, "file_history_changed", "_rebuild_history_view")
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
		var link: HistoryFileEntry = _file_entry.instance()
		_links_root.add_child(link)
		link.set_path(path)


func _on_new_template_pressed() -> void:
	GlobalEventBus.dispatch("create_template")


func _on_load_template_pressed() -> void:
	GlobalEventBus.dispatch("load_template")
