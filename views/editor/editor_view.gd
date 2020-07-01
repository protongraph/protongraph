tool
class_name ConceptGraphEditorView
extends Control

"""
"""

signal message

export var viewport: NodePath
export var template: NodePath
export var add_node_dialog: NodePath

var _node_dialog: WindowDialog
var _template: ConceptGraphTemplate
var _save_timer: Timer
var _last_position: Vector2
var _template_path: String
var _viewport: ViewportContainer


func _ready() -> void:
	_template = get_node(template)
	_node_dialog = get_node(add_node_dialog)
	_viewport = get_node(viewport)
	_viewport.rect_min_size = Vector2(256, 128)

	_save_timer = Timer.new()
	_save_timer.connect("timeout", self, "save_template")
	_save_timer.one_shot = false
	_save_timer.autostart = false
	add_child(_save_timer)

	_save_timer.start(Settings.get_setting(Settings.AUTOSAVE_INTERVAL))


func load_template(path: String) -> void:
	_template_path = path
	_template.load_from_file(path)


func get_input(name) -> Node:
	return null


func save_template() -> void:
	print("Saving template ", _template_path)
	_template.save_to_file(_template_path)
	emit_signal("message", "Saving template " + _template_path)


func regenerate() -> void:
	_template.generate(true)


func _show_node_dialog(position: Vector2) -> void:
	_last_position = position
	_node_dialog.set_global_position(position)
	_node_dialog.popup()


func _hide_node_dialog() -> void:
	_node_dialog.visible = false


func _clear_graph():
	_template.clear()


func _on_create_node_request(node) -> void:
	var local_pos = _last_position - _template.get_global_transform().origin + _template.scroll_offset
	_template.create_node(node, {"offset": local_pos})


func _on_graph_changed() -> void:
	if Settings.get_setting("autosave"):
		_save_timer.stop()
		_save_timer.start(Settings.autosave_interval)


func _on_simulation_completed() -> void:
	var result = _template.get_output()
	_viewport.display(result)


func _on_simulation_outdated() -> void:
	_template.generate()
