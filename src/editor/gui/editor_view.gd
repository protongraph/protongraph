tool
class_name ConceptGraphEditorView
extends Control

"""
The graph editor shown in the bottom panel. When a ConceptGraph node is selected, its Template node
is added as a child of the main editor view so it's editable by the user and removed (but not
deleted) when the ConceptGraph is deselected.
"""

var undo_redo: UndoRedo

var _template_parent: Control
var _node_dialog: WindowDialog
var _load_panel: PanelContainer
var _no_graph_panel: PanelContainer
var _loading_indicator: HBoxContainer
var _graph_name: Label
var _current_graph: WeakRef
var _current_template: WeakRef
var _autosave: bool
var _autosave_interval := 3
var _save_timer: Timer


func _ready() -> void:
	_template_parent = get_node("PanelContainer/TemplateParent")
	_load_panel = get_node("LoadOrCreateTemplate")
	_no_graph_panel = get_node("NoGraphSelected")
	_node_dialog = get_node("AddNodeDialog")
	_graph_name = get_node("PanelContainer/TemplateParent/TemplateControls/Right/GraphName")
	_loading_indicator = get_node("PanelContainer/TemplateParent/TemplateControls/Left/LoadingIndicator")
	_autosave = get_node("PanelContainer/TemplateParent/TemplateControls/Left/Autosave").pressed

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
func enable_template_editor_for(node: ConceptGraph) -> void:
	clear_template_editor()
	_current_graph = weakref(node)
	_current_template = weakref(node._template)

	node._template.paused = true # Prevent regenerations while the UI is not ready

	node.connect("template_path_changed", self, "_on_load_template")
	node.connect("tree_exited", self, "clear_template_editor")
	node._template.connect("graph_changed", self, "_on_graph_changed")
	node._template.connect("popup_request", self, "_show_node_dialog")
	node._template.connect("simulation_started", self, "_show_loading_panel")
	node._template.connect("simulation_completed", self, "_hide_loading_panel")
	node._template.undo_redo = undo_redo

	node.remove_child(node._template)
	_template_parent.add_child(node._template)
	_graph_name.text = node.get_name()

	# Force graphnodes to rebuild their UI because they were generated under a spatial node but they
	# are now under a Control node so the editor theme is now available
	for child in node._template.get_children():
		if child is ConceptNode:
			child.regenerate_default_ui()

	_no_graph_panel.visible = false
	if node.template_path == "":
		_load_panel.visible = true
	else:
		_template_parent.visible = true

	node._template.paused = false


"""
Give the template back to the ConceptGraph and remove references to these nodes to go back to a
clean state. Disconnect the signals to avoid impacting deselected templates.
"""
func clear_template_editor() -> void:
	_hide_all()
	var graph = _get_ref(_current_graph)
	var template = _get_ref(_current_template)

	if not graph or not template:
		_current_template = null
		_current_graph = null
		for c in _template_parent.get_children():
			if c is GraphEdit:
				_template_parent.remove_child(c)
				c.free()
		return

	template.disconnect("graph_changed", self, "_on_graph_changed")
	template.disconnect("popup_request", self, "_show_node_dialog")
	template.disconnect("simulation_started", self, "_show_loading_panel")
	template.disconnect("simulation_completed", self, "_hide_loading_panel")
	graph.disconnect("template_path_changed", self, "_on_load_template")
	graph.disconnect("tree_exited", self, "clear_template_editor")

	_template_parent.remove_child(template)
	graph.add_child(template)

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
	_node_dialog.popup()


func _hide_node_dialog() -> void:
	_node_dialog.visible = false


func _show_loading_panel() -> void:
	_loading_indicator.visible = true


func _hide_loading_panel() -> void:
	_loading_indicator.visible = false


func _hide_all() -> void:
	_load_panel.visible = false
	_node_dialog.visible = false
	_template_parent.visible = false
	_no_graph_panel.visible = true


func _on_load_template(path: String) -> void:
	var graph = _get_ref(_current_graph)
	if graph:
		graph.template_path = path
		graph.property_list_changed_notify() # Forces the inspector to refresh
		_hide_all()
		_no_graph_panel.visible = false

		if not path or path == "":
			_load_panel.visible = true
		else:
			_template_parent.visible = true


func _on_create_node_request(node) -> void:
	var template = _get_ref(_current_template)
	if template:
		template.create_node(node)


func _on_graph_changed() -> void:
	if _autosave:
		_save_timer.stop()
		_save_timer.start(_autosave_interval)


func _get_ref(ref):
	if ref:
		return ref.get_ref()
	return null


func _clear_graph():
	var template = _get_ref(_current_template)
	if template:
		template.clear()


func _on_autosave_toggled(button_pressed: bool) -> void:
	_autosave = button_pressed
