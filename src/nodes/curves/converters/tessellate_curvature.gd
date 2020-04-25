tool
extends ConceptNode

"""
Tessellate a curve using the built in tessellate function on the curve3D. Creates an array of points
controlled by the curvature. Straight lines will have less points and curved parts will be denser.
"""


func _init() -> void:
	unique_id = "curve_tesselate_curvature"
	display_name = "Tesselate curve (Curvature)"
	category = "Curves/Conversion"
	description = "Creates a vector curve with a curvature controlled point density"

	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_input(1, "Max stages", ConceptGraphDataType.SCALAR, {"step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Tolerance", ConceptGraphDataType.SCALAR,
		{"min": 0, "max": 360, "allow_lesser": false, "allow_higher": false, "value": 4})
	set_output(0, "", ConceptGraphDataType.VECTOR_CURVE)


func get_output(idx: int) -> Array:
	var res = []
	var curves = get_input(0)
	if not curves:
		return res

	if not curves is Array:
		curves = [curves]
	elif curves.size() == 0:
		return res

	var stages = get_input(1, 1)
	var tolerance = get_input(2, 4)

	for c in curves:	# c is a Path object here
		var p = ConceptNodeVectorCurve.new()
		p.transform = c.transform
		p.points = c.curve.tessellate(stages, tolerance)
		res.append(p)

	return res

