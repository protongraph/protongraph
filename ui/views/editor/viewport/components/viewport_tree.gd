extends Tree


signal node_selected


@export var input: Node3D
@export var output: Node3D


func _ready() -> void:
	update()
	item_selected.connect(_on_item_selected)


func update() -> void:
	# TODO : save selected first
	clear()
	var root = create_item()
	set_hide_root(true)

	var input_root = create_item(root)
	var output_root = create_item(root)

	# TODO: Add icons
	input_root.set_text(0, "Input")
	output_root.set_text(0, "Output")

	_add_children_to_root(input, input_root)
	_add_children_to_root(output, output_root)


func _add_children_to_root(parent: Node, root: TreeItem) -> void:
	for child in parent.get_children():
		var child_root = create_item(root)
		child_root.set_text(0, child.get_name())
		child_root.set_metadata(0, child)
		if child.get_child_count() > 0:
			_add_children_to_root(child, child_root)


func _on_item_selected() -> void:
	var tree_item = get_selected()
	if tree_item:
		node_selected.emit(tree_item.get_metadata(0))
