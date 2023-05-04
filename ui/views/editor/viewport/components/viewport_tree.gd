extends Tree


# Display the Input and Output scenetree structure.


signal node_selected


@export var input: Node3D
@export var output: Node3D
@export var preview: Node3D


@onready var _info_panel: Control = %DefaultTreeInfo


func _ready() -> void:
	update()
	item_selected.connect(_on_item_selected)


func update() -> void:
	# TODO : save selected first
	clear()
	var root = create_item()
	set_hide_root(true)

	var show_in_tree = func(node: Node3D, item_name: String):
		if node.visible and node.get_child_count() != 0:
			var tree_item = create_item(root)
			tree_item.set_text(0, item_name)
			_add_children_to_root(node, tree_item)

	show_in_tree.call(input, "Input")
	show_in_tree.call(output, "Output")
	show_in_tree.call(preview, "Preview")

	# Show the info panel if there's nothing to show.
	_info_panel.visible = root.get_child_count() == 0


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
