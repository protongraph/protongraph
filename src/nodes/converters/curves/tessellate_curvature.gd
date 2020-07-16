tool
extends ConceptNode

"""
Tessellate a curve using the built in tessellate function on the curve3D. Creates an array of points
controlled by the curvature. Straight lines will have less points and curved parts will be denser.
"""


func _init() -> void:
	unique_id = "curve_tesselate_curvature"
	display_name = "Tesselate (Curvature)"
	category = "Converters/Curves"
	description = "Creates a vector curve with a curvature controlled point density"

	set_input(0, "Curve", ConceptGraphDataType.CURVE_3D)
	set_input(1, "Max stages", ConceptGraphDataType.SCALAR, {"step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Tolerance", ConceptGraphDataType.SCALAR,
		{"min": 0, "max": 360, "allow_lesser": false, "allow_higher": false, "value": 4})
	set_output(0, "", ConceptGraphDataType.VECTOR_CURVE_3D)


func _generate_outputs() -> void:
	var paths = get_input(0)
	if not paths or paths.size() == 0:
		return

	var stages: int = get_input_single(1, 1)
	var tolerance: float = get_input_single(2, 4.0)

	for path in paths:
		var p = ConceptNodeVectorCurve.new()
		p.points = path.curve.tessellate(stages, tolerance)
		p.transform = path.transform
		output[0].append(p)


