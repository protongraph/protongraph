tool
extends ProtonNode

"""
Take a point curve in input and creates a Path node from it
"""

func _init() -> void:
	unique_id = "convert_points_to_curve"
	display_name = "To Curve"
	category = "Converters/Vector Curves"
	description = "Takes a point curve in input and creates a Path node from it"

	set_input(0, "Vector curve", DataType.VECTOR_CURVE_3D)
	set_output(0, "", DataType.CURVE_3D)


func _generate_outputs() -> void:
	var vcs := get_input(0)
	if not vcs or vcs.size() == 0:
		return

	for vc in vcs:
		var path = Path.new()
		path.curve = Curve3D.new()

		for p in vc.points:
			path.curve.add_point(p)

		path.transform = vc.transform
		output[0].push_back(path)
