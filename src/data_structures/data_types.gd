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
const VECTOR_CURVE = 10
const ANY = 11
const MATH_CURVE = 12

# Workaround to get type name by it's ID for hint_tooltip on input and output
enum Types {
	BOOLEAN = 0
	SCALAR = 1
	VECTOR = 2
	NODE = 3
	CURVE = 4
	NOISE = 5
	MATERIAL = 6
	MESH = 7
	STRING = 8
	BOX = 9
	VECTOR_CURVE = 10
	ANY = 11
	MATH_CURVE = 12
}

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
	VECTOR_CURVE: Color.sandybrown,
	ANY: Color.white,
	MATH_CURVE: Color.dodgerblue,
}

"""
Convert graph node category name to color
"""
static func to_category_color(category: String) -> Color:
	match category:
		"Boxes":
			return COLORS[BOX]
		"Curves", "Curves/Inputs", "Curves/Operations", "Curves/Conversion", "Curves/Generators":
			return COLORS[CURVE]
		"Debug":
			return Color.palegreen
		"Inputs":
			return Color("8ca6f4")
		"Inspector properties":
			return Color.navyblue
		"Maths/Scalars":
			return COLORS[SCALAR]
		"Meshes":
			return COLORS[MESH]
		"Nodes/Generators", "Nodes/Operations", "Nodes/Instancers":
			return COLORS[NODE]
		"Noise":
			return Color.olive#COLORS[NOISE]
		"Output":
			return Color.black
		"Vectors":
			return COLORS[VECTOR]
		_:
			return Color.black


"""
Allows extra connections between different types
"""
static func setup_valid_connection_types(graph_edit: GraphEdit) -> void:
	graph_edit.add_valid_connection_type(NODE, MESH)
	graph_edit.add_valid_connection_type(NODE, CURVE)
	graph_edit.add_valid_connection_type(NODE, BOX)



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
		MATH_CURVE:
			return TYPE_OBJECT
		MATERIAL:
			return TYPE_OBJECT
	return TYPE_NIL
