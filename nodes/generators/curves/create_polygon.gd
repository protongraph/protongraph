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
	create_input("v_count", "Vertex count", DataType.NUMBER, opts)

	opts = SlotOptions.new()
	opts.value = 1.0
	create_input("radius", "Radius", DataType.NUMBER, opts)

	create_input("up_axis", "Up Axis", DataType.VECTOR3, SlotOptions.new(Vector3.UP))
	create_input("origin", "Origin", DataType.VECTOR3)

	create_output("polygon", "Polygon", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var count: int = get_input_single("v_count", 3)
	var radius: float = get_input_single("radius", 1.0)
	var axis: Vector3 = get_input_single("up_axis", Vector3.UP)
	var origin: Vector3 = get_input_single("origin", Vector3.ZERO)
	var angle_offset: float = (2 * PI) / count

	var t = Transform3D()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3.BACK)

	var curve = Curve3D.new()

	for i in range(count + 1):
		var v = Vector3.ZERO
		v.x = cos(angle_offset * i)
		v.y = sin(angle_offset * i)
		v *= radius
		curve.add_point(v * t)

	var path = Path3D.new()
	path.curve = curve
	path.position = origin

	set_output("polygon", path)

