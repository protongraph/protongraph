tool
extends ConceptNode

"""
Extrude a curve along another one at constant intervals.
"""

func _init() -> void:
	unique_id = "extrude_bevel_along_path"
	display_name = "Extrude along curve"
	category = "Meshes"
	description = "Extrudes a curve along another curve to create a pipe-like mesh"

	set_input(0, "Bevel curve", ConceptGraphDataType.VECTOR_CURVE)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE)
	set_input(2, "Taper curve", ConceptGraphDataType.MATH_CURVE)
	set_input(3, "Resolution", ConceptGraphDataType.SCALAR, {"min": 0.01, "value": 1.0})
	set_input(4, "Merge all", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "Mesh", ConceptGraphDataType.MESH)


func get_output(idx: int) -> Array:
	var result = []
	var bevel = get_input(0)	# We extrude this
	var paths = get_input(1, 1.0)	# following this
	var taper: Curve = get_input(2)	# and vary its scale at each step based on this
	var resolution: float = get_input(3, 1.0)	# at this interval

	if not bevel or not paths:
		return result
	if bevel is Array:
		bevel = bevel[0]
	if not paths is Array:
		paths = [paths]
	if paths.size() == 0:
		return result

	var surface_tool := SurfaceTool.new()

	for path in paths:
		surface_tool.clear()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
		surface_tool.add_smooth_group(true)

		var curve: Curve3D = path.curve
		var length: float = curve.get_baked_length()
		var steps: int = floor(length / resolution)
		var offset: float = length / steps
		var bevel_count: int = bevel.points.size()
		var up = Vector3(0, 1, 0)

		for i in range(steps + 1):
			var current_offset: float = i * offset
			var position_on_curve: Vector3 = curve.interpolate_baked(current_offset)

			var position_2: Vector3
			if current_offset + 0.1 < length:
				position_2 = curve.interpolate_baked(current_offset + 0.1)
			else:
				position_2 = curve.interpolate_baked(current_offset - 0.1)
				position_2 += (position_on_curve - position_2) * 2.0

			var taper_size = 1.0
			if taper:
				taper_size = taper.interpolate_baked(float(i) / float(steps))
			var node = Spatial.new()

			node.look_at_from_position(position_on_curve, position_2, up)
			up = node.transform.basis.y

			for j in range(bevel_count):

				var pos = taper_size * bevel.points[j]
				pos = node.transform.xform(pos)

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
