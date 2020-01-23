tool
extends Panel

class_name ConceptGraphNodePanel

"""
Select and add nodes to the graph from this panel. This class doesn't actually modify the graph,
it simply send signals to the ConceptGraphEditorView parent node.
"""

signal hide_panel
signal create_node

export var item_list: NodePath
export var create_button: NodePath
export var description_text: NodePath

var _item_list: ItemList
var _create_button: Button
var _description_label: Label
var _default_description: String
var _node_library: ConceptNodeLibrary


func _ready() -> void:
	_node_library = ConceptNodeLibrary.new()

	_item_list = get_node(item_list)
	_item_list.unselect_all()
	_refresh_concept_nodes_list()

	_create_button = get_node(create_button)
	_create_button.disabled = true

	_description_label = get_node(description_text)
	_default_description = _description_label.text


func _refresh_concept_nodes_list() -> void:
	_item_list.clear()
	var nodes = _node_library.get_list()
	for node in nodes:
		var index = _item_list.get_item_count()
		_item_list.add_item(node.get_name(), null, true)
		_item_list.set_item_tooltip(index, node.get_description())


func _hide_panel() -> void:
	emit_signal("hide_panel")


func _on_item_selected(index: int) -> void:
	_create_button.disabled = false
	_description_label.text = _item_list.get_item_tooltip(index)


func _on_nothing_selected() -> void:
	_create_button.disabled = true
	_description_label.text = _default_description
	_item_list.unselect_all()


func _on_item_activated(index: int) -> void:
	emit_signal("create_node", _node_library.get_list()[index])


func _on_create_button_pressed() -> void:
	var index = _item_list.get_selected_items()[0]
	_on_item_activated(index)

