tool
extends ConceptNode

"""
Extrude a curve along another one at constant intervals.
"""

func _init() -> void:
	unique_id = "extrude_bevel_along_path"
	display_name = "Extrude Along Curve"
	category = "Generators/Meshes"
	description = "Extrudes a curve along another curve to create a pipe-like mesh"

	set_input(0, "Bevel curve", ConceptGraphDataType.VECTOR_CURVE_3D)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE_3D)
	set_input(2, "Taper curve", ConceptGraphDataType.CURVE_FUNC)
	set_input(3, "Resolution", ConceptGraphDataType.SCALAR, {"min": 0.01, "value": 1.0})
	set_input(4, "UV scale", ConceptGraphDataType.VECTOR2, {"min": 0.01, "value": 1.0})
	set_input(5, "Smooth", ConceptGraphDataType.BOOLEAN, {"value": false})
	#set_input(6, "Close caps", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_output(0, "Mesh", ConceptGraphDataType.MESH_3D)


func _generate_outputs() -> void:
	var bevel: ConceptNodeVectorCurve = get_input_single(0)	# We extrude this
	var paths := get_input(1)	# following these
	var taper: Curve = get_input_single(2)	# and vary its scale at each step based on this
	var resolution: float = get_input_single(3, 1.0)	# at this interval
	var uv_scale: Vector2 = get_input_single(4, 1.0)
	var smooth: bool = get_input_single(5, false)
	#var close_caps: bool = get_input_single(6, false)

	if resolution == 0:
		resolution = 0.01

	if not bevel or not paths or paths.size() == 0:
		return

	var surface_tool := SurfaceTool.new()

	for path in paths:
		surface_tool.clear()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
		surface_tool.add_smooth_group(smooth)

		var curve: Curve3D = path.curve
		var length: float = curve.get_baked_length()
		var steps: int = floor(length / resolution)
		if steps == 0:
			continue

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

				# TODO : Adding UV breaks the smooth group
				surface_tool.add_color(Color(1, 1, 1, 1));
				surface_tool.add_uv(Vector2(current_offset / length * uv_scale.x, j / float(bevel_count) * uv_scale.y))
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
		output[0].append(mesh_instance)
