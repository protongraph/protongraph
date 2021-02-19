tool
extends ProtonNode

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
	
	set_input(10, "---- 2D Types ----", DataType.NODE_2D)
	set_input(11, "Texture", DataType.TEXTURE_2D)
	set_input(12, "Curve Function", DataType.CURVE_FUNC)
	set_input(13, "Material", DataType.MATERIAL)

	set_input(20, "Noise", DataType.NOISE)

	set_input(30, "---- 3D Types ----", DataType.NODE_3D)
	set_input(31, "Bezier Curve", DataType.CURVE_3D)
	set_input(32, "Mesh", DataType.MESH_3D)
	set_input(33, "Polygon Curve", DataType.POLYLINE_3D)
	set_input(34, "Heightmap", DataType.HEIGHTMAP)
