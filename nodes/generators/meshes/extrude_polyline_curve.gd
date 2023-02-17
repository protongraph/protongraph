extends ProtonNode


func _init() -> void:
	type_id = "extrude_polyline_curve"
	title = "Extrude Polyline (Curved)"
	category = "Generators/Meshes"
	description = "Extrude a polyline along a curve to create a pipe-like mesh"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("cross_section", "Cross section", DataType.POLYLINE_3D, opts)
	create_input("curve", "Curve path", DataType.CURVE_3D, opts)

	opts = SlotOptions.new()
	opts.value = 0
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("loop_cuts", "Loop cuts", DataType.NUMBER, opts)

	create_input("uv_scale", "UV scale", DataType.VECTOR2, SlotOptions.new(Vector2.ONE))
	create_input("smooth_faces", "Smooth faces", DataType.BOOLEAN, SlotOptions.new(false))
	create_input("flip_normals", "Invert normals", DataType.BOOLEAN, SlotOptions.new(false))
	create_input("taper_curve", "Taper ramp", DataType.CURVE_FUNC)

	create_output("out", "Extruded mesh", DataType.MESH_3D)


func _generate_outputs() -> void:
	var cross_section: Polyline3D = get_input_single("cross_section")
	var paths = get_input("curve")
	var taper: Curve = get_input_single("taper_curve")
	var cuts: int = get_input_single("loop_cuts", 0)
	var uv_scale: Vector2 = get_input_single("uv_scale", Vector2.ONE)
	var smooth: bool = get_input_single("smooth_faces", false)
	var flip_normals: bool = get_input_single("flip_normals", false)
	#var close_caps: bool = get_input_single(6, false)

	if not cross_section or paths.is_empty():
		return

	var mesh_instances: Array[MeshInstance3D] = []
	var surface_tool := SurfaceTool.new()

	for path in paths as Array[Path3D]:
		var curve: Curve3D = path.curve
		var curve_length: float = curve.get_baked_length()
		var extrude_steps := cuts + 2
		var extrude_length: float = curve_length / (extrude_steps - 1)
		var point_count: int = cross_section.size()
		var up = Vector3.UP
		var smooth_index = 0 if smooth else -1

		surface_tool.clear()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.set_smooth_group(smooth_index)

		for i in extrude_steps:
			# Current point on curve
			var current_offset: float = i * extrude_length
			var position_on_curve: Vector3 = curve.sample_baked(current_offset)

			# Point slightly ahead for look_at calculations
			var position_2: Vector3
			if current_offset + 0.1 < curve_length:
				position_2 = curve.sample_baked(current_offset + 0.2)
			else:
				position_2 = curve.sample_baked(current_offset - 0.2)
				position_2 += (position_on_curve - position_2) * 2.0

			var taper_size := 1.0
			if taper:
				taper_size = taper.sample(float(i) / float(extrude_steps - 1)) # TODO: check the bake issue

			var node = Node3D.new()

			node.look_at_from_position(position_on_curve, position_2, up)
			up = node.transform.basis.y

			for point_index in point_count:
				var pos = taper_size * cross_section.points[point_index]
				pos = node.transform * pos

				# TODO : Adding UV breaks the smooth group
				surface_tool.set_uv(Vector2(current_offset / curve_length * uv_scale.x, (point_index / float(point_count)) * uv_scale.y))
				surface_tool.add_vertex(pos)

			if i > 0:

				# If the mesh appears inside out, the winding order is incorrect
				if flip_normals:
					for k in (point_count - 1):
						surface_tool.add_index((i - 1) * point_count + k)
						surface_tool.add_index((i - 1) * point_count + k + 1)
						surface_tool.add_index(i * point_count + k)

						surface_tool.add_index(i * point_count + k)
						surface_tool.add_index((i - 1) * point_count + k + 1)
						surface_tool.add_index(i * point_count + k + 1)
				else:
					for k in (point_count - 1):
						surface_tool.add_index((i - 1) * point_count + k)
						surface_tool.add_index(i * point_count + k)
						surface_tool.add_index((i - 1) * point_count + k + 1)

						surface_tool.add_index(i * point_count + k)
						surface_tool.add_index(i * point_count + k + 1)
						surface_tool.add_index((i - 1) * point_count + k + 1)

		# For some reason, the flip_normals parameter here doesn't work
		surface_tool.generate_normals()

		var mi := MeshInstance3D.new()
		mi.transform = path.transform
		mi.name = path.name + " Extruded"
		mi.mesh = ProtonMesh.create_from_arrays(surface_tool.commit_to_arrays())

		mesh_instances.push_back(mi)

	set_output("out", mesh_instances)
