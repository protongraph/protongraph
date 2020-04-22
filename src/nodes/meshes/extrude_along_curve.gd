tool
extends ConceptNode


func _init() -> void:
	node_title = "Extrude along curve"
	category = "Meshes"
	description = "Extrudes a curve along another curve to create a pipe-like mesh"

	set_input(0, "Bevel curve", ConceptGraphDataType.VECTOR_CURVE)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE)
	set_input(2, "Taper curve", ConceptGraphDataType.MATH_CURVE)
	set_input(3, "Resolution", ConceptGraphDataType.SCALAR, {"min": 0.01, "value": 1.0})
	set_output(0, "Mesh", ConceptGraphDataType.MESH)


func get_output(idx: int) -> Array:
	var result = []
	var bevel = get_input(0)
	var paths = get_input(1, 1.0)
	var taper: Curve = get_input(2)
	var resolution: float = get_input(3, 1.0)

	if not bevel or not paths:
		return result
	if bevel is Array:
		bevel = bevel[0]
	if not paths is Array:
		paths = [paths]
	if paths.size() == 0:
		return result

	for path in paths:
		var surface_tool = SurfaceTool.new()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
		surface_tool.add_smooth_group(true)

		var curve: Curve3D = path.curve
		var length = curve.get_baked_length()
		var steps = floor(length / resolution)
		var offset = length / steps
		var bevel_count = bevel.points.size()

		for i in range(steps + 1):
			var position_on_curve = curve.interpolate_baked(i * offset)
			var taper_size = taper.interpolate_baked(float(i) / float(steps))

			for j in range(bevel_count):
				var pos = taper_size * bevel.points[j] + position_on_curve # TODO : do a proper transform
				# TODO: Scale according to taper
				surface_tool.add_color(Color(1, 1, 1, 1));
				surface_tool.add_vertex(pos)

			if i > 0:
				for k in range(bevel_count - 1):
					surface_tool.add_index((i - 1) * bevel_count + k)
					surface_tool.add_index((i - 1) * bevel_count + k + 1)
					surface_tool.add_index(i * bevel_count + k)

					surface_tool.add_index(i * bevel_count + k)
					surface_tool.add_index((i - 1) * bevel_count + k + 1)
					surface_tool.add_index(i * bevel_count + k + 1)

		surface_tool.generate_normals()

		var mesh_instance = MeshInstance.new()
		mesh_instance.transform = path.transform
		mesh_instance.mesh = surface_tool.commit()
		result.append(mesh_instance)

	return result
