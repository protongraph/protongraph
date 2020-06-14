tool
extends ConceptNode

"""
Tessellate a curve using the path controls points only.
This does not preserve the in / out positions of each controls.
"""


func _init() -> void:
	unique_id = "curve_tesselate_exact_2d"
	display_name = "Tesselate (Exact) 2D"
	category = "Converters/Curves/2D"
	description = "Creates a vector curve from the curve control points only"

	set_input(0, "Curve", ConceptGraphDataType.CURVE_2D)
	set_output(0, "", ConceptGraphDataType.VECTOR_CURVE_2D)


func _generate_outputs() -> void:
	var curves := get_input(0)
	if not curves or curves.size() == 0:
		return

	for c in curves:	# c is a Path object here
		var p = ConceptNodeVectorCurve2D.new()
		var points = []
		var curve: Curve2D = c.curve

		for i in range(curve.get_point_count()):
			points.append(curve.get_point_position(i))

		p.points = points
		p.transform = c.transform
		output[0].append(p)
