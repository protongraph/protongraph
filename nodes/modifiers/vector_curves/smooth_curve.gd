extends ProtonNode


func _init() -> void:
	unique_id = "curve_smooth"
	display_name = "Smooth Polyline"
	category = "Modifiers/Polylines"
	description = "Smooth a polyline. Does not create new points."

	set_input(0, "Curve", DataType.POLYLINE_3D)
	set_input(1, "Smooth", DataType.SCALAR, {"value": 0.25, "min": 0, "max": 1, "allow_lesser": false, "allow_greater": false})
	set_input(2, "Steps", DataType.SCALAR, {"step": 1, "allow_lesser": false, "value": 1})
	set_output(0, "", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var vcurves := get_input(0)
	var smooth: float = get_input_single(1, 0.25)
	var steps: int = get_input_single(2, 1)

	for polyline in vcurves:
		var point_count = polyline.points.size()
		var closed: bool = polyline.points[0] == polyline.points[point_count - 1]

		for i in steps:
			var previous: Vector3
			var next: Vector3
			var mean: Vector3
			var points := PoolVector3Array()

			for j in point_count:
				if j == 0:
					if not closed:
						points.push_back(polyline.points[0])
						continue
					previous = polyline.points[point_count - 2]
				else:
					previous = polyline.points[j - 1]

				if j == point_count - 1:
					if not closed:
						points.push_back(polyline.points[j])
						continue
					next = polyline.points[1]
				else:
					next = polyline.points[j + 1]

				mean = (previous + next) / 2.0
				points.push_back(lerp(polyline.points[j], mean, smooth))

			polyline.points = points

		output[0].push_back(polyline)
