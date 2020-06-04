tool
extends ConceptNode


func _init() -> void:
	unique_id = "mesh_from_heightmap"
	display_name = "Mesh from Heightmap"
	category = "Heightmaps"
	description = "Creates a mesh from a heightmap"

	set_input(0, "HeightMap", ConceptGraphDataType.HEIGHTMAP)
	set_input(1, "Mesh density", ConceptGraphDataType.SCALAR, {"value": 1})
	set_output(0, "", ConceptGraphDataType.MESH)


func _generate_outputs() -> void:
	var heightmap: ConceptGraphHeightmap = get_input_single(0)
	var density: float = get_input_single(1, 1.0)

	if not heightmap or density == 0:
		return

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var mesh_size: float = heightmap.mesh_size.x
	var steps: int = round(mesh_size * density)
	var offset: float = 1.0 / density
	var ratio: float

	ratio = heightmap.size.x / steps

	for y in steps:
		for x in steps:
			st.add_color(Color(1,1,1))
			st.add_uv(Vector2(x / steps, y / steps))
			st.add_vertex(Vector3(x * offset, heightmap.get_point(round(x * ratio), round(y * ratio)), y * offset))

			if x > 0 and y > 0:
				st.add_index((y - 1) * steps + (x - 1))
				st.add_index(y * steps + x)
				st.add_index(y * steps + x - 1)

				st.add_index((y - 1) * steps + (x - 1))
				st.add_index((y - 1) * steps + x)
				st.add_index(y * steps + x)

	st.generate_normals()

	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = st.commit()
	output[0].append(mesh_instance)
