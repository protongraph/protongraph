tool
class_name ConceptGraphDataType

"""
Define the constants used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the COLORS dictionnary.
"""

# NEVER CHANGE THE TYPES ORDER or it will break save files
enum Types {
	ANY,
	BOOLEAN,
	SCALAR,
	STRING,
	MATERIAL,
	NOISE,
	HEIGHTMAP,
	CURVE_FUNC,
	NODE_2D,
	BOX_2D,
	MESH_2D,
	CURVE_2D,
	VECTOR_CURVE_2D,
	NODE_3D,
	BOX_3D,
	MESH_3D,
	CURVE_3D,
	VECTOR_CURVE_3D,
	VECTOR2,
	VECTOR3,
}


# Shorthand so we don't have to type ConceptGraphDataType.Types.ANY and skip the Types part
const ANY = Types.ANY
const BOOLEAN = Types.BOOLEAN
const SCALAR = Types.SCALAR
const STRING = Types.STRING
const MATERIAL = Types.MATERIAL
const NOISE = Types.NOISE
const HEIGHTMAP = Types.HEIGHTMAP
const CURVE_FUNC = Types.CURVE_FUNC

const NODE_2D = Types.NODE_2D
const BOX_2D = Types.BOX_2D
const MESH_2D = Types.MESH_2D
const CURVE_2D = Types.CURVE_2D
const VECTOR_CURVE_2D = Types.VECTOR_CURVE_2D

const NODE_3D = Types.NODE_3D
const BOX_3D = Types.BOX_3D
const MESH_3D = Types.MESH_3D
const CURVE_3D = Types.CURVE_3D
const VECTOR_CURVE_3D = Types.VECTOR_CURVE_3D

const VECTOR2 = Types.VECTOR2
const VECTOR3 = Types.VECTOR3




# Slot connections colors. Share the same color as common types also used in the VisualShader editor.
const COLORS = {
	ANY: Color.white,
	BOOLEAN: Color("8ca6f4"),
	SCALAR: Color("61d9f5"),
	STRING: Color.gold,
	MATERIAL: Color.darkmagenta,
	NOISE: Color("b48700"),
	HEIGHTMAP: Color("cc8f20"),
	CURVE_FUNC: Color.dodgerblue,

	NODE_2D: Color.crimson,
	BOX_2D: Color.mediumvioletred,
	MESH_2D: Color.chocolate,
	CURVE_2D: Color.forestgreen,
	VECTOR_CURVE_2D: Color.sandybrown,

	NODE_3D: Color.crimson,
	BOX_3D: Color.mediumvioletred,
	MESH_3D: Color.chocolate,
	CURVE_3D: Color.forestgreen,
	VECTOR_CURVE_3D: Color.sandybrown,

	VECTOR2: Color("7e3f97"),
	VECTOR3: Color("d67ded"),
}


"""
Convert graph node category name to color
"""
static func to_category_color(category: String) -> Color:
	var tokens := category.split("/")
	tokens.invert()
	var type = tokens[0]
	if type == "2D" or type == "3D":
		type = tokens[1]

	match type:
		"Boxes":
			return COLORS[BOX_3D]
		"Curves":
			return COLORS[CURVE_3D]
		"Vector Curves":
			return COLORS[VECTOR_CURVE_3D]
		"Debug":
			return Color.black
		"Heigthmaps":
			return COLORS[HEIGHTMAP].darkened(0.5)
		"Inputs":
			return Color.steelblue
		"Inspector":
			return Color.teal
		"Maths":
			return Color.steelblue
		"Meshes":
			return COLORS[MESH_3D]
		"Nodes":
			return Color.firebrick
		"Noises":
			return COLORS[NOISE]
		"Output":
			return Color.black
		"Transforms":
			return Color.maroon
		"Utilities":
			return Color("4371b5")
		"Vectors":
			return COLORS[VECTOR2]
		"Numbers":
			return COLORS[SCALAR].darkened(0.3)
		_:
			return Color.black


"""
Allows extra connections between different types
"""
static func setup_valid_connection_types(graph_edit: GraphEdit) -> void:
	graph_edit.add_valid_connection_type(NODE_3D, BOX_3D)
	graph_edit.add_valid_connection_type(NODE_3D, MESH_3D)
	graph_edit.add_valid_connection_type(NODE_3D, CURVE_3D)
	graph_edit.add_valid_connection_type(NODE_3D, VECTOR_CURVE_3D)

	graph_edit.add_valid_connection_type(NODE_2D, BOX_2D)
	graph_edit.add_valid_connection_type(NODE_2D, MESH_2D)
	graph_edit.add_valid_connection_type(NODE_2D, CURVE_2D)
	graph_edit.add_valid_connection_type(NODE_2D, VECTOR_CURVE_2D)

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
		VECTOR2:
			return TYPE_VECTOR2
		VECTOR3:
			return TYPE_VECTOR3
		STRING:
			return TYPE_STRING
		BOOLEAN:
			return TYPE_BOOL
		CURVE_FUNC:
			return TYPE_OBJECT
		MATERIAL:
			return TYPE_OBJECT
		BOX_2D:
			return TYPE_RECT2
		BOX_3D:
			return TYPE_AABB
	return TYPE_NIL
