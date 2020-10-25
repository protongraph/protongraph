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

	set_input(0, "Any", DataType.ANY)
			
	set_input(1, "Boolean", DataType.BOOLEAN)
	set_input(2, "Number", DataType.SCALAR)
	set_input(3, "String", DataType.STRING)
	set_input(4, "Vector2", DataType.VECTOR2)
	set_input(5, "Vector3", DataType.VECTOR3)
	
	set_input(6, "---- 2D Types ----", DataType.NODE_2D)
	set_input(7, "Texture", DataType.TEXTURE_2D)
	set_input(8, "Curve Function", DataType.CURVE_FUNC)
	set_input(9, "Material", DataType.MATERIAL)

	set_input(10, "Noise", DataType.NOISE)

	set_input(11, "---- 3D Types ----", DataType.NODE_3D)
	set_input(12, "Bezier Curve", DataType.CURVE_3D)
	set_input(13, "Mesh", DataType.MESH_3D)
	set_input(14, "Polygon Curve", DataType.VECTOR_CURVE_3D)
	set_input(15, "Heightmap", DataType.HEIGHTMAP)
