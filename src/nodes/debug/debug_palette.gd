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
	set_input(2, "Scalar", ConceptGraphDataType.SCALAR)
	set_input(3, "String", ConceptGraphDataType.STRING)
	set_input(4, "Material", ConceptGraphDataType.MATERIAL)
	set_input(5, "Noise", ConceptGraphDataType.NOISE)

	set_input(6, "Node 2D", ConceptGraphDataType.NODE_2D)
	set_input(7, "Curve 2D", ConceptGraphDataType.CURVE_2D)

	set_input(8, "Node 3D", ConceptGraphDataType.NODE_3D)
	set_input(9, "Mesh", ConceptGraphDataType.MESH)
	set_input(10, "Box", ConceptGraphDataType.BOX)
	set_input(11, "Curve 3D", ConceptGraphDataType.CURVE_3D)
	set_input(12, "PolyCurve", ConceptGraphDataType.VECTOR_CURVE)

	set_input(13, "Vector2", ConceptGraphDataType.VECTOR2)
	set_input(14, "Vector3", ConceptGraphDataType.VECTOR3)
	set_input(15, "Vector4", ConceptGraphDataType.VECTOR4)
