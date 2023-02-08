class_name CustomTabContainer
extends TabContainer


signal tab_closed
signal tabs_cleared


@export var tab_bar: NodePath

var _tabs: TabBar


func _ready():
	_tabs = get_node_or_null(tab_bar)
	if not _tabs:
		return

	_tabs.tab_changed.connect(_on_remote_tab_changed)
	_tabs.tab_close_pressed.connect(_on_tab_close_pressed)
	_tabs.active_tab_rearranged.connect(_on_tab_moved)

	for c in get_children():
		_tabs.add_tab(c.get_name())


func add_tab(view, set_current := true) -> void:
	add_child(view, true)
	_tabs.add_tab(view.get_name())
	if set_current:
		var tab_id = get_child_count() - 1
		#set_current_tab()
		_tabs.set_current_tab(tab_id)


func close_tab(tab: int = -1) -> void:
	if tab == -1:
		tab = current_tab

	if get_child_count() == 0:
		return

	var c = get_child(tab)
	if not c:
		return

	remove_child(c)
	c.queue_free()
	_tabs.remove_tab(tab)

	tab_closed.emit()

	if get_child_count() == 0:
		tabs_cleared.emit()
	else:
		current_tab = _tabs.current_tab


func change_tab(tab: int) -> void:
	current_tab = tab
	_tabs.set_current_tab(tab)


func set_tab_name(tab: int, new_name: String) -> void:
	_tabs.set_tab_title(tab, new_name)


func _on_tab_changed(tab: int) -> void:
	_tabs.set_current_tab(tab)


func _on_remote_tab_changed(tab: int) -> void:
	set_current_tab(tab)
	GlobalEventBus.current_view_changed.emit(get_child(tab))


func _on_tab_moved(to_tab: int) -> void:
	var child = get_child(current_tab)
	move_child(child, to_tab)


func _on_tab_close_pressed(tab: int) -> void:
	close_tab(tab)
