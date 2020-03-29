tool
extends ConceptNode


func _init() -> void:
	node_title = "Extrude polygon curve"
	category = "Meshes"
	description = "Creates extruded CSG meshes defined by one or multiple polygon curve"

	set_input(0, "Polygon curve", ConceptGraphDataType.POLYGON_CURVE)
	set_input(1, "Depth", ConceptGraphDataType.SCALAR)
	set_input(2, "Material", ConceptGraphDataType.MATERIAL)
	set_input(3, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(4, "Smooth faces", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "Mesh", ConceptGraphDataType.MESH)


func get_output(idx: int) -> Array:
	var result = []

	var polygon_curves = get_input(0)
	var depth = get_input(1, 1.0)
	var material = get_input(2)
	var use_collision = get_input(3, false)
	var smooth = get_input(4, true)

	if not polygon_curves:
		return result
	if not polygon_curves is Array:
		polygon_curves = [polygon_curves]

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
		result.append(mesh)

	return result

# Assumes Y axis is ignored. TODO : Find a more generic way
func _to_pool_vector_2(vectors: PoolVector3Array) -> PoolVector2Array:
	var res = PoolVector2Array()
	for v in vectors:
		res.append(Vector2(v.x, v.z))
	return res
