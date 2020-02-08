"""
Discard all the transforms inside (or outside) the provided curves
"""

tool
class_name ConceptNodeExcludeTransformsFromCurve
extends ConceptNode


var _resolution := 0.2 #tmp


func _init() -> void:
	set_input(0, "Transforms", ConceptGraphDataType.TRANSFORM)
	set_input(1, "Curves", ConceptGraphDataType.CURVE)
	set_input(2, "Invert", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.TRANSFORM)


func get_node_name() -> String:
	return "Exclude from curves"


func get_category() -> String:
	return "Transforms"


func get_description() -> String:
	return "Discard all the transforms inside (or outside) the provided curves"


func get_output(idx: int) -> Array:
	var transforms = get_input(0)
	var curves = get_input(1)
	var invert = get_input(2)
	var result = []

	if not curves is Array:
		curves = [curves]

	var polygons = _make_polygons_from_curves(curves)

	for transform in transforms:
		var point = Vector2(transform.origin.x, transform.origin.z)
		var inside = false
		for polygon in polygons:
			if polygon.is_point_inside(point):
				inside = true

		if invert:
			inside = !inside

		if !inside:
			result.append(transform)

	return result


func _make_polygons_from_curves(curves: Array) -> Array:
	var result = []
	for curve in curves:
		var connections = PoolIntArray()
		var polygon_points = PoolVector2Array()
		var polygon = PolygonPathFinder.new()

		var length = curve.get_baked_length()
		var steps = round(length / _resolution)

		if steps == 0:
			continue

		for i in range(steps):
			# Get a point on the curve
			var coords_3d = curve.interpolate_baked((i/(steps-2)) * length)
			var coords = Vector2(coords_3d.x, coords_3d.z)

			# Store polygon data
			polygon_points.append(coords)
			connections.append(i)
			if(i == steps - 1):
				connections.append(0)
			else:
				connections.append(i + 1)

		polygon.setup(polygon_points, connections)
		result.append(polygon)

	return result
