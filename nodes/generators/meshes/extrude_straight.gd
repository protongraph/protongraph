tool
extends ProtonNode


func _init() -> void:
	unique_id = "extrude_curve_straight"
	display_name = "Extrude Polygon Curve"
	category = "Generators/Meshes"
	description = "Creates extruded CSG meshes defined by one or multiple polygon curve"

	set_input(0, "Cross section", DataType.POLYLINE_3D)
	set_input(1, "Depth", DataType.SCALAR)
	set_input(2, "Smooth faces", DataType.BOOLEAN, {"value": true})
	set_input(3, "Axis", DataType.VECTOR3)
	set_input(4, "Local space", DataType.BOOLEAN, {"value": false})
	set_output(0, "Mesh", DataType.MESH_3D)


func _generate_outputs() -> void:
	var vector_curves := get_input(0)
	var depth: float = get_input_single(1, 1.0)
	var smooth: bool = get_input_single(2, true)
	var axis: Vector3 = get_input_single(3, Vector3.UP)
	axis = axis.normalized()
	var local: bool = get_input_single(4, false)

	var up := Vector3.UP
	if axis == Vector3.UP or axis == Vector3.DOWN:
		up = Vector3.BACK

	if not vector_curves:
		return

	for vc in vector_curves:
		var polygon = vc.to_pool_vector_2(axis, !local)

		var mesh = CSGPolygon.new()
		mesh.polygon = polygon
		mesh.depth = depth
		mesh.smooth_faces = smooth

		var t = vc.transform
		if local:
			mesh.transform = t.looking_at(t.xform(axis), t.xform(up))
		else:
			mesh.transform = t.looking_at(t.origin + axis, up)

		output[0].push_back(mesh)
