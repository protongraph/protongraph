tool
extends ConceptNode

"""
Extrude a curve along another one at constant intervals.
"""

func _init() -> void:
	unique_id = "extrude_bevel_along_path_2d"
	display_name = "Extrude Along Curve 2D"
	category = "Generators/Meshes/2D"
	description = "Extrudes a curve along another curve to create a 2d mesh"

	set_input(0, "Bevel curve", ConceptGraphDataType.VECTOR_CURVE_2D)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE_2D)
	set_input(2, "Taper curve", ConceptGraphDataType.CURVE_FUNC)
	set_input(3, "Polygon length", ConceptGraphDataType.SCALAR, {"min": 1, "value": 50, "step": 1})
	set_input(4, "UV scale", ConceptGraphDataType.VECTOR2, {"min": 0.01, "value": 1.0})
	set_output(0, "Mesh", ConceptGraphDataType.MESH_2D)


func _generate_outputs() -> void:
	var bevel: ConceptNodeVectorCurve2D = get_input_single(0)	# We extrude this
	var paths := get_input(1)	# following these
	var taper: Curve = get_input_single(2)	# and vary its scale at each step based on this
	var polygon_length: float = get_input_single(3, 1.0)	# at this interval
	var uv_scale: Vector2 = get_input_single(4, Vector2.ONE)

	if polygon_length == 0:
		polygon_length = 0.01

	if not bevel or not paths or paths.size() == 0:
		return

	var surface_tool := SurfaceTool.new()

	for path in paths:
		surface_tool.clear()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
		surface_tool.add_smooth_group(true)

		var curve: Curve2D = path.curve
		var length: float = curve.get_baked_length()
		var steps: int = floor(length / polygon_length)
		if steps == 0:
			continue

		var offset: float = length / steps
		var bevel_count: int = bevel.points.size()

		for i in range(steps + 1):
			var current_offset: float = i * offset
			var position_on_curve: Vector2 = curve.interpolate_baked(current_offset)

			var position_2: Vector2
			if current_offset + 0.1 < length:
				position_2 = curve.interpolate_baked(current_offset + 0.1)
			else:
				position_2 = curve.interpolate_baked(current_offset - 0.1)
				position_2 += (position_on_curve - position_2) * 2.0

			var taper_size = 1.0
			if taper:
				taper_size = taper.interpolate_baked(float(i) / float(steps))

			var t = Transform2D()
			t = t.rotated(position_on_curve.angle_to_point(position_2))
			t.origin = position_on_curve

			for j in range(bevel_count):
				var pos = taper_size * bevel.points[j]
				pos = t.xform(pos)

				# TODO : Adding UV breaks the smooth group
				surface_tool.add_color(Color(1, 1, 1, 1));
				surface_tool.add_uv(Vector2(current_offset / length * uv_scale.x, j / float(bevel_count) * uv_scale.y))
				surface_tool.add_vertex(Vector3(pos.x, pos.y, 0.0))

			if i > 0:
				for k in range(bevel_count - 1):
					surface_tool.add_index((i - 1) * bevel_count + k)
					surface_tool.add_index((i - 1) * bevel_count + k + 1)
					surface_tool.add_index(i * bevel_count + k)

					surface_tool.add_index(i * bevel_count + k)
					surface_tool.add_index((i - 1) * bevel_count + k + 1)
					surface_tool.add_index(i * bevel_count + k + 1)

		surface_tool.generate_normals()

		var mesh_instance = MeshInstance2D.new()
		#mesh_instance.transform = path.transform
		mesh_instance.mesh = surface_tool.commit()
		output[0].append(mesh_instance)
