tool
extends ProtonNode


func _init() -> void:
	unique_id = "mesh_from_heightmap"
	display_name = "Heightmap To Mesh"
	category = "Converters/Heightmaps"
	description = "Creates a mesh from a heightmap"

	set_input(0, "HeightMap", DataType.HEIGHTMAP)
	set_input(1, "Subdivision", DataType.SCALAR, {"value": 64, "step":1, "min":1, "allow_lesser": false})
	set_input(2, "Smoothing", DataType.BOOLEAN, {"value": true})
	set_input(3, "Wireframe", DataType.BOOLEAN, {"value": false})
	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var heightmap: Object = get_input_single(0)
	var subdivide: int = get_input_single(1, 64)
	var smoothing: bool = get_input_single(2, false)
	var wireframe: bool = get_input_single(3, false)

	if not heightmap:
		return

	var map_size: float = heightmap.size.x - 1
	var mesh_size: float = heightmap.mesh_size.x - 1
	var height_scale: float = heightmap.height_scale
	var height_offset: float = heightmap.height_offset

	var steps: float = subdivide
	var spacing: float = mesh_size / steps
	var ratio: float = map_size / steps
	steps += 1

	var st = SurfaceTool.new()

	if wireframe:
		st.begin(Mesh.PRIMITIVE_LINES)
	else:
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

	if smoothing:
		st.add_smooth_group(true)

	var height: float = 0.0
	var _x: float = 0.0
	var _y: float = 0.0

	for y in steps:
		for x in steps:
			_x = x * spacing
			_y = y * spacing

			height = heightmap.get_point(
				round(x * ratio),
				round(y * ratio)
			) * height_scale + height_offset

#			st.add_color(Color(1,1,1))
			st.add_uv(Vector2(x / steps, y / steps))
			st.add_vertex(Vector3(_x, height, _y))

			if x and y:
				st.add_index((y - 1) * steps + (x - 1))
				st.add_index(y * steps + x)
				st.add_index(y * steps + x - 1)

				st.add_index((y - 1) * steps + (x - 1))
				st.add_index((y - 1) * steps + x)
				st.add_index(y * steps + x)

	if not wireframe:
		st.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = st.commit()

	output[0].push_back(mesh_instance)
