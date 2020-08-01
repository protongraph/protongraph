tool
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
export var grouping_button: NodePath

var _node_tree: Tree
var _create_button: Button
var _description_label: Label
var _grouping_button: Button
var _default_description: String
var _search_text := ""
var _group_by_type := false
var _initialized := false


func _ready() -> void:
	_node_tree = get_node(node_tree)
	_refresh_concept_nodes_list()

	_create_button = get_node(create_button)
	_create_button.disabled = true

	_description_label = get_node(description_text)
	_default_description = _description_label.text

	_grouping_button = get_node(grouping_button)
	_initialized = true


func _refresh_concept_nodes_list(nodes := [], folder_collapsed := true) -> void:
	if not _initialized:
		return

	_group_by_type = _grouping_button.pressed

	_node_tree.clear()
	var root = _node_tree.create_item()
	_node_tree.set_hide_root(true)

	if nodes.empty():
		nodes = NodeLibrary.get_list().values()
		nodes.sort_custom(self, "_sort_nodes_by_display_name")

	var categories := []
	var node_category
	for node in nodes:
		node_category = _get_node_category(node)
		if _filter_node(node) and not categories.has(node_category):
			categories.append(node_category)
	categories.sort()

	if !_search_text:
		folder_collapsed = true
	else:
		folder_collapsed = false

	for cat in categories:
		_get_or_create_category(cat, folder_collapsed)

	for node in nodes:
		if _filter_node(node):
			var item_parent = _get_or_create_category(_get_node_category(node), folder_collapsed)
			var item: TreeItem = _node_tree.create_item(item_parent)
			item.set_text(0, node.display_name)
			item.set_tooltip(0, node.description)
			item.set_metadata(0, node.unique_id)
			var color = ConceptGraphDataType.to_category_color(node.category)
			item.set_icon(0, ConceptGraphEditorUtil.get_square_texture(color))


func _get_or_create_category(category: String, collapsed := true) -> TreeItem:
	var levels = category.split('/')
	var item := _node_tree.get_root()

	for c in levels:
		var sub_item = _get_tree_item(item, c)
		if not sub_item:
			sub_item = _node_tree.create_item(item)
			sub_item.set_text(0, c)
			sub_item.set_selectable(0, false)
			sub_item.set_collapsed(collapsed)
		item = sub_item

	return item


func _get_tree_item(root: TreeItem, name: String) -> TreeItem:
	var child = root.get_children()
	while child:
		if child.get_text(0) == name:
			return child
		child = child.get_next()
	return null


func _get_node_category(node) -> String:
	if not _group_by_type:
		return node.category

	var tokens = node.category.split('/')
	tokens.invert()
	var reversed := ""
	for i in tokens.size():
		if i != 0:
			reversed += "/"
		reversed += tokens[i]
	return reversed


func _sort_tree(root: TreeItem) -> void:
	pass


func _hide_panel() -> void:
	#emit_signal("hide_panel")
	visible = false


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
	var selected = _node_tree.get_selected()
	if not selected:
		return

	var node_id = selected.get_metadata(0)
	emit_signal("create_node", node_id)
	_hide_panel()


func _on_create_button_pressed() -> void:
	_on_item_activated()


func _on_Search_text_changed(new_text):
	_search_text = new_text
	_refresh_concept_nodes_list()


func _filter_node(node) -> bool:
	var pattern := "*" + _search_text + "*"
	return node.display_name.matchn(pattern) or node.category.matchn(pattern)


func _sort_nodes_by_display_name(a, b):
	if a.display_name < b.display_name:
		return true
	return false


func _on_grouping_type_changed(_pressed):
	_refresh_concept_nodes_list()


func _on_dialog_about_to_show() -> void:
	_refresh_concept_nodes_list()
