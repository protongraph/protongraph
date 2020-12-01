class_name DataType


# Define the constants used when setting up the GraphNodes slots type. Each of 
# these values should have an associated color in the COLORS dictionnary.


# NEVER CHANGE THE TYPES ORDER or it will break save files
# TODO : Find a way to fix that because there's obsolete types in there
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
	BOX_2D,	# Obsolete
	MESH_2D, # Obsolete
	CURVE_2D, # Obsolete
	VECTOR_CURVE_2D, # Obsolete
	NODE_3D,
	BOX_3D, # Will become "MASK" later
	MESH_3D,
	CURVE_3D,
	VECTOR_CURVE_3D,
	VECTOR2,
	VECTOR3,
	TEXTURE_2D,
}


# Shorthand so we don't have to type DataType.Types.ANY and skip the Types part
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
const TEXTURE_2D = Types.TEXTURE_2D

const NODE_3D = Types.NODE_3D
const BOX_3D = Types.BOX_3D
const MESH_3D = Types.MESH_3D
const CURVE_3D = Types.CURVE_3D
const VECTOR_CURVE_3D = Types.VECTOR_CURVE_3D

const VECTOR2 = Types.VECTOR2
const VECTOR3 = Types.VECTOR3

# Colors are used for slots, connections between slots and frame color
const color_base_type = Color("3ac5e6")
const color_vector = Color("3ac5e6")

const COLORS = {
	ANY: Color.white,

	NODE_2D: Color("7c42ba"),
	TEXTURE_2D: Color("6b64c6"),
	CURVE_FUNC: Color("5d7fcf"),
	MATERIAL: Color("5197d7"),

	BOOLEAN: color_base_type,
	SCALAR: color_base_type,
	STRING: color_base_type,
	VECTOR2: color_vector,
	VECTOR3: color_vector,
	
	NOISE: Color("4ce0a0"),
	HEIGHTMAP: Color("fecf46"),
	
	NODE_3D: Color("e9001e"),
	CURVE_3D: Color("f6450d"),
	MESH_3D: Color("fb6f10"),
	BOX_3D: Color("fc9224"), # TODO rename to MASK
	VECTOR_CURVE_3D: Color("fdb136"),
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
			return COLORS[CURVE_3D].darkened(0.25)
		"Vector Curves":
			return COLORS[VECTOR_CURVE_3D].darkened(0.25)
		"Function Curves":
			return COLORS[CURVE_FUNC]
		"Debug":
			return Color.black
		"Heightmaps":
			return COLORS[HEIGHTMAP].darkened(0.3)
		"Inputs":
			return Color.steelblue
		"Inspector":
			return Color.teal
		"Maths":
			return COLORS[SCALAR].darkened(0.25)
		"Meshes":
			return COLORS[MESH_3D].darkened(0.2)
		"Nodes":
			return COLORS[NODE_3D].darkened(0.2)
		"Noises":
			return COLORS[NOISE].darkened(0.4)
		"Output":
			return Color.black
		"String":
			return COLORS[STRING].darkened(0.25)
		"Transforms":
			return Color.maroon
		"Utilities":
			return Color("4371b5")
		"Vectors":
			return COLORS[SCALAR].darkened(0.25)
		"Numbers":
			return COLORS[SCALAR].darkened(0.25)
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

	graph_edit.add_valid_connection_type(NODE_2D, NOISE)
	graph_edit.add_valid_connection_type(NODE_2D, HEIGHTMAP)
	graph_edit.add_valid_connection_type(NODE_2D, TEXTURE_2D)

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


static func get_type_name(type: int) -> String:
	var keys = Types.keys()
	if type in Types:
		return Types[type].capitalize()
	return ""
