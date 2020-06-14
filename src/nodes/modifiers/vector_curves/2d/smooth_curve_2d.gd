tool
extends ConceptNode


func _init() -> void:
	unique_id = "curve_smooth_2d"
	display_name = "Smooth Vector Curve 2D"
	category = "Modifiers/Vector Curves/2D"
	description = "Smooth a vector curve. Does not create new points."

	set_input(0, "Curve", ConceptGraphDataType.VECTOR_CURVE_2D)
	set_input(1, "Smooth", ConceptGraphDataType.SCALAR, {"value": 0.25, "min": 0, "max": 1})
	set_input(2, "Steps", ConceptGraphDataType.SCALAR, {"step": 1, "allow_lesser": false, "value": 1})
	set_output(0, "", ConceptGraphDataType.VECTOR_CURVE_2D)


func _generate_outputs() -> void:
	var vcurves := get_input(0)
	var smooth: float = get_input_single(1, 0.25)
	var steps: int = get_input_single(2, 1)

	for vector_curve in vcurves:
		var point_count = vector_curve.points.size()
		var closed: bool = vector_curve.points[0] == vector_curve.points[point_count - 1]

		for i in steps:
			var previous: Vector2
			var next: Vector2
			var mean: Vector2
			var points := []

			for j in point_count:
				if j == 0:
					if not closed:
						points.append(vector_curve.points[0])
						continue
					previous = vector_curve.points[point_count - 2]
				else:
					previous = vector_curve.points[j - 1]

				if j == point_count - 1:
					if not closed:
						points.append(vector_curve.points[j])
						continue
					next = vector_curve.points[1]
				else:
					next = vector_curve.points[j + 1]

				mean = (previous + next) / 2.0
				points.append(lerp(vector_curve.points[j], mean, smooth))

			vector_curve.points = points

		output[0].append(vector_curve)
