extends ProtonNode


func _init() -> void:
	type_id = "convert_points_to_curve"
	title = "To Curve"
	category = "Converters/Polylines"
	description = "Converts polylines to bezier curves"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("polylines", "Polyline", DataType.POLYLINE_3D, opts)
	create_output("paths", "Curve 3D", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var polylines = get_input("polylines")

	if polylines.is_empty():
		return

	var out: Array[Path3D] = []

	for pl in polylines:
		var path := Path3D.new()
		path.curve = Curve3D.new()

		for p in pl.points:
			path.curve.add_point(p)

		path.transform = pl.transform
		out.push_back(path)

	set_output("paths", out)
