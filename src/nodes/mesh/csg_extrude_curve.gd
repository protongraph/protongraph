tool
class_name ConceptNodeCsgExtrudeCurve
extends ConceptNode


func _init() -> void:
	node_title = "Extrude curve"
	category = "CSG"
	description = "Creates extruded CSG meshes defined by one or multiple curves"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Resolution", ConceptGraphDataType.SCALAR, {"exp_edit": false})
	set_input(2, "Depth", ConceptGraphDataType.SCALAR)
	set_input(3, "Material", ConceptGraphDataType.MATERIAL)
	set_input(4, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(5, "Smooth faces", ConceptGraphDataType.BOOLEAN, {"value": true})
	set_output(0, "Mesh", ConceptGraphDataType.MESH)




func get_output(idx: int) -> Array:
	var result = []

	var curves = get_input(0)
	var resolution = get_input(1, 1.0)
	var depth = get_input(2, 1.0)
	var material = get_input(3)
	var use_collision = get_input(4, false)
	var smooth = get_input(5, true)

	if not curves:
		return result
	if not curves is Array:
		curves = [curves]

	var polygons = ConceptGraphCurveUtil.make_polygons_points(curves, resolution)

	for polygon in polygons:
		var mesh = CSGPolygon.new()
		mesh.rotation = Vector3(PI/2.0, 0.0, 0.0) # TODO : link it to the curve projection axis
		mesh.polygon = polygon
		mesh.depth = depth
		mesh.smooth_faces = smooth
		result.append(mesh)

	return result

