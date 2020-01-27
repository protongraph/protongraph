tool
extends WindowDialog

class_name ConceptGraphNodePanel

"""
Select and add nodes to the graph from this panel. This class doesn't actually modify the graph,
it simply send signals to the ConceptGraphEditorView parent node.
"""


signal hide_panel
signal create_node

export var node_tree: NodePath
export var create_button: NodePath
export var description_text: NodePath

var _node_tree: Tree
var _create_button: Button
var _description_label: Label
var _default_description: String
var _node_library: ConceptNodeLibrary


func _ready() -> void:
	_node_library = ConceptNodeLibrary.new()

	_node_tree = get_node(node_tree)
	_refresh_concept_nodes_list()

	_create_button = get_node(create_button)
	_create_button.disabled = true

	_description_label = get_node(description_text)
	_default_description = _description_label.text


func _refresh_concept_nodes_list() -> void:
	_node_tree.clear()
	var root = _node_tree.create_item()
	_node_tree.set_hide_root(true)
	var categories = Dictionary()

	var nodes = _node_library.get_list()
	for node in nodes.values():
		var category = node.get_category()
		if not categories.has(category):
			categories[category] = _node_tree.create_item(root)
			categories[category].set_text(0, category)
			categories[category].set_selectable(0, false)

		var item = _node_tree.create_item(categories[category])
		item.set_text(0, node.get_node_name())
		item.set_tooltip(0, node.get_description())


func _hide_panel() -> void:
	emit_signal("hide_panel")


func _on_item_selected() -> void:
	var item = _node_tree.get_selected()
	if not item:
		_on_nothing_selected()
		return

	_create_button.disabled = false
	_description_label.text = item.get_tooltip(0)


func _on_nothing_selected() -> void:
	_create_button.disabled = true
	_description_label.text = _default_description


func _on_item_activated() -> void:
	var node_name = _node_tree.get_selected().get_text(0)
	var node = _node_library.get_list()[node_name]
	emit_signal("create_node", node)
	_hide_panel()


func _on_create_button_pressed() -> void:
	_on_item_activated()

