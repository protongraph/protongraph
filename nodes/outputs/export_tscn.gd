extends GenericExportNode

var directory := Directory.new()


func _init() -> void:
	._init(["*.tscn", "*.scn"])
	ignore = false
	unique_id = "save_tscn_output"
	display_name = "Export Godot Scene"
	category = "Output"
	description = "Saves the output as a scene file"

	set_input(0, "Node", DataType.NODE_3D)


func _trigger_export() -> void:
	var scene = get_input_single(0)
	var path: String = get_resource_path()

	if path and path != "" and scene:
		# sets the owner of all the children to scene
		_set_children_owner(scene, scene)
		
		var packed_scene := PackedScene.new()
		if packed_scene.pack(scene) != OK:
			print("Failed to pack resource")
			return
		
		ResourceSaver.save(path, packed_scene)


func _set_children_owner(root: Node, node: Node):
	for child in node.get_children():
		child.set_owner(root)
		if child.get_children().size() > 0:
			_set_children_owner(root, child)
