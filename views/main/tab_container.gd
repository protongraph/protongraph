extends TabContainer


signal tabs_cleared

export var tabs: NodePath
export var confirm_dialog: NodePath

var _tabs: Tabs
var _confirm_dialog: WindowDialog


func _ready() -> void:
	_confirm_dialog = get_node(confirm_dialog)
	_tabs = get_node(tabs)
	_tabs.connect("tab_changed", self, "_on_tab_changed")
	_tabs.connect("tab_close", self, "_on_tab_close_request")
	_tabs.connect("reposition_active_tab_request", self, "_on_tab_moved")

	for c in get_children():
		_tabs.add_tab(c.get_name())


func add_child(node: Node, legible_unique_name: bool = false) -> void:
	.add_child(node, legible_unique_name)
	_tabs.add_tab(node.get_name())
	_tabs.set_current_tab(get_child_count() - 1)


func select_tab(tab: int) -> void:
	_tabs.current_tab = tab


func close_tab(tab: int = -1) -> void:
	if tab == -1:
		tab = current_tab

	var c = get_child(tab)
	remove_child(c)
	c.queue_free()
	_tabs.remove_tab(tab)
	close_confirm_dialog()

	if get_child_count() == 0:
		emit_signal("tabs_cleared")


func save_and_close() -> void:
	var tab = current_tab
	var c = get_child(tab)
	c.save_template()
	close_tab()


func close_confirm_dialog() -> void:
	_confirm_dialog.visible = false


func _on_tab_changed(tab: int) -> void:
	set_current_tab(tab)


func _on_tab_moved(to_tab: int) -> void:
	move_child(get_child(current_tab), to_tab)


func _on_tab_close_request(tab: int) -> void:
	var c = get_child(tab)
	if c is ConceptGraphEditorView:
		_confirm_dialog.popup_centered()
	else:
		close_tab(tab)
