extends ProtonNode


func _init() -> void:
	type_id = "extrude_polyline_straight"
	title = "Extrude Polyline (Straight)"
	category = "Generators/Meshes"
	description = "Extrude polyline(s) along an axis"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("cross_section", "Cross section", DataType.POLYLINE_3D, opts)
	create_input("depth", "Depth", DataType.NUMBER, SlotOptions.new(1.0))

	opts = SlotOptions.new()
	opts.value = 0
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("loop_cuts", "Loop cuts", DataType.NUMBER, opts)
	create_input("axis", "Axis", DataType.VECTOR3, SlotOptions.new(Vector3.UP))
	create_input("space", "Local space", DataType.BOOLEAN, SlotOptions.new(true))
	create_input("smooth", "Smooth faces", DataType.BOOLEAN, SlotOptions.new(false))
	#create_input("top_cap", "Top cap", DataType.BOOLEAN, SlotOptions.new(true))
	#create_input("bottom_cap", "Bottom cap", DataType.BOOLEAN, SlotOptions.new(true))
	create_input("flip_normals", "Invert normals", DataType.BOOLEAN, SlotOptions.new(false))
	create_input("taper_curve", "Taper ramp", DataType.CURVE_FUNC)

	create_output("mesh", "Extruded mesh", DataType.MESH_3D)

# TODO:
# - If the polyline is closed, first and last point should be shared
# - caps
# - ensure normals are facing outwards
# - Invert normals?
# - Merge points if taper_size = 0?

func _generate_outputs() -> void:
	var polylines: Array = get_input("cross_section")
	var depth: float = get_input_single("depth", 1.0)
	var cuts: int = get_input_single("loop_cuts", 0)
	var smooth: bool = get_input_single("smooth", false)
	var axis: Vector3 = get_input_single("axis", Vector3.UP)
	var local_space: bool = get_input_single("space", true)
	var taper: Curve = get_input_single("taper_curve")
	var flip_normals: bool = get_input_single("flip_normals", false)
	#var top_cap: bool = get_input_single("top_cap", true)
	#var bottom_cap: bool = get_input_single("bottom_cap", true)

	# Data validation
	if polylines.is_empty():
		return

	axis = axis.normalized()
	cuts = max(cuts, 0) # Negative cuts aren't possible
	var smooth_index = 0 if smooth else -1

	# Mesh extrusion
	var mesh_instances: Array[MeshInstance3D] = []
	var surface_tool := SurfaceTool.new()

	for pl in polylines as Array[Polyline3D]:
		var extrude_steps := cuts + 2
		var extrude_length: float = depth / (extrude_steps - 1)
		var point_count := pl.size()
		var transform := pl.get_transform()
		var global_axis: Vector3 = axis * transform.basis

		surface_tool.clear()
		surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		surface_tool.set_smooth_group(smooth_index)

		for i in extrude_steps:
			var taper_size := 1.0
			if taper:
				taper_size = taper.sample(float(i) / float(extrude_steps - 1)) # TODO: check why sample baked crash when threaded

			var extrude_axis := global_axis
			if local_space:
				extrude_axis = axis

			extrude_axis *= i * extrude_length

			for point_index in point_count:
				var pos: Vector3 = taper_size * pl.points[point_index] + extrude_axis
				surface_tool.add_vertex(pos)

			if i > 0:
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

		surface_tool.generate_normals()

		var mi := MeshInstance3D.new()
		mi.transform = pl.get_transform()
		mi.name = pl.name + " Extruded"
		mi.mesh = ProtonMesh.create_from_arrays(surface_tool.commit_to_arrays())

		mesh_instances.push_back(mi)

	set_output("mesh", mesh_instances)
