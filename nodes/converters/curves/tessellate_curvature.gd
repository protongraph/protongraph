extends ProtonNode


func _init() -> void:
	unique_id = "curve_tesselate_curvature"
	display_name = "Tesselate (Curvature)"
	category = "Converters/Curves"
	description = "Creates a vector curve with a curvature controlled point density"

	set_input(0, "Curve", DataType.CURVE_3D)
	set_input(1, "Max stages", DataType.SCALAR,
		{"value": 4, "step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Tolerance", DataType.SCALAR,
		{"value": 4, "min": 0, "max": 360,
		"allow_lesser": false, "allow_greater": false, })
	set_output(0, "", DataType.VECTOR_CURVE_3D)

	doc.add_paragraph("""Converts a bezier curve to a vector curve with a
		curvature controlled point density. That is, the curvier parts will
		have more points than the straighter parts.""")
	doc.add_paragraph("""This approximation makes straight segments between
		each point, then subdivides those segments until the resulting shape is
		similar enough.""")
	
	doc.add_parameter("Max stages",
		"""Controls how many subdivisions a curve segment may face before it
		is considered approximate enough. Each subdivision splits the segment
		in half.""", {"cost": 1})
	doc.add_parameter("Tolerance",
		"""Controls how many degrees the midpoint of a segment may deviate
		from the real curve, before the segment has to be subdivided.""")


func _generate_outputs() -> void:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return

	var stages: int = get_input_single(1, 1)
	var tolerance: float = get_input_single(2, 4.0)

	for path in paths:
		var p = VectorCurve.new()
		p.points = path.curve.tessellate(stages, tolerance)
		p.transform = path.transform
		output[0].push_back(p)
