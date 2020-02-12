"""
Define the constants used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the COLORS dictionnary.
"""

class_name ConceptGraphDataType
extends Node


const BOOLEAN = 0
const SCALAR = 1
const VECTOR = 2
const NODE = 3
const CURVE = 4
const NOISE = 5
const MATERIAL = 6
const MESH = 7


# Common types also used in the VisualShader editor share the same color
const COLORS = {
	BOOLEAN: Color("8ca6f4"),
	SCALAR: Color("61d9f5"),
	VECTOR: Color("d67ded"),
	NODE: Color.crimson,
	CURVE: Color.yellowgreen,
	NOISE: Color.darkcyan,
	MATERIAL: Color.darkmagenta,
	MESH: Color.chocolate
}


static func setup_valid_connection_types(node: GraphEdit) -> void:
	# TODO : Not sure if the doc is wrong or if it's a bug, but the type order is actually reversed
	node.add_valid_connection_type(NODE, MESH)
