tool
extends ConceptNode

"""
Assigns a material to the selected node
"""


func _init() -> void:
	unique_id = "set_material_to_node"
	display_name = "Set material"
	category = "Modifiers/Nodes"
	description = "Assigns a material to the given node"

	set_input(0, "Node", ConceptGraphDataType.NODE_3D)
	set_input(1, "Material", ConceptGraphDataType.MATERIAL)
	set_input(2, "Override children", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.NODE_3D)

	mirror_slots_type(0, 0)


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var material: Material = get_input_single(1)
	var override_children_mats: bool = get_input_single(2, false)

	if not material or not nodes or nodes.size() == 0:
		output[0] = nodes
		return

	for node in nodes:
		if override_children_mats:
			override_recursive(node, material)
		else:
			override_material(node, material)

	output[0] = nodes


func override_material(node, material):
	if node is MeshInstance:
		for i in node.get_surface_material_count():
			node.set_surface_material(i, material)
	elif node is CSGPrimitive:
		node.set_material(material)


func override_recursive(node, material):
	override_material(node, material)
	for c in node.get_children():
		override_recursive(c, material)
