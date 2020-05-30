"""
Define the constants used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the COLORS dictionnary.
"""

class_name ConceptGraphDataType
extends Reference


enum Types {
	ANY,
	BOOLEAN,
	SCALAR,
	STRING,
	MATERIAL,
	NOISE,
	HEIGHTMAP,

	NODE_2D,
	CURVE_2D,

	NODE_3D,
	MESH,
	BOX,
	CURVE_3D,
	VECTOR_CURVE,

	VECTOR2,
	VECTOR3,
	VECTOR4,
}

# Shorthand so we don't have to type ConceptGraphDataType.Types.ANY and skip the Types part
const ANY = Types.ANY
const BOOLEAN = Types.BOOLEAN
const SCALAR = Types.SCALAR
const STRING = Types.STRING
const MATERIAL = Types.MATERIAL
const NOISE = Types.NOISE
const HEIGHTMAP = Types.HEIGHTMAP

const NODE_2D = Types.NODE_2D
const CURVE_2D = Types.CURVE_2D

const NODE_3D = Types.NODE_3D
const MESH = Types.MESH
const BOX = Types.BOX
const CURVE_3D = Types.CURVE_3D
const VECTOR_CURVE = Types.VECTOR_CURVE

const VECTOR2 = Types.VECTOR2
const VECTOR3 = Types.VECTOR3
const VECTOR4 = Types.VECTOR4


# Slot connections colors. Share the same color as common types also used in the VisualShader editor.
const COLORS = {
	ANY: Color.white,
	BOOLEAN: Color("8ca6f4"),
	SCALAR: Color("61d9f5"),
	STRING: Color.gold,
	MATERIAL: Color.darkmagenta,
	NOISE: Color("b48700"),
	HEIGHTMAP: Color("cc8f20"),

	NODE_2D: Color.dodgerblue,
	CURVE_2D: Color.dodgerblue,

	NODE_3D: Color.crimson,
	MESH: Color.chocolate,
	BOX: Color.mediumvioletred,
	CURVE_3D: Color.forestgreen,
	VECTOR_CURVE: Color.sandybrown,

	VECTOR2: Color("7e3f97"),
	VECTOR3: Color("d67ded"),
	VECTOR4: Color("ebadf6"),
}


"""
Convert graph node category name to color
"""
static func to_category_color(category: String) -> Color:
	match category:
		"Boxes":
			return COLORS[BOX]
		"Curves", "Curves/Inputs", "Curves/Operations", "Curves/Conversion", "Curves/Generators":
			return COLORS[CURVE_3D]
		"Debug":
			return Color.black
		"Inputs":
			return Color.steelblue
		"Inspector properties":
			return Color.teal
		"Maths":
			return Color.steelblue
		"Meshes":
			return COLORS[MESH]
		"Nodes/Generators", "Nodes/Operations", "Nodes/Instancers":
			return Color.firebrick
		"Noise":
			return COLORS[NOISE]
		"Output":
			return Color.black
		"Vectors":
			return COLORS[VECTOR2]
		"Transforms":
			return Color.maroon
		"Heigthmaps":
			return COLORS[HEIGHTMAP].darkened(0.5)
		_:
			return Color.black


"""
Allows extra connections between different types
"""
static func setup_valid_connection_types(graph_edit: GraphEdit) -> void:
	graph_edit.add_valid_connection_type(NODE_3D, MESH)
	graph_edit.add_valid_connection_type(NODE_3D, BOX)
	graph_edit.add_valid_connection_type(NODE_3D, CURVE_3D)
	graph_edit.add_valid_connection_type(NODE_3D, VECTOR_CURVE)

	# Allow everything to connect to ANY
	for type in Types.values():
		graph_edit.add_valid_connection_type(ANY, type)


"""
Convert our custom defined data type to built in variant type. We make the separation as we don't
need all of the variant types, and some of them doesn't exists (like the MATERIAL data type).
"""
static func to_variant_type(type: int) -> int:
	match type:
		SCALAR:
			return TYPE_REAL
		VECTOR3:
			return TYPE_VECTOR3
		STRING:
			return TYPE_STRING
		BOOLEAN:
			return TYPE_BOOL
		CURVE_2D:
			return TYPE_OBJECT
		MATERIAL:
			return TYPE_OBJECT
	return TYPE_NIL
