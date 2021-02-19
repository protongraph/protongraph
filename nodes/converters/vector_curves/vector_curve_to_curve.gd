extends ProtonNode


func _init() -> void:
	unique_id = "convert_points_to_curve"
	display_name = "To Curve"
	category = "Converters/Polylines"
	description = "Converts a polyline to a bezier curve"

	set_input(0, "Polyline", DataType.POLYLINE_3D)
	set_output(0, "", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var polylines := get_input(0)
	if not polylines or polylines.size() == 0:
		return

	for pl in polylines:
		var path = Path.new()
		path.curve = Curve3D.new()

		for p in pl.points:
			path.curve.add_point(p)

		path.transform = pl.transform
		output[0].push_back(path)
