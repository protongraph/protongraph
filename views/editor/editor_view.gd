tool
class_name ConceptGraphEditorView
extends Control

"""
"""

signal message
signal template_saved

export var viewport_container: NodePath
export var template: NodePath
export var add_node_dialog: NodePath
export var inspector: NodePath

var _node_dialog: WindowDialog
var _template: ConceptGraphTemplate
var _save_timer: Timer
var _last_position: Vector2
var _template_path: String
var _viewport: ViewportContainer
var _inspector: InspectorPanel
var _saved := false
var _updating_inspector := false


func _ready() -> void:
	_template = get_node(template)
	_node_dialog = get_node(add_node_dialog)
	_viewport = get_node(viewport_container)
	_viewport.rect_min_size = Vector2(256, 128)
	_inspector = get_node(inspector)


	if Settings.get_setting("autosave"):
		_save_timer = Timer.new()
		_save_timer.one_shot = false
		_save_timer.autostart = false
		Signals.safe_connect(_save_timer, "timeout", self, "save_template")
		add_child(_save_timer)
		_save_timer.start(Settings.get_setting(Settings.AUTOSAVE_INTERVAL))


func load_template(path: String) -> void:
	_template_path = path
	_template.load_from_file(path)
	_template.update_exposed_variables()
	_template.generate(true)
	_saved = true


func get_input(name) -> Node:
	return null


func save_template() -> void:
	_template.save_to_file(_template_path)
	yield(_template, "template_saved")
	_saved = true
	emit_signal("message", "Saved template " + _template_path)
	emit_signal("template_saved")
	print("Saved template ", _template_path)


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


func _hide_node_dialog() -> void:
	_node_dialog.visible = false


func _clear_graph():
	_template.clear()


func _on_create_node_request(type: String) -> void:
	var local_pos = _last_position - _template.get_global_transform().origin + _template.scroll_offset
	_template.create_node(type, {"offset": local_pos})


func _on_graph_changed() -> void:
	_saved = false


func _on_simulation_completed() -> void:
	var result = _template.get_output()
	_viewport.display(result)


func _on_simulation_outdated() -> void:
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
