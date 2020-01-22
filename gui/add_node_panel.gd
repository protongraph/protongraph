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


func _ready() -> void:
	_item_list = get_node(item_list)
	_create_button = get_node(create_button)
	_description_label = get_node(description_text)
	_default_description = _description_label.text


func register_node_type(name: String) -> void:
	_item_list.add_item(name, null, true)


func _hide_panel() -> void:
	emit_signal("hide_panel")


func _on_node_selection_changed() -> void:
	if _item_list.is_anything_selected():
		_create_button.disabled = false
		# TODO Display the node's description
	else:
		_create_button.disabled = true
		# TODO : Reset description to default text


func _on_create_button_pressed(node) -> void:
	emit_signal("create_node", node)

