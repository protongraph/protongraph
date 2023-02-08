extends Window

# Browse the available nodes from this panel. Once a node is selected, it sends
# a signal caught by the template editor that handles the actual node creation.


signal create_node_request


@onready var _node_tree: Tree = $%NodeTree
@onready var _create_button: Button = $%CreateButton
@onready var _cancel_button: Button = $%CancelButton
@onready var _reload_button: Button = $%ReloadButton
@onready var _description_label: Label = $%DescriptionText
@onready var _grouping_button: CheckBox = $%CheckBox
@onready var _search: LineEdit = $%Search

var _default_description: String
var _search_text := ""
var _group_by_type := false
var _initialized := false


func _ready() -> void:
	about_to_popup.connect(_on_about_to_popup)
	close_requested.connect(hide)
	focus_exited.connect(hide)

	_node_tree.item_activated.connect(_on_item_activated)
	_node_tree.item_selected.connect(_on_item_selected)
	_node_tree.nothing_selected.connect(_on_nothing_selected)
	_grouping_button.toggled.connect(_on_grouping_type_changed)
	_create_button.pressed.connect(_on_item_activated)
	_cancel_button.pressed.connect(hide)
	_reload_button.pressed.connect(_on_reload_button_pressed)
	_search.text_changed.connect(_on_search_text_changed)

	_create_button.disabled = true
	_default_description = _description_label.text
	_grouping_button.button_pressed = Settings.get_setting(Settings.GROUP_NODES_BY_TYPE, false)

	_initialized = true


func _refresh_nodes_list(nodes := [], folder_collapsed := true) -> void:
	if not _initialized:
		return

	_group_by_type = _grouping_button.button_pressed

	_node_tree.clear()
	var root = _node_tree.create_item()
	_node_tree.set_hide_root(true)

	if nodes.is_empty():
		nodes = NodeFactory.get_available_nodes()
		nodes.sort_custom(_sort_nodes_by_title)

	var categories := []
	var node_category
	for node in nodes:
		node_category = _get_node_category(node)
		if _filter_node(node) and not categories.has(node_category):
			categories.push_back(node_category)
	categories.sort()

	if _search_text.is_empty():
		folder_collapsed = true
	else:
		folder_collapsed = false

	for node in nodes:
		if _filter_node(node):
			var item_parent = _get_or_create_category(_get_node_category(node), folder_collapsed)
			var item: TreeItem = _node_tree.create_item(item_parent)
			item.set_text(0, node.title)
			item.set_tooltip_text(0, node.description.strip_escapes())
			item.set_metadata(0, node.type_id)
			var color = DataType.get_category_color(node.category)
			item.set_icon(0, TextureUtil.get_square_texture(color))

	# Select the first result if the user searched a node
	if _search_text:
		var first_node: TreeItem = _get_first_node(root)
		if first_node:
			first_node.select(0)


func _get_first_node(item: TreeItem) -> TreeItem:
	if item.get_child_count() > 0:
		return _get_first_node(item.get_child(0))
	return item


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

# TODO : Check if this actually works after the 4.0 refactoring
func _get_tree_item(root: TreeItem, node_name: String) -> TreeItem:
	if root.get_child_count() == 0:
		return null

	var child = root.get_child(0)
	while child:
		if child.get_text(0) == node_name:
			return child
		child = child.get_next()

	return null


func _get_node_category(node) -> String:
	if not _group_by_type:
		return node.category

	var tokens = node.category.split('/')
	tokens.reverse()
	var reversed := ""
	for i in tokens.size():
		if i != 0:
			reversed += "/"
		reversed += tokens[i]
	return reversed


func _filter_node(node) -> bool:
	return _search_text.is_subsequence_ofn(node.title)


func _sort_nodes_by_title(a, b):
	if a.title < b.title:
		return true
	return false


func _on_item_selected() -> void:
	var item = _node_tree.get_selected()
	if not item:
		_on_nothing_selected()
		return
	_create_button.disabled = false
	_description_label.text = item.get_tooltip_text(0)


func _on_nothing_selected() -> void:
	_create_button.disabled = true
	_description_label.text = _default_description


func _on_item_activated() -> void:
	var selected = _node_tree.get_selected()
	if not selected:
		return

	var type_id: String = selected.get_metadata(0)
	create_node_request.emit(type_id)
	hide()


func _on_search_text_changed(new_text):
	_search_text = new_text
	_refresh_nodes_list()


func _on_grouping_type_changed(_pressed):
	_refresh_nodes_list()


func _on_about_to_popup():
	_refresh_nodes_list()


func _on_reload_button_pressed() -> void:
	NodeFactory.refresh_list()
	_refresh_nodes_list()
