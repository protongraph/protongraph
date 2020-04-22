tool
class_name ConceptGraphNodeDialog
extends WindowDialog

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
var _categories: Dictionary


func _ready() -> void:
	_node_library = ConceptNodeLibrary.new()

	_node_tree = get_node(node_tree)
	_refresh_concept_nodes_list()

	_create_button = get_node(create_button)
	_create_button.disabled = true

	_description_label = get_node(description_text)
	_default_description = _description_label.text


func _refresh_concept_nodes_list() -> void:
	_categories = Dictionary()
	_node_tree.clear()
	var root = _node_tree.create_item()
	_node_tree.set_hide_root(true)

	var nodes = _node_library.get_list()
	for node in nodes.values():
		var item_parent = _get_or_create_category(node.category)
		var item = _node_tree.create_item(item_parent)
		item.set_text(0, node.node_title)
		item.set_tooltip(0, node.description)


func _get_or_create_category(category: String) -> TreeItem:
	var levels = category.split('/')
	var item := _node_tree.get_root()

	for c in levels:
		var sub_item = _get_tree_item(item, c)
		if not sub_item:
			sub_item = _node_tree.create_item(item)
			sub_item.set_text(0, c)
			sub_item.set_selectable(0, false)
			sub_item.set_collapsed(true)
		item = sub_item

	return item


func _get_tree_item(root: TreeItem, name: String) -> TreeItem:
	var child = root.get_children()
	while child:
		if child.get_text(0) == name:
			return child
		child = child.get_next()
	return null


func _sort_tree(root: TreeItem) -> void:
	pass


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
