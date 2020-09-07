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
	set_input(4, "Vector2", ConceptGraphDataType.VECTOR2)
	set_input(5, "Vector3", ConceptGraphDataType.VECTOR3)
	
	set_input(6, "---- 2D Types ----", ConceptGraphDataType.NODE_2D)
	set_input(7, "Texture", ConceptGraphDataType.TEXTURE_2D)
	set_input(8, "Curve Function", ConceptGraphDataType.CURVE_FUNC)
	set_input(9, "Material", ConceptGraphDataType.MATERIAL)

	set_input(10, "Noise", ConceptGraphDataType.NOISE)

	set_input(11, "---- 3D Types ----", ConceptGraphDataType.NODE_3D)
	set_input(12, "Bezier Curve", ConceptGraphDataType.CURVE_3D)
	set_input(13, "Mesh", ConceptGraphDataType.MESH_3D)
	set_input(14, "Polygon Curve", ConceptGraphDataType.VECTOR_CURVE_3D)
	set_input(15, "Heightmap", ConceptGraphDataType.HEIGHTMAP)
