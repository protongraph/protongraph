class_name AddNodeSearchBar
extends LineEdit


# This script allows the user to select items in the Tree while the
# search bar is focused.


@export var tree: Tree


func _gui_input(event):
	if not tree or not has_focus() or not event is InputEventKey:
		return

	if Input.is_action_just_pressed("ui_down"):
		select_sibling(true)

	elif Input.is_action_just_pressed("ui_up"):
		select_sibling(false)

	elif Input.is_action_just_released("ui_accept"):
		tree.item_activated.emit()


# Select the next (or previous) visible TreeItem.
# This emulates what happens when pressing up or down while the tree is focused.
func select_sibling(next: bool):
	var item := tree.get_selected()
	if not item:
		return

	var sibling: TreeItem
	if next:
		sibling = item.get_next_visible()
	else:
		sibling = item.get_prev_visible()

	if not sibling:
		return

	while sibling and not sibling.is_selectable(0):
		if next:
			sibling = sibling.get_child(0)
		else:
			sibling = sibling.get_prev_visible()

	if not sibling:
		return

	sibling.select(0)
