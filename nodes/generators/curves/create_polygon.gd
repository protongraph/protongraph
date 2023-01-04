extends ProtonNode


func _init() -> void:
	type_id = "curve_generator_polygon"
	title = "Create Polygon"
	category = "Generators/Curves"
	description = "Creates a curve made of n points at regular radial interval."

	var opts := SlotOptions.new()
	opts.step = 1
	opts.value = 6
	opts.min_value = 3
	opts.allow_lesser = false
	create_input(0, "Vertex count", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 1.0
	create_input(1, "Radius", DataType.NUMBER, opts)

	create_input(2, "Up Axis", DataType.VECTOR3)
	create_input(3, "Origin", DataType.VECTOR3)

	create_output(0, "", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var count: int = get_input_single(0, 3)
	var radius: float = get_input_single(1, 1.0)
	var axis: Vector3 = get_input_single(2, Vector3.UP)
	var origin: Vector3 = get_input_single(3, Vector3.ZERO)
	var angle_offset: float = (2 * PI) / count

	var t = Transform3D()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3(0, 0, 1))

	var curve = Curve3D.new()

	for i in range(count + 1):
		var v = Vector3.ZERO
		v.x = cos(angle_offset * i)
		v.y = sin(angle_offset * i)
		v *= radius
		curve.add_point(t.xform(v))

	var path = Path3D.new()
	path.curve = curve
	path.translation = origin

	set_output(0, path)

