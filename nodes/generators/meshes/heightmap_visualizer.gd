extends ProtonNode


func _init() -> void:
	unique_id = "heightmap_visualizer"
	display_name = "Heightmap Visualizer"
	category = "Generators/Meshes"
	description = "Uses a shader to visualize a 3D heightmap, " + \
		"it doesn't actually edit the geometry so it's a lot faster than 'Heightmap to Mesh'"

	set_input(0, "HeightMap", DataType.HEIGHTMAP)
	set_input(1, "Show Color", DataType.BOOLEAN)
	set_output(0, "", DataType.MESH_3D)


func _generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)

	var mesh = PlaneMesh.new()
	mesh.size = heightmap.mesh_size
	mesh.subdivide_width = heightmap.size.x - 2
	mesh.subdivide_depth = heightmap.size.y - 2
	
	var material: ShaderMaterial = load("res://common/lib/heightmap.tres")
	var texture = ImageTexture.new()
	texture.create_from_image(heightmap.get_image())
	texture.set_flags(Texture.FLAG_FILTER + Texture.FLAG_MIPMAPS)
	material.set_shader_param("heightmap", texture)
	material.set_shader_param("texture_size", heightmap.size.x)
	material.set_shader_param("scale", heightmap.height_scale)
	material.set_shader_param("offset", heightmap.height_offset)
	material.set_shader_param("show_color", get_input_single(1, true))
	
	var mi = MeshInstance.new()
	mi.mesh = mesh
	mi.material_override = material
	mi.translate(Vector3(mesh.size.x * 0.5, 0.0, mesh.size.y * 0.5))
	
	output[0].push_back(mi)
