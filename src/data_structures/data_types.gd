"""
Define the constants used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the COLORS dictionnary.
"""

class_name ConceptGraphDataType
extends Reference


const BOOLEAN = 0
const SCALAR = 1
const VECTOR = 2
const NODE = 3
const CURVE = 4
const NOISE = 5
const MATERIAL = 6
const MESH = 7
const STRING = 8
const BOX = 9
const POLYGON_CURVE = 10


# Common types also used in the VisualShader editor share the same color
const COLORS = {
	BOOLEAN: Color("8ca6f4"),
	SCALAR: Color("61d9f5"),
	VECTOR: Color("d67ded"),
	NODE: Color.crimson,
	CURVE: Color.yellowgreen,
	NOISE: Color.ivory,
	MATERIAL: Color.darkmagenta,
	MESH: Color.chocolate,
	STRING: Color.gold,
	BOX: Color.maroon,
	POLYGON_CURVE: Color.sandybrown,
}


"""
Allows extra connections between different types
"""
static func setup_valid_connection_types(graph_edit: GraphEdit) -> void:
	graph_edit.add_valid_connection_type(NODE, MESH)
	graph_edit.add_valid_connection_type(NODE, CURVE)


"""
Convert our custom defined data type to built in variant type. We make the separation as we don't
need all of the variant types, and some of them doesn't exists (like the MATERIAL data type).
"""
static func to_variant_type(type: int) -> int:
	match type:
		SCALAR:
			return TYPE_REAL
		VECTOR:
			return TYPE_VECTOR3
		STRING:
			return TYPE_STRING
		BOOLEAN:
			return TYPE_BOOL
	return TYPE_NIL
