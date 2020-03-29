tool
extends ConceptNode

"""
DEBUG NODE : Show all input colors at once
"""


func _init() -> void:
	node_title = "Palette"
	category = "Debug"
	description = "Show all input colors at once"

	set_input(0, "Bool", ConceptGraphDataType.BOOLEAN)
	set_input(1, "Scalar", ConceptGraphDataType.SCALAR)
	set_input(2, "Vector", ConceptGraphDataType.VECTOR)
	set_input(3, "Node", ConceptGraphDataType.NODE)
	set_input(4, "Curve", ConceptGraphDataType.CURVE)
	set_input(5, "Noise", ConceptGraphDataType.NOISE)
	set_input(6, "Material", ConceptGraphDataType.MATERIAL)
	set_input(7, "Mesh", ConceptGraphDataType.MESH)
	set_input(8, "String", ConceptGraphDataType.STRING)
	set_input(9, "Box", ConceptGraphDataType.BOX)
	set_input(10, "PolyCurve", ConceptGraphDataType.POLYGON_CURVE)

