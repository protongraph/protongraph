class_name CurveUtil


# Utility tools for 3D curves related operations


static func make_polygons_path(paths: Array, axis: Vector3, resolution: float = 1.0) -> Array:
	var result = []
	for path in paths:
		var curve = path.curve
		var connections = PoolIntArray()
		var polygon_points = PoolVector2Array()
		var polygon = PolygonPathFinder.new()

		var length = curve.get_baked_length()
		var steps = round(length / resolution)

		if steps == 0:
			continue

		for i in range(steps):
			# Get a point on the curve
			var transform = path.transform
			if path.is_inside_tree():
				transform = path.global_transform
			var coords_3d = transform.xform(curve.interpolate_baked((i/(steps-2)) * length))
			var coords = VectorUtil.project(coords_3d, axis)

			# Store polygon data
			polygon_points.push_back(coords)
			connections.push_back(i)
			if(i == steps - 1):
				connections.push_back(0)
			else:
				connections.push_back(i + 1)

		polygon.setup(polygon_points, connections)
		result.push_back(polygon)

	return result


# TODO : fix duplicate code with the above function
static func make_polygons_points(paths: Array, resolution: float = 1.0) -> Array:
	var result = []
	for path in paths:
		var curve = path.curve
		var polygon_points = PoolVector2Array()

		var length = curve.get_baked_length()
		var steps = round(length / resolution)

		if steps == 0:
			continue

		for i in range(steps):
			var coords_3d = curve.interpolate_baked((i / (steps-2)) * length)
			var coords = Vector2(coords_3d.x, coords_3d.z)
			polygon_points.push_back(coords)

		result.push_back(polygon_points)

	return result


static func make_polygons_path_2d(paths: Array, resolution: float = 50.0) -> Array:
	var result = []
	for path in paths:
		var curve = path.curve
		var connections = []
		var polygon_points = []
		var polygon = PolygonPathFinder.new()

		var length = curve.get_baked_length()
		var steps = round(length / resolution)

		if steps == 0:
			continue

		for i in range(steps):
			# Get a point on the curve
			var transform = path.transform
			if path.is_inside_tree():
				transform = path.global_transform
			var coords = transform.xform(curve.interpolate_baked((i / (steps - 2)) * length))

			# Store polygon data
			polygon_points.push_back(coords)
			connections.push_back(i)
			if(i == steps - 1):
				connections.push_back(0)
			else:
				connections.push_back(i + 1)

		polygon.setup(polygon_points, connections)
		result.push_back(polygon)

	return result
