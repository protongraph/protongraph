extends ProtonNode


func _init() -> void:
	type_id = "curve_tesselate_control_only"
	title = "Tesselate (Control points)"
	category = "Converters/Curves"
	description = "Creates a Polyline3D from the curve control points only."

	create_input("path3d", "Curve", DataType.CURVE_3D)
	create_output("polyline", "Polyline", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var paths: Array = get_input("path3d")
	if paths.is_empty():
		return

	var polylines: Array[Polyline3D] = []

	for path in paths as Array[Path3D]:
		var pl = Polyline3D.new()
		var points = PackedVector3Array()
		var curve: Curve3D = path.curve

		for i in curve.get_point_count():
			points.push_back(curve.get_point_position(i))

		pl.name = "Polyline " + path.name
		pl.points = points
		pl.transform = path.transform
		polylines.push_back(pl)

	set_output("polyline", polylines)
