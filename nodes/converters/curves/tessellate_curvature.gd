extends ProtonNode


func _init() -> void:
	unique_id = "curve_tesselate_curvature"
	display_name = "To Polyline (Curvature)"
	category = "Converters/Curves"
	description = "Creates a polyline with a curvature controlled point density"

	set_input(0, "Curve", DataType.CURVE_3D)
	set_input(1, "Max stages", DataType.SCALAR,
		{"value": 4, "step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Tolerance", DataType.SCALAR,
		{"value": 4, "min": 0, "max": 360,
		"allow_lesser": false, "allow_greater": false, })
	set_output(0, "", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return

	var stages: int = get_input_single(1, 1)
	var tolerance: float = get_input_single(2, 4.0)

	for path in paths:
		var p = Polyline.new()
		p.points = path.curve.tessellate(stages, tolerance)
		p.transform = path.transform
		output[0].push_back(p)
