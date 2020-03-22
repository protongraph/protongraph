tool
class_name ConceptGraphEditorView
extends Control

"""
The graph editor shown in the bottom panel. When a ConceptGraph node is selected, its Template node
is added as a child of the main editor view so it's editable by the user and removed (but not
deleted) when the ConceptGraph is deselected.
"""


var _template_parent: Control
var _node_dialog: ConceptGraphNodeDialog
var _template_controls: Control
var _load_panel: PanelContainer
var _current_graph: WeakRef
var _current_template: WeakRef
var _autosave: CheckBox
var _autosave_interval := 3
var _save_timer: Timer


func _ready() -> void:
	_template_parent = get_node("TemplateParent")
	_load_panel = get_node("LoadOrCreateTemplate")
	_template_controls = get_node("TemplateControls")
	_node_dialog = get_node("AddNodeDialog")
	_autosave = get_node("TemplateControls/Autosave")

	_load_panel.connect("load_template", self, "_on_load_template")
	_hide_all()

	_save_timer = Timer.new()
	_save_timer.connect("timeout", self, "save_template")
	_save_timer.one_shot = true
	_save_timer.autostart = false
	add_child(_save_timer)


"""
Takes the Template node from the ConceptGraph and add it as a child of the editor view displayed
in the bottom dock. This way the template can be edited there.
"""
func enable_template_editor(node: ConceptGraph) -> void:
	_current_graph = weakref(node)
	_current_template = weakref(node._template)

	node.connect("template_path_changed", self, "")
	node._template.connect("graph_changed", self, "_on_graph_changed")
	node._template.connect("popup_request", self, "_show_node_dialog")

	node.remove_child(node._template)
	_template_parent.add_child(node._template)
	_template_controls.visible = true

	if node.template_path == "":
		_load_panel.visible = true


"""
Give the template back to the conceptGraph and remove references to these nodes to go back to a
clean state.
"""
func disable_template_editor() -> void:
	_hide_all()

	var graph = _get_ref(_current_graph)
	var template = _get_ref(_current_template)

	if not graph or not template:
		_current_template = null
		_current_graph = null
		for c in _template_parent.get_children():
			if c is GraphEdit:
				_template_parent.remove_child(c)
				c.queue_free()
		return

	_template_parent.remove_child(template)
	graph.add_child(template)

	template.disconnect("graph_changed", self, "_on_graph_changed")
	template.disconnect("popup_request", self, "_show_node_dialog")

	_current_template = null
	_current_graph = null


func get_input(name) -> Node:
	var graph = _get_ref(_current_graph)
	if graph:
		return graph.get_input(name)
	return null


func save_template() -> void:
	var template = _get_ref(_current_template)
	var graph = _get_ref(_current_graph)

	if template and graph:
		print("Saving template ", graph.template_path)
		template.save_to_file(graph.template_path)


func replay_simulation() -> void:
	var graph = _get_ref(_current_graph)
	if graph:
		graph.generate(true)


func _show_node_dialog(position: Vector2) -> void:
	_node_dialog.set_global_position(position)
	_node_dialog.visible = true


func _hide_node_dialog() -> void:
	_node_dialog.visible = false


func _hide_all() -> void:
	_load_panel.visible = false
	_template_controls.visible = false
	_node_dialog.visible = false


func _on_load_template(path: String) -> void:
	var graph = _get_ref(_current_graph)
	if graph:
		graph.template_path = path
		graph.property_list_changed_notify() # Forces the inspector to refresh
		_load_panel.visible = false


func _on_create_node_request(node) -> void:
	var template = _get_ref(_current_template)
	if template:
		template.create_node(node)


func _on_graph_changed() -> void:
	if _autosave.pressed:
		_save_timer.stop()
		_save_timer.start(_autosave_interval)


func _get_ref(ref):
	if ref:
		return ref.get_ref()
	return null
