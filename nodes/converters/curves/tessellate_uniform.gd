tool
extends ProtonNode

"""
Tessellate a curve by sampling the curve at regular intervals. This creates an array of points of
uniform density, which means curviers areas will have the same resolution as straight parts of the
curve.
"""


func _init() -> void:
	unique_id = "curve_tesselate_regular"
	display_name = "Tesselate (Uniform)"
	category = "Converters/Curves"
	description = "Creates a vector curve with the same density along the curve"

	set_input(0, "Curve", DataType.CURVE_3D)
	set_input(1, "Resolution", DataType.SCALAR,
		{"min": 0.001, "allow_lesser": false, "value": 1.0})
	set_input(2, "Preserve sharp", DataType.BOOLEAN)
	set_output(0, "", DataType.POLYLINE_3D)


func _generate_outputs() -> void:
	var curves := get_input(0)
	if not curves or curves.size() == 0:
		return

	var resolution: float = get_input_single(1, 1.0)
	var preserve_sharp: bool = get_input_single(2, false)

	for c in curves:
		var curve = c.curve
		var p = Polyline.new()
		p.transform = c.transform

		var length = curve.get_baked_length()
		var steps = round(length / resolution)
		if steps == 0:
			continue

		var points := []
		for i in range(steps):
			var pos = curve.interpolate_baked((i / (steps - 1)) * length)
			points.push_back(pos)

		p.points = points
		p.transform = c.transform

		output[0].push_back(p)
