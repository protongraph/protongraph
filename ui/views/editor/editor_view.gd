extends Control
class_name EditorView

# Displays a graph editor, a viewport and an inspector.
# It handles autosaves and the communication between the different parts of
# this view.


signal template_saved


export var viewport_container: NodePath
export var template: NodePath
export var add_node_dialog: NodePath
export var inspector: NodePath

var _node_dialog: WindowDialog
var _template: Template
var _save_timer: Timer
var _last_position: Vector2
var _template_path: String
var _viewport: EditorViewport
var _inspector: InspectorPanel
var _saved := false
var _updating_inspector := false


func _ready() -> void:
	_template = get_node(template)
	_node_dialog = get_node(add_node_dialog)
	_viewport = get_node(viewport_container)
	_inspector = get_node(inspector)
	_template.inspector = _inspector

	Signals.safe_connect(self, "template_saved", self, "_on_template_saved")
	GlobalEventBus.register_listener(self, "settings_updated", "_on_settings_updated")
	_on_settings_updated(Settings.AUTOSAVE_ENABLED)


func load_template(path: String) -> void:
	_template_path = path
	_template.load_from_file(path)
	_template.generate()
	_saved = true


func save_template() -> void:
	_template.save_to_file(_template_path)
	yield(_template, "template_saved")
	_saved = true
	emit_signal("template_saved")
	print("Saved template ", _template_path)


func save_template_as(path: String) -> void:
	var old = _template_path
	_template_path = path
	save_template()
	yield(_template, "template_saved")
	_template_path = old


func get_input(_name) -> Node:
	return null


func regenerate(clear_cache := true) -> void:
	_template.generate(clear_cache)


func has_pending_changes() -> bool:
	return not _saved


func _show_node_dialog_centered() -> void:
	_show_node_dialog(_template.rect_size / 2.0)


func _show_node_dialog(position: Vector2) -> void:
	_last_position = position
	_node_dialog.set_global_position(position)
	_node_dialog.popup()


# warning-ignore:return_value_discarded
func _on_create_node_request(type: String) -> void:
	var local_pos = _last_position - _template.get_global_transform().origin + _template.scroll_offset
	_template.create_node(type, {"offset": local_pos})


func _on_graph_changed() -> void:
	_saved = false


func _on_build_completed() -> void:
	var result = _template.get_output()
	_viewport.display(result)


func _on_build_outdated() -> void:
	_template.generate(false)


func _on_exposed_variables_updated(variables: Array) -> void:
	_updating_inspector = true
	_inspector.update_variables(variables)
	_updating_inspector = false


func _on_inspector_value_changed(name: String) -> void:
	if not _updating_inspector:
		_template.notify_exposed_variable_change(name)


func _on_input_created(node: Spatial) -> void:
	_viewport.add_input_node(node)


func _on_input_deleted(node: Spatial) -> void:
	_viewport.remove_input_node(node)


# Called when the user changes parameters in the settings panel.
func _on_settings_updated(setting: String) -> void:
	var enabled = Settings.get_setting(Settings.AUTOSAVE_ENABLED)
	var interval = Settings.get_setting(Settings.AUTOSAVE_INTERVAL)

	# Autosave delay was changed
	if setting == Settings.AUTOSAVE_INTERVAL and _save_timer:
		_save_timer.start(interval)
		return

	if setting == Settings.AUTOSAVE_ENABLED:
		# Autosave was enabled
		if enabled and not _save_timer:
			_save_timer = Timer.new()
			_save_timer.one_shot = true
			_save_timer.autostart = false
			Signals.safe_connect(_save_timer, "timeout", self, "save_template")
			add_child(_save_timer)
			_save_timer.start(interval)
			return

		# Autosave was disabled
		if not enabled and _save_timer:
			_save_timer.stop()
			_save_timer.queue_free()
			_save_timer = null
			return


# Reset the autosave timer when the template is saved.
func _on_template_saved() -> void:
	if _save_timer:
		_save_timer.start()
