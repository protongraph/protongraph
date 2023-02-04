extends ProtonNode


func _init() -> void:
	type_id = "curve_tesselate_even_length"
	title = "Tesselate (Even)"
	category = "Converters/Curves"
	description = "Creates a Polyline3D from the curve while trying to keep a uniform density."

	create_input("path3d", "Curve", DataType.CURVE_3D)

	var opts := SlotOptions.new()
	opts.value = 4
	opts.step = 1
	opts.min_value = 0
	opts.allow_lesser = false
	create_input("max_stages", "Max stages", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 0.5
	opts.min_value = 0.001
	opts.allow_lesser = false
	opts.step = 0.1
	create_input("tolerance_length", "Max length", DataType.NUMBER, opts)

	create_output("polyline", "Polyline", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var paths: Array = get_input("path3d")
	var max_stages: int = get_input_single("max_stages", 4)
	var tolerance_length: float = get_input_single("tolerance_length", 0.5)
	if paths.is_empty():
		return

	var polylines: Array[Polyline3D] = []

	for path in paths as Array[Path3D]:
		var pl = Polyline3D.new()
		pl.name = "Polyline " + path.name
		pl.points = path.curve.tessellate_even_length(max_stages, tolerance_length)
		pl.transform = path.transform
		polylines.push_back(pl)

	set_output("polyline", polylines)
