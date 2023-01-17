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
	create_input("up_axis", "Up Axis", DataType.VECTOR3)
	create_input("origin", "Origin", DataType.VECTOR3)

	opts = SlotOptions.new()
	opts.value = 0.0
	opts.min_value = 0.0
	opts.allow_lesser = false
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


# TODO: handle rounded corners
func _generate_outputs() -> void:
	var width: float = get_input_single("width", 1.0)
	var length: float = get_input_single("length", 1.0)
	var axis: Vector3 = get_input_single("up_axis", Vector3.UP)
	var origin: Vector3 = get_input_single("origin", Vector3.ZERO)
	var radius: Vector4 = get_input_single("corners_radius", Vector4.ZERO)
	var offset := Vector3(width / 2.0, length / 2.0, 0.0)

	var t = Transform3D()
	if axis != Vector3.ZERO:
		t = t.looking_at(axis.normalized(), Vector3(0, 0, 1))

	var curve = Curve3D.new()

	curve.add_point(t.xform(Vector3.ZERO - offset))
	curve.add_point(t.xform(Vector3(width, 0.0, 0.0) - offset))
	curve.add_point(t.xform(Vector3(width, length, 0.0) - offset))
	curve.add_point(t.xform(Vector3(0.0, length, 0.0) - offset))
	curve.add_point(t.xform(Vector3.ZERO - offset))

	var path = Path3D.new()
	path.curve = curve
	path.translation = origin

	set_output("rectangle", path)

