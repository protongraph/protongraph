class_name DataType
extends RefCounted


const ANY := 0
const BOOLEAN := 10
const NUMBER := 11
const STRING := 12
const VECTOR2 := 13
const VECTOR3 := 14

const NODE_2D := 20
const TEXTURE_2D := 21
const CURVE_FUNC := 22
const MATERIAL := 23

const NODE_3D := 30
const MASK_3D := 31
const MESH_3D := 32
const CURVE_3D := 33
const POLYLINE_3D := 34

const NOISE := 40
const HEIGHTMAP := 41

# Colors are used for slots, connections between slots and frame color
const color_base_type = Color("3ac5e6")
const color_vector = Color("3ac5e6")

const COLORS = {
	ANY: Color.WHITE,
	BOOLEAN: color_base_type,
	NUMBER: color_base_type,
	STRING: color_base_type,
	VECTOR2: color_vector,
	VECTOR3: color_vector,
	
	NODE_2D: Color("7c42ba"),
	TEXTURE_2D: Color("6b64c6"),
	CURVE_FUNC: Color("5d7fcf"),
	MATERIAL: Color("5197d7"),

	NODE_3D: Color("e9001e"),
	CURVE_3D: Color("f6450d"),
	MESH_3D: Color("fb6f10"),
	MASK_3D: Color("fc9224"),
	POLYLINE_3D: Color("fdb136"),
	
	NOISE: Color("4ce0a0"),
	HEIGHTMAP: Color("fecf46"),
}

const NAMES = {
	ANY: "Any",
	BOOLEAN: "Bool",
	NUMBER: "Number",
	STRING: "String",
	VECTOR2: "Vector2",
	VECTOR3: "Vector3",
	
	NODE_2D: "Node2D",
	TEXTURE_2D: "Texture",
	CURVE_FUNC: "Curve",
	MATERIAL: "Material",

	NODE_3D: "Node3D",
	CURVE_3D: "Curve3D",
	MESH_3D: "Mesh",
	MASK_3D: "Mask",
	POLYLINE_3D: "Polyline",
	
	NOISE: "Noise",
	HEIGHTMAP: "Heightmap",
}

# Convert graph node category name to color
static func get_category_color(category: String) -> Color:
	var tokens := category.split("/")
	tokens.reverse()
	var type = tokens[0]
	if type == "2D" or type == "3D":
		type = tokens[1]

	match type:
		"Masks":
			return COLORS[MASK_3D]
		"Curves":
			return COLORS[CURVE_3D].darkened(0.25)
		"Vector Curves":
			return COLORS[POLYLINE_3D].darkened(0.25)
		"Function Curves":
			return COLORS[CURVE_FUNC]
		"Debug":
			return Color.BLACK
		"Heightmaps":
			return COLORS[HEIGHTMAP].darkened(0.3)
		"Inputs":
			return Color.STEEL_BLUE
		"Inspector":
			return Color.TEAL
		"Maths":
			return COLORS[NUMBER].darkened(0.25)
		"Meshes":
			return COLORS[MESH_3D].darkened(0.2)
		"Nodes":
			return COLORS[NODE_3D].darkened(0.2)
		"Noises":
			return COLORS[NOISE].darkened(0.4)
		"Output":
			return Color.BLACK
		"String":
			return COLORS[STRING].darkened(0.25)
		"Transforms":
			return Color.MAROON
		"Utilities":
			return Color("4371b5")
		"Vectors":
			return COLORS[NUMBER].darkened(0.25)
		"Numbers":
			return COLORS[NUMBER].darkened(0.25)
		_:
			return Color.BLACK


static func get_type_name(type: int):
	if type in NAMES:
		return NAMES[type]
	return ""


# Returns a dictionnary of compatible types
# Key: Destination, Values: Sources
static func get_valid_connections() -> Dictionary:
	var connections := {}
	connections[NODE_3D] = [MASK_3D, MESH_3D, CURVE_3D, POLYLINE_3D]
	connections[NODE_2D] = [NOISE, HEIGHTMAP, TEXTURE_2D]
	connections[ANY] = NAMES.keys()
	return connections
