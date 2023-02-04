extends ProtonNode


func _init() -> void:
	type_id = "curve_tesselate_curvature"
	title = "Tesselate (Curvature)"
	category = "Converters/Curves"
	description = "Creates a vector curve with a curvature controlled point density"

	var opts := SlotOptions.new()
	opts.allow_multiple_connections = true
	create_input("curve", "Curve", DataType.CURVE_3D, opts)

	opts = SlotOptions.new()
	opts.value = 4
	opts.step = 1
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("max_stages", "Max stages", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 4.0
	opts.min_value = 0.0
	opts.max_value = 360.0
	opts.allow_lesser = false
	opts.allow_greater = false
	create_input("tolerance", "Tolerance", DataType.NUMBER, opts)

	create_output("polyline", "Polyline", DataType.POLYLINE_3D)

	documentation.add_paragraph("Converts a bezier curve to a vector curve with
		a curvature controlled point density. That means, the curvier parts will
		have more points than the straighter parts.")
	documentation.add_paragraph("This approximation makes straight segments
		between each point, then subdivides those segments until the resulting
		shape is similar enough.")

	var p := documentation.add_parameter("Max stages")
	p.set_type("int")
	p.set_description("Controls how many subdivisions a curve segment may face
		before it's considered close enough. Each subdivision splits the segment
		in half.")
	p.set_cost(1)

	p = documentation.add_parameter("Tolerance")
	p.set_type("float")
	p.set_description("How many degrees the midpoint of a segment may deviate
		from the real curve, before the segment has to be subdivided.")


func _generate_outputs() -> void:
	var paths: Array = get_input("curve")
	if paths.is_empty():
		return

	var stages: int = get_input_single("max_stages", 1)
	var tolerance: float = get_input_single("tolerance", 4.0)
	var polylines: Array[Polyline3D] = []

	for path in paths as Array[Path3D]:
		var pl := Polyline3D.new()
		pl.points = path.curve.tessellate(stages, tolerance) # TODO: Might be bugged upstream
		pl.transform = path.transform
		pl.name = "Polyline " + path.name
		polylines.push_back(pl)

	set_output("polyline", polylines)
