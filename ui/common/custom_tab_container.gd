extends TabContainer
class_name CustomTabContainer


# Same thing as a regular TabContainer, but this one uses a remote tab bar
# placed elsewhere on the scene tree instead of using its own.


signal tab_closed
signal tabs_cleared


export var tabs: NodePath

var _tabs: Tabs


func _ready() -> void:
	tabs_visible = false
	_tabs = get_node(tabs)
	Signals.safe_connect(_tabs, "tab_changed", self, "_on_tab_changed")
	Signals.safe_connect(_tabs, "tab_close", self, "_on_tab_close_request")
	Signals.safe_connect(_tabs, "reposition_active_tab_request", self, "_on_tab_moved")

	for c in get_children():
		_tabs.add_tab(c.get_name())


func add_tab(tab_content: Node, autoselect := true) -> void:
	add_child(tab_content)
	_tabs.add_tab(tab_content.get_name())
	if autoselect:
		_tabs.set_current_tab(get_child_count() - 1)


func select_tab(tab: int) -> void:
	_tabs.current_tab = tab


func get_tab_content(tab_id: int) -> Node:
	return get_child(tab_id)


func get_current_tab_content() -> Node:
	return get_tab_content(current_tab)


func close_tab(tab: int = -1) -> void:
	if tab == -1:
		tab = current_tab

	var c = get_child(tab)
	if not c:
		return

	remove_child(c)
	c.queue_free()
	_tabs.remove_tab(tab)

	var new_tab = _tabs.current_tab
	if new_tab >= 0 and new_tab < get_tab_count():
		current_tab = _tabs.current_tab

	emit_signal("tab_closed")

	if get_child_count() == 0:
		emit_signal("tabs_cleared")


func _on_tab_changed(tab: int) -> void:
	set_current_tab(tab)


func _on_tab_moved(to_tab: int) -> void:
	move_child(get_current_tab_content(), to_tab)


func _on_tab_close_request(tab: int) -> void:
	close_tab(tab)
