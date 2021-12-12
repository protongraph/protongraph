extends ProtonNode


func _init() -> void:
	type_id = "debug_color_palette"
	title = "Palette"
	category = "Debug"
	description = "Show all input colors"

	create_input(0, "Any", DataType.ANY)

	create_input(1, "Boolean", DataType.BOOLEAN)
	create_input(2, "Number", DataType.NUMBER)
	create_input(3, "String", DataType.STRING)
	create_input(4, "Vector2", DataType.VECTOR2)
	create_input(5, "Vector3", DataType.VECTOR3)

	create_input(10, "---- 2D Types ----", DataType.NODE_2D)
	create_input(11, "Texture", DataType.TEXTURE_2D)
	create_input(12, "Curve Function", DataType.CURVE_FUNC)
	create_input(13, "Material", DataType.MATERIAL)

	create_input(20, "Noise", DataType.NOISE)

	create_input(30, "---- 3D Types ----", DataType.NODE_3D)
	create_input(31, "Bezier Curve", DataType.CURVE_3D)
	create_input(32, "Mesh", DataType.MESH_3D)
	create_input(33, "Polygon Curve", DataType.POLYLINE_3D)
	create_input(34, "Heightmap", DataType.HEIGHTMAP)
