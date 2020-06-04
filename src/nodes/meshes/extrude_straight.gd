tool
extends ConceptNode


func _init() -> void:
	unique_id = "extrude_curve_straight"
	display_name = "Extrude Polygon Curve"
	category = "Meshes"
	description = "Creates extruded CSG meshes defined by one or multiple polygon curve"

	set_input(0, "Polygon curve", ConceptGraphDataType.VECTOR_CURVE)
	set_input(1, "Depth", ConceptGraphDataType.SCALAR)
	set_input(2, "Material", ConceptGraphDataType.MATERIAL)
	set_input(3, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Smooth faces", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "Mesh", ConceptGraphDataType.MESH)


func _generate_outputs() -> void:
	var polygon_curves := get_input(0)
	var depth: float = get_input_single(1, 1.0)
	var material: Material = get_input_single(2)
	var use_collision: bool = get_input_single(3, false)
	var smooth: bool = get_input_single(4, true)

	if not polygon_curves:
		return

	for i in range(polygon_curves.size()):
		var pc = polygon_curves[i]
		var polygon = _to_pool_vector_2(pc.points)
		var mesh = CSGPolygon.new()
		mesh.rotation = Vector3(PI/2.0, 0.0, 0.0) # TODO : link it to the curve projection axis
		mesh.translation = pc.translation
		mesh.polygon = polygon
		mesh.depth = depth
		mesh.smooth_faces = smooth
		mesh.use_collision = use_collision
		mesh.material = material
		output[0].append(mesh)


# Assumes Y axis is ignored. TODO : Find a more generic way
func _to_pool_vector_2(vectors: PoolVector3Array) -> PoolVector2Array:
	var res = PoolVector2Array()
	for v in vectors:
		res.append(Vector2(v.x, v.y))
	return res
