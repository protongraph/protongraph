class_name ViewContainer
extends CustomTabContainer


signal ready_to_quit
signal quit_canceled
signal editor_tab_changed


export var dialog_manager: NodePath

var _dialog_manager: DialogManager
var _is_quitting := false


func _ready() -> void:
	GlobalEventBus.register_listener(self, "create_template", "_on_create_template")
	GlobalEventBus.register_listener(self, "load_template", "_on_load_template")
	GlobalEventBus.register_listener(self, "save_template", "_on_save_template")
	GlobalEventBus.register_listener(self, "save_template_as", "_on_save_template_as")
	GlobalEventBus.register_listener(self, "open_settings", "_load_settings_view")
	GlobalEventBus.register_listener(self, "open_remote_view", "_load_remote_view")
	
	_dialog_manager = get_node(dialog_manager)
	Signals.safe_connect(self, "tabs_cleared", self, "_on_tabs_cleared")
	Signals.safe_connect(self, "tab_changed", self, "_on_tab_changed")
	Signals.safe_connect(_dialog_manager, "canceled", self, "_on_close_canceled")
	Signals.safe_connect(_dialog_manager, "discarded", self, "_on_close_discarded")
	Signals.safe_connect(_dialog_manager, "confirmed", self, "_on_close_confirmed")
	
	_load_start_view()


func save_all_and_close() -> void:
	_is_quitting = true
	
	while get_child_count() > 0:
		if not _is_quitting:
			return
		select_tab(0)
		if get_child(0) is EditorView:
			_on_tab_close_request(0)
			yield(self, "tab_closed")
		else:
			close_tab(0)
	
	emit_signal("ready_to_quit")


func _save_current_template(close := false) -> void:
	var view = get_current_tab_content()
	if not view is EditorView:
		return
	
	view.save_template()
	if close:
		yield(view, "template_saved")
		close_tab()


func _save_all_templates() -> void:
	for view in get_children():
		if view is EditorView:
			view.save_template()


func _load_start_view():
	if _is_view_opened(WelcomeView):
		return
	var start_view = preload("res://ui/views/welcome/welcome_view.tscn").instance()
	add_tab(start_view)


func _load_settings_view():
	if _is_view_opened(EditorSettingsView):
		return 
	var settings_view = preload("res://ui/views/settings/editor_settings_view.tscn").instance()
	add_tab(settings_view)


func _load_remote_view():
	if _is_view_opened(RemoteView):
		return
	var remote_view = preload("res://ui/views/remote/remote_view.tscn").instance()
	add_tab(remote_view)


func _create_template(path: String) -> void:
	var default_content : String = '{"editor":{"offset_x":-300, "offset_y":-200},"connections":[],"nodes":[{"data":{},"editor":{"offset_x":0,"offset_y":0,"slots":{}},"name":"GraphNode","type":"viewer_3d"}]}'
	var template_file = File.new()
	template_file.open(path, File.WRITE)
	template_file.store_line(default_content)
	template_file.close()
	_load_template(path)


func _load_template(path: String) -> void:
	# Check if the requested template isn't already open
	for i in get_child_count():
		var view = get_child(i)
		if not view is EditorView:
			continue

		# If the template is already loaded, focus the existing tab
		if view._template_path == path:
			select_tab(i)
			return

	# Template isn't already loaded, create an editor view
	var editor: EditorView = load("res://ui/views/editor/editor_view.tscn").instance()
	editor.name = path.get_file().get_basename()
	add_tab(editor)
	editor.load_template(path)


func _save_template_as(path: String) -> void:
	var view = get_current_tab_content()
	if view is EditorView:
		view.save_template_as(path)


func _is_view_opened(type: GDScript) -> bool:
	for view in get_children():
		if view is type:
			return true
	return false


func _on_tabs_cleared() -> void:
	if _is_quitting:
		emit_signal("ready_to_quit")
	else:
		_load_start_view()


func _on_tab_changed(idx: int) -> void:
	._on_tab_changed(idx)
	emit_signal("editor_tab_changed", get_child(idx) is EditorView)


func _on_create_template(path = null) -> void:
	if path:
		_create_template(path)
	else:
		_dialog_manager.show_file_dialog(Constants.CREATE)


func _on_load_template(path = null) -> void:
	if path:
		_load_template(path)
	else:
		_dialog_manager.show_file_dialog(Constants.LOAD)


func _on_save_template_as(path = null) -> void:
	if path:
		_save_template_as(path)
	else:
		_dialog_manager.show_file_dialog(Constants.SAVE_AS)


func _on_tab_close_request(tab: int) -> void:
	var view = get_tab_content(tab)
	if view is EditorView and view.has_pending_changes():
		_dialog_manager.show_confirm_dialog()
	else:
		._on_tab_close_request(tab)


func _on_close_confirmed() -> void:
	_save_current_template(true)


func _on_close_discarded() -> void:
	close_tab(current_tab)


func _on_close_canceled() -> void:
	if _is_quitting:
		_is_quitting = false
		emit_signal("tab_closed")	# Don't leave the yield pending
		emit_signal("quit_canceled")
