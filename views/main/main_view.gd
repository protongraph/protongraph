extends PanelContainer


export var file_button: NodePath
export var editor_button: NodePath
export var message_label: NodePath
export var tab_container: NodePath
export var file_dialog: NodePath

var _file: MenuButton
var _editor: MenuButton
var _message: Label
var _tab_container: TabContainer
var _file_dialog: FileDialog

var _history_path := "res://history.json"
var _history: Array


func _ready() -> void:
	# Setup file actions
	_file = get_node(file_button)
	var file_popup: PopupMenu = _file.get_popup()
	file_popup.connect("id_pressed", self, "_on_file_action")

	# Setup editor actions
	_editor = get_node(editor_button)
	var editor_popup: PopupMenu = _file.get_popup()
	editor_popup.connect("id_pressed", self, "_on_editor_action")

	_message = get_node(message_label)

	# File dialog behavior
	_file_dialog = get_node(file_dialog)
	_file_dialog.connect("template_requested", self, "_on_template_requested")

	# Tabs behavior
	_tab_container = get_node(tab_container)
	_tab_container.connect("tabs_cleared", self, "_load_start_view")

	# File history
	_load_file_history()

	# Load a default view to avoid having a blank empty tab on launch
	_load_start_view()


func _load_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.READ)
	_history = JSON.parse(file.get_as_text()).result


func _save_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.WRITE)
	file.store_string(to_json(_history))
	file.close()


func _load_start_view():
	var start_view = preload("res://views/main/start_tab.tscn").instance()
	start_view.set_file_history(_history)
	start_view.connect("template_requested", self, "_on_template_requested")
	_tab_container.add_child(start_view)


func _show_settings_panel():
	pass


func _save_template():
	var editor = _tab_container.get_child(_tab_container.current_tab)
	if editor is ConceptGraphEditorView:
		editor.save_template()


func _quit() -> void:
	get_tree().quit()


func _on_file_action(id: int) -> void:
	match id:
		0:
			_file_dialog.create_template()
		1:
			_file_dialog.load_template()
		3:
			_save_template()
		4:
			_file_dialog.save_template_as()
		6:
			_quit()


func _on_editor_action(id: int) -> void:
	match id:
		0:
			_show_settings_panel()


func _on_template_requested(path) -> void:
	# Check if the requested template isn't already open
	for i in _tab_container.get_child_count():
		var c = _tab_container.get_child(i)
		if not c is ConceptGraphEditorView:
			continue

		if c._template_path == path:
			_tab_container.select_tab(i)
			return

	# Tab isn't already open, create an editor view.
	var editor = load("res://views/editor/editor_view.tscn").instance()
	editor.name = path.get_file().get_basename()
	_tab_container.add_child(editor)
	editor.load_template(path)

	if _history.has(path):
		_history.erase(path)

	_history.push_front(path)
	if _history.size() > 20:
		_history.pop_back()

	_save_file_history()

