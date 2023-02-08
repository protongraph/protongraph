extends MenuButton

# Broadcast a global event when one of the entry is clicked. No logic happens
# here, it only sends commands.


var _new_icon = TextureUtil.get_texture("res://ui/icons/icon_new.svg")
var _load_icon = TextureUtil.get_texture("res://ui/icons/icon_load.svg")
var _save_icon = TextureUtil.get_texture("res://ui/icons/icon_save.svg")
var _settings_icon = TextureUtil.get_texture("res://ui/icons/icon_cog.svg")
var _close_icon = TextureUtil.get_texture("res://ui/icons/icon_close.svg")

var _current_graph: NodeGraph


func _ready() -> void:
	var popup: PopupMenu = get_popup()
	popup.id_pressed.connect(_on_id_pressed)
	popup.add_icon_item(_new_icon, "New", 0)
	popup.add_icon_item(_load_icon, "Load", 1)
	popup.add_separator()
	popup.add_icon_item(_save_icon, "Save", 10)
	popup.add_icon_item(_save_icon, "Save Copy As", 12)
	popup.add_icon_item(_save_icon, "Save All", 14)
	popup.add_separator()
	popup.add_icon_item(_load_icon, "Browse examples", 17)
	popup.add_icon_item(_settings_icon, "Settings", 20)
	popup.add_separator()
	popup.add_icon_item(_close_icon, "Quit", 30)

	var l = max(size.x, size.y)
	custom_minimum_size = Vector2(l, l)

	GlobalEventBus.current_view_changed.connect(_on_view_changed)


func _on_id_pressed(id) -> void:
	match id:
		0:
			GlobalEventBus.create_graph.emit()
		1:
			GlobalEventBus.load_graph.emit()
		10:
			GlobalEventBus.save_graph.emit(_current_graph)
		12:
			GlobalEventBus.save_graph_as.emit(_current_graph)
		14:
			GlobalEventBus.save_all.emit()
		17:
			GlobalEventBus.browse_examples.emit()
		20:
			GlobalEventBus.open_settings.emit()
		30:
			GlobalEventBus.quit.emit()


func _on_view_changed(view) -> void:
	# Toggle the save / save_as options from the menu button if the current
	# view is not an editor view.
	var entry_disabled: bool = not view is EditorView
	var popup: PopupMenu = get_popup()
	popup.set_item_disabled(popup.get_item_index(10), entry_disabled)
	popup.set_item_disabled(popup.get_item_index(12), entry_disabled)

	# Update the current graph reference
	if view is EditorView:
		_current_graph = view.get_edited_graph()
	else:
		_current_graph = null
