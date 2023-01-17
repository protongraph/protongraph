extends ProtonNode


func _init() -> void:
	type_id = "debug_color_palette"
	title = "Palette"
	category = "Debug"
	description = "Show all input colors"

	create_input("any", "Any", DataType.ANY)

	create_input("bool", "Boolean", DataType.BOOLEAN)
	create_input("num", "Number", DataType.NUMBER)
	create_input("str", "String", DataType.STRING)

	var opts := SlotOptions.new()
	opts.add_dropdown_item(0, "Option 1")
	opts.add_dropdown_item(1, "Option 2")
	create_input("dropdown", "DropDown", DataType.MISC, opts)
	create_input("vec2", "Vector2", DataType.VECTOR2)
	create_input("vec3", "Vector3", DataType.VECTOR3)

	create_input("2d", "---- 2D Types ----", DataType.NODE_2D)
	create_input("tex", "Texture", DataType.TEXTURE_2D)
	create_input("curve_func", "Curve Function", DataType.CURVE_FUNC)
	create_input("mat", "Material", DataType.MATERIAL)

	create_input("noise", "Noise", DataType.NOISE)

	create_input("3d", "---- 3D Types ----", DataType.NODE_3D)
	create_input("bezier", "Bezier Curve", DataType.CURVE_3D)
	create_input("mesh", "Mesh", DataType.MESH_3D)
	create_input("poly", "Polyline3D", DataType.POLYLINE_3D)
	create_input("height", "Heightmap", DataType.HEIGHTMAP)
