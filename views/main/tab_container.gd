extends TabContainer


signal tab_closed
signal tabs_cleared

export var tabs: NodePath
export var confirm_dialog: NodePath

var _tabs: Tabs
var _confirm_dialog: WindowDialog


func _ready() -> void:
	_confirm_dialog = get_node(confirm_dialog)
	_tabs = get_node(tabs)
	Signals.safe_connect(_tabs, "tab_changed", self, "_on_tab_changed")
	Signals.safe_connect(_tabs, "tab_close", self, "_on_tab_close_request")
	Signals.safe_connect(_tabs, "reposition_active_tab_request", self, "_on_tab_moved")

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
	if not c:
		return

	remove_child(c)
	c.queue_free()
	_tabs.remove_tab(tab)
	close_confirm_dialog()

	var new_tab = _tabs.current_tab
	if new_tab >= 0 and new_tab < get_tab_count():
		current_tab = _tabs.current_tab

	emit_signal("tab_closed")

	if get_child_count() == 0:
		emit_signal("tabs_cleared")


func close_all_tabs(no_prompt := false) -> void:
	if no_prompt:
		while get_child_count() > 0:
			close_tab(0)
	else:
		while get_child_count() > 0:
			if get_child(0) is ConceptGraphEditorView:
				_on_tab_close_request(0)
				yield(self, "tab_closed")
			else:
				close_tab(0)


func save_and_close() -> void:
	var tab = current_tab
	var c = get_child(tab)
	c.save_template()
	yield(c, "template_saved")
	close_tab()


func close_confirm_dialog() -> void:
	_confirm_dialog.visible = false


func has_opened_templates() -> bool:
	for c in get_children():
		if c is ConceptGraphEditorView:
			return true
	return false


func _on_tab_changed(tab: int) -> void:
	set_current_tab(tab)


func _on_tab_moved(to_tab: int) -> void:
	move_child(get_child(current_tab), to_tab)


func _on_tab_close_request(tab: int) -> void:
	var c = get_child(tab)
	if c is ConceptGraphEditorView and c.has_pending_changes():
		_confirm_dialog.call_deferred("popup_centered")
	else:
		close_tab(tab)
