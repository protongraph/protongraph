tool
extends ConceptNode

"""
Takes a node or a node array and parent it to the selected node. Returns the parent.
TODO : Move the dynamic slot system to the ConceptNode
"""


var _btn_container: HBoxContainer
var _children_count := 1


func _init() -> void:
	node_title = "Parent to node"
	category = "Objects"
	description = "Parent the given node(s) to another one and return the parent"

	set_input(0, "Parent", ConceptGraphDataType.NODE)
	set_input(1, "Child", ConceptGraphDataType.NODE)
	set_output(0, "Parent", ConceptGraphDataType.NODE)


func _ready() -> void:
	var add = _make_button("+")
	var remove = _make_button("-")
	add.connect("pressed", self, "add_child_slot")
	remove.connect("pressed", self, "remove_child_slot")

	_btn_container = HBoxContainer.new()
	_btn_container.alignment = BoxContainer.ALIGN_END
	_btn_container.add_child(add)
	_btn_container.add_child(remove)

	add_child(_btn_container)


func get_output(idx: int) -> Spatial:
	if idx != 0:
		return null	# Wrong index

	var parent = get_input(0)
	if not parent:
		return null	# Source didn't provide a valid parent
	if parent is Array and parent.size() >= 1:
		parent = parent[0]

	for i in range(1, _children_count + 1):
		var children = get_input(i)
		if not children:
			continue
		if not children is Array:
			children = [children]

		for c in children:
			var old_parent = c.get_parent()
			if old_parent:
				old_parent.remove_child(c)
			parent.add_child(c)
			c.owner = parent

	return parent


func export_custom_data() -> Dictionary:
	return {"children_count": _children_count}


func restore_custom_data(data: Dictionary) -> void:
	if not data.has("children_count"):
		return

	_children_count = data["children_count"]
	if _children_count > 1:
		for i in range(2, _children_count + 1):
			set_input(i, "Child", ConceptGraphDataType.NODE)

		remove_child(_btn_container)
		._generate_default_gui()
		._setup_slots()
		add_child(_btn_container)


func add_child_slot() -> void:
	_children_count += 1
	set_input(_children_count, "Child", ConceptGraphDataType.NODE)
	_update_gui()
	emit_signal("node_changed", self, true)


func remove_child_slot() -> void:
	if _children_count <= 1:
		return

	if remove_input(_children_count):
		_children_count -= 1
		_update_gui()
		emit_signal("node_changed", self, true)


func _update_gui() -> void:
	remove_child(_btn_container)
	._generate_default_gui()
	._setup_slots()
	add_child(_btn_container)


func _make_button(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.rect_min_size.y = 24
	return btn
