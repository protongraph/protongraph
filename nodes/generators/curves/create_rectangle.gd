extends ProtonNode


func _init() -> void:
	type_id = "curve_generator_rectangle"
	title = "Create Rectangle"
	category = "Generators/Curves"
	description = "Creates a rectangle shaped curve."

	var opts := SlotOptions.new()
	opts.value = 1.0
	opts.min_value = 0.0
	opts.allow_lesser = false

	create_input("width", "Width", DataType.NUMBER, opts)
	create_input("length", "Length", DataType.NUMBER, opts)
	create_input("up_axis", "Up Axis", DataType.VECTOR3, SlotOptions.new(Vector3.UP))
	create_input("origin", "Origin", DataType.VECTOR3)

	opts = SlotOptions.new()
	opts.value = 0.0
	#opts.step = 0.1
	opts.min_value = 0.0
	opts.allow_lesser = false
	opts.force_vertical = true
	opts.override_vector_options_with_current()
	opts.vec_x.label_override = "Top left"
	opts.vec_y.label_override = "Top right"
	opts.vec_z.label_override = "Bottom left"
	opts.vec_w.label_override = "Bottom right"

	create_input("corners_radius", "Corners radius", DataType.VECTOR4, opts)

	create_output("rectangle", "Rectangle", DataType.CURVE_3D)

	documentation.add_paragraph("Creates a 3D curve object, shaped like a rectangle.")

	var p := documentation.add_parameter("Corners radius")
	p.set_type("Vector4")
	p.set_cost(0)
	p.set_description("Values above zero will round the associated corner")


func _generate_outputs() -> void:
	var width: float = get_input_single("width", 1.0)
	var length: float = get_input_single("length", 1.0)
	var axis: Vector3 = get_input_single("up_axis", Vector3.UP)
	var origin: Vector3 = get_input_single("origin", Vector3.ZERO)
	var radius: Vector4 = get_input_single("corners_radius", Vector4.ZERO)

	# Clamp radius if necessary
	radius.x = _clamp_radius(radius.x, length, radius.z, width, radius.y)
	radius.y = _clamp_radius(radius.y, length, radius.w, width, radius.x)
	radius.z = _clamp_radius(radius.z, length, radius.x, width, radius.w)
	radius.w = _clamp_radius(radius.w, length, radius.y, width, radius.z)

	var circle_mult = 4.0 * (sqrt(2.0) - 1.0) / 3.0
	var offset := Vector3(width / 2.0, -length / 2.0, 0.0)
	var top = width - (radius.x + radius.y)
	var bottom = width - (radius.z + radius.w)
	var left = length - (radius.x + radius.z)
	var right = length - (radius.y + radius.w)

	var t := Transform3D()
	var up := Vector3.UP
	if axis != Vector3.ZERO and axis != up:
		t = t.looking_at(axis.normalized(), up)
	t.origin = origin

	var curve = Curve3D.new()

	var pos := Vector3.ZERO - offset # Move to the top left
	var v_in := Vector3.ZERO
	var v_out := Vector3.ZERO
	pos.x += radius.x
	curve.add_point(pos, v_in, v_out)

	# Top right
	pos.x += top
	v_in = Vector3.ZERO
	v_out = Vector3(radius.y * circle_mult, 0.0, 0.0)
	curve.add_point(pos, v_in, v_out)

	pos.x += radius.y
	pos.y -= radius.y
	v_in = Vector3(0.0, radius.y * circle_mult, 0.0)
	v_out = Vector3.ZERO
	curve.add_point(pos, v_in, v_out)

	# Bottom right
	pos.y -= right
	v_in = Vector3.ZERO
	v_out = Vector3(0.0, -radius.w * circle_mult, 0.0)
	curve.add_point(pos, v_in, v_out)

	pos.y -= radius.w
	pos.x -= radius.w
	v_in = Vector3(radius.w * circle_mult, 0.0, 0.0)
	v_out = Vector3.ZERO
	curve.add_point(pos, v_in, v_out)

	# Bottom left
	pos.x -= bottom
	v_in = Vector3.ZERO
	v_out = Vector3(-radius.z * circle_mult, 0.0, 0.0)
	curve.add_point(pos, v_in, v_out)

	pos.x -= radius.z
	pos.y += radius.z
	v_in = Vector3(0.0, -radius.z * circle_mult, 0.0)
	v_out = Vector3.ZERO
	curve.add_point(pos, v_in, v_out)

	# Top left
	pos.y += left
	v_in = Vector3.ZERO
	v_out = Vector3(0.0, radius.x * circle_mult, 0.0)
	curve.add_point(pos, v_in, v_out)

	pos.y += radius.x
	pos.x += radius.x
	v_in = Vector3(-radius.x * circle_mult, 0.0, 0.0)
	v_out = Vector3.ZERO
	curve.add_point(pos, v_in, v_out)

	var path = Path3D.new()
	path.name = "Rectangle"
	path.curve = curve
	path.transform = t

	set_output("rectangle", path)


# Ensure no corner radius is larger than their edges and neighboring corners radius.
# TODO: double check this logic
func _clamp_radius(r: float, edge_1: float, r1: float, edge_2: float, r2: float) -> float:
	var smallest_edge = min(edge_1, edge_2)
	r = clamp(r, 0.0, smallest_edge)
	r1 = clamp(r1, 0.0, smallest_edge)
	r2 = clamp(r2, 0.0, smallest_edge)

	var diff_1 := edge_1 - (r + r1)
	var diff_2 := edge_2 - (r + r2)
	var offset = min(diff_1, diff_2)
	if offset < 0.0:
		r += offset

	return r
