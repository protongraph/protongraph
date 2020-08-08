tool
extends ConceptNode

"""
DEBUG NODE : Show all input colors at once
"""


func _init() -> void:
	unique_id = "debug_color_palette"
	display_name = "Palette"
	category = "Debug"
	description = "Show all input colors at once"

	set_input(0, "Any", ConceptGraphDataType.ANY)
	set_input(1, "Boolean", ConceptGraphDataType.BOOLEAN)
	set_input(2, "Number", ConceptGraphDataType.SCALAR)
	set_input(3, "String", ConceptGraphDataType.STRING)
	set_input(4, "Material", ConceptGraphDataType.MATERIAL)
	set_input(5, "Noise", ConceptGraphDataType.NOISE)
	set_input(6, "Curve Function", ConceptGraphDataType.CURVE_FUNC)

	set_input(7, "Vector2", ConceptGraphDataType.VECTOR2)
	set_input(8, "Vector3", ConceptGraphDataType.VECTOR3)
	
	set_input(9, "Node", ConceptGraphDataType.NODE_3D)
	set_input(10, "Mesh", ConceptGraphDataType.MESH_3D)
	set_input(11, "Bezier Curve", ConceptGraphDataType.CURVE_3D)
	set_input(12, "Polygon Curve", ConceptGraphDataType.VECTOR_CURVE_3D)

