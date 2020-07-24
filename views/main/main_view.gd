extends PanelContainer


export var menu_button: NodePath
export var tab_container: NodePath
export var file_dialog: NodePath
export var black_overlay: NodePath

var _menu: MenuButton
var _message: Label
var _tab_container: TabContainer
var _file_dialog: FileDialog
var _overlay: Panel

var _history_path := "user://history.json"
var _history: Array = []
var _start_view: WeakRef
var _is_quitting := false


func _ready() -> void:
	# Prevent the application to close automatically
	get_tree().set_auto_accept_quit(false)

	theme = ConceptGraphEditorUtil.get_scaled_theme(theme)
	ConceptGraphEditorUtil.scale_all_ui_resources()
	update()

	_menu = get_node(menu_button)
	Signals.safe_connect(_menu, "menu_action", self, "_on_menu_action")
	_overlay = get_node(black_overlay)

	# File dialog behavior
	_file_dialog = get_node(file_dialog)
	Signals.safe_connect(_file_dialog, "template_requested", self, "_on_template_requested")

	# Tabs behavior
	_tab_container = get_node(tab_container)
	Signals.safe_connect(_tab_container, "tabs_cleared", self, "_on_tabs_cleared")

	# File history
	_load_of_create_file_history()

	# Load a default view to avoid having a blank empty tab on launch
	_load_start_view()


func _notification(event):
	if (event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		_quit()


func _load_of_create_file_history() -> void:
	var dir = Directory.new()
	dir.open("user://")
	if dir.file_exists(_history_path):
		_load_file_history()
	else:
		_save_file_history()


func _load_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.READ)
	_history = JSON.parse(file.get_as_text()).result


func _save_file_history() -> void:
	var file = File.new()
	file.open(_history_path, File.WRITE)
	file.store_string(to_json(_history))
	file.close()

	if _start_view:
		var ref = _start_view.get_ref()
		if not ref:
			_start_view = null
			return
		ref.set_file_history(_history)


func _load_start_view():
	var start_view = preload("res://views/main/start_tab.tscn").instance()
	_tab_container.add_child(start_view)
	start_view.set_file_history(_history)
	start_view.connect("template_requested", self, "_on_template_requested")
	start_view.connect("menu_action", self, "_on_menu_action")
	_start_view = weakref(start_view)


func _load_settings_view():
	var settings_view = preload("res://views/main/editor_settings.tscn").instance()
	_tab_container.add_child(settings_view)


func _show_settings_panel():
	pass


func _save_template():
	var editor = _tab_container.get_child(_tab_container.current_tab)
	if editor is ConceptGraphEditorView:
		editor.save_template()


func _quit() -> void:
	_is_quitting = true
	if _tab_container.has_opened_templates():
		_tab_container.close_all_tabs()
		yield(_tab_container, "tabs_cleared")
	get_tree().quit()


func _on_menu_action(action: String) -> void:
	match action:
		"new":
			_file_dialog.create_template()
		"load":
			_file_dialog.load_template()
		"save":
			_save_template()
		"save_as":
			_file_dialog.save_template_as()
		"settings":
			_load_settings_view()
		"quit":
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


func _on_popup_about_to_show() -> void:
	_overlay.visible = true


func _on_popup_hidden() -> void:
	_overlay.visible = false


func _on_tabs_cleared() -> void:
	if _is_quitting:
		get_tree().quit()
	else:
		_load_start_view()
