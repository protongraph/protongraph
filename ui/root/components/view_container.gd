extends CustomTabContainer
class_name ViewContainer


var _settings_tab := -1
var _start_tab := -1


func _ready() -> void:
	GlobalEventBus.register_listener(self, "create_template", "_on_create_template")
	GlobalEventBus.register_listener(self, "load_template", "_on_load_template")
	GlobalEventBus.register_listener(self, "save_template", "_on_save_template")
	GlobalEventBus.register_listener(self, "open_settings", "_load_settings_view")
	Signals.safe_connect(self, "tabs_cleared", self, "_on_tabs_cleared")


func save_and_close() -> void:
	_save_current_template(true)


func save_all_and_close() -> void:
	for view in get_children():
		pass


func _on_tab_close_request(tab: int) -> void:
	var view = get_tab_content(tab)
	if view is ConceptGraphEditorView and view.has_pending_changes():
		pass
		#_confirm_dialog.call_deferred("popup_centered")
	else:
		._on_tab_close_request(tab)


func _on_load_template(path) -> void:
	# Check if the requested template isn't already open
	for i in get_child_count():
		var view = get_child(i)
		if not view is ConceptGraphEditorView:
			continue

		# Template already loaded, focus the existing tab
		if view._template_path == path:
			select_tab(i)
			return

	# Template isn't already loaded, create an editor view
	var editor = load("res://ui/views/editor/editor_view.tscn").instance()
	editor.name = path.get_file().get_basename()
	add_tab(editor)
	editor.load_template(path)

	GlobalEventBus.dispatch("template_loaded", path)


func _save_current_template(close := false) -> void:
	var view = get_current_tab_content()
	if view is ConceptGraphEditorView:
		view.save_template()
	if close:
		yield(view, "template_saved")
		close_tab()


func _save_all_templates() -> void:
	for view in get_children():
		if view is ConceptGraphEditorView:
			view.save_template()


func _load_start_view():
	var start_view = preload("res://ui/views/welcome/welcome_view.tscn").instance()
	add_tab(start_view)


func _load_settings_view():
	var settings_view = preload("res://ui/views/settings/editor_settings_view.tscn").instance()
	add_tab(settings_view)


func close_all_tabs(no_prompt := false) -> void:
	if no_prompt:
		while get_child_count() > 0:
			close_tab(0)
	else:
		while get_child_count() > 0:
			if get_child(0) is ConceptGraphEditorView:
				_on_tab_close_request(0)
				yield(self, "tab_closed")
			else:
				close_tab(0)


func _on_tabs_cleared() -> void:
	pass
