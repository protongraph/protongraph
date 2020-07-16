tool
extends ConceptNode


func _init() -> void:
	unique_id = "extrude_curve_straight"
	display_name = "Extrude Polygon Curve"
	category = "Generators/Meshes"
	description = "Creates extruded CSG meshes defined by one or multiple polygon curve"

	set_input(0, "Polygon curve", ConceptGraphDataType.VECTOR_CURVE_3D)
	set_input(1, "Depth", ConceptGraphDataType.SCALAR)
	set_input(2, "Material", ConceptGraphDataType.MATERIAL)
	set_input(3, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Smooth faces", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_input(5, "Axis", ConceptGraphDataType.VECTOR3)
	set_input(6, "Local Space", ConceptGraphDataType.BOOLEAN, {"value": false})
	set_output(0, "Mesh", ConceptGraphDataType.MESH_3D)


func _generate_outputs() -> void:
	var polygon_curves := get_input(0)
	var depth: float = get_input_single(1, 1.0)
	var material: Material = get_input_single(2)
	var use_collision: bool = get_input_single(3, false)
	var smooth: bool = get_input_single(4, true)
	var axis: Vector3 = get_input_single(5, Vector3.UP)
	axis = axis.normalized()
	var local: bool = get_input_single(6, false)

	var up := Vector3.UP
	if axis == Vector3.UP or axis == Vector3.DOWN:
		up = Vector3.BACK

	if not polygon_curves:
		return

	for i in range(polygon_curves.size()):
		var pc := polygon_curves[i] as ConceptNodeVectorCurve
		var polygon = pc.to_pool_vector_2(axis, !local)

		var mesh = CSGPolygon.new()
		mesh.polygon = polygon
		mesh.depth = depth
		mesh.smooth_faces = smooth
		mesh.use_collision = use_collision
		mesh.material = material
		var t = pc.transform
		if local:
			mesh.transform = t.looking_at(t.xform(axis), t.xform(up))
		else:
			mesh.transform = t.looking_at(t.origin + axis, up)

		output[0].append(mesh)

