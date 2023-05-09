extends ProtonNode


var _polylines: Array[Polyline3D]
var _depth: float
var _cuts: int
var _smooth: bool
var _axis: Vector3
var _local_space: bool
var _taper: Curve
var _flip_normals: bool
var _top_cap: bool
var _bottom_cap: bool


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
	create_input("top_cap", "Top cap", DataType.BOOLEAN, SlotOptions.new(true))
	create_input("bottom_cap", "Bottom cap", DataType.BOOLEAN, SlotOptions.new(true))
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
	_polylines.assign(get_input("cross_section", []))
	_depth = get_input_single("depth", 1.0)
	_cuts = get_input_single("loop_cuts", 0)
	_smooth = get_input_single("smooth", false)
	_axis = get_input_single("axis", Vector3.UP)
	_local_space = get_input_single("space", true)
	_taper = get_input_single("taper_curve")
	_flip_normals = get_input_single("flip_normals", false)
	_top_cap = get_input_single("top_cap", true)
	_bottom_cap = get_input_single("bottom_cap", true)

	# Data validation
	if _polylines.is_empty():
		return

	_axis = _axis.normalized()
	_cuts = max(_cuts, 0) # Negative cuts aren't possible

	var mesh_instances: Array[MeshInstance3D] = []

	for pl in _polylines:
		var instances: Array[MeshInstance3D] = []
		instances.push_back(_extrude_main_body(pl))
		if _top_cap:
			instances.push_back(_create_cap(pl, 1.0))
		if _bottom_cap:
			instances.push_back(_create_cap(pl, 0.0))

		var mi := MeshUtil.merge_mesh_surfaces(instances)
		mi.transform = pl.get_transform()
		mi.name = pl.name + " Extruded"
		mesh_instances.push_back(mi)

		# Cleanup
		MemoryUtil.safe_free(instances)

	set_output("mesh", mesh_instances)


func _extrude_main_body(pl: Polyline3D) -> MeshInstance3D:
	var point_count := pl.size()
	if point_count < 3:
		return null # Not enough vertices to create a polygon.

	var extrude_steps := _cuts + 2
	var extrude_length: float = _depth / (extrude_steps - 1)

	var transform := pl.get_transform()
	var global_axis: Vector3 = _axis * transform.basis
	var smooth_index = 0 if _smooth else -1
	var closed_loop = VectorUtil.are_equal_approx(pl.points[0], pl.points[-1])

	var surface_tool := SurfaceTool.new()
	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_smooth_group(smooth_index)

	for i in extrude_steps:
		var taper_size := 1.0
		if _taper:
			taper_size = _taper.sample_baked(float(i) / float(extrude_steps - 1))

		var extrude_axis := global_axis
		if _local_space:
			extrude_axis = _axis

		extrude_axis *= i * extrude_length

		for point_index in point_count:
			var pos: Vector3 = taper_size * pl.points[point_index] + extrude_axis
			surface_tool.add_vertex(pos)

		if i > 0:
			if _flip_normals:
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
	mi.mesh = surface_tool.commit()
	return mi


func _create_cap(pl: Polyline3D, top: bool) -> MeshInstance3D:
	var count := pl.size()
	var curve_position: float = 1.0 if top else 0.0
	var taper_size: float = _taper.sample_baked(curve_position)
	if abs(taper_size) < 0.0001:
		return null

	var polygon = PackedVector2Array()
	var offset := _axis * _depth * curve_position
	var normal := _axis
	if not top:
		normal *= -1

	var surface_tool = SurfaceTool.new()
	surface_tool.clear()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for i in count:
		var pos = pl.points[i] * taper_size + offset
		polygon.push_back(Vector2(pos.x, pos.z))
		surface_tool.set_normal(normal)
		surface_tool.add_vertex(pos)

	if not top:
		polygon.reverse()

	var indices := Geometry2D.triangulate_polygon(polygon)
	#var indices := Geometry2D.triangulate_delaunay(polygon)
	for idx in indices:
		surface_tool.add_index(idx)

	var mi := MeshInstance3D.new()
	mi.transform = pl.get_transform()
	mi.mesh = surface_tool.commit()
	return mi
