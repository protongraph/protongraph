class_name DataType
extends RefCounted


const ANY := 0
const BOOLEAN := 10
const NUMBER := 11
const STRING := 12
const VECTOR2 := 13
const VECTOR3 := 14
const VECTOR4 := 15

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

const MISC := 100
const MISC_CUSTOM_UI := 101
const MISC_PREVIEW_2D := 102


# Colors are used for slots, connections between slots and frame color
const color_base_type = Color("3ac5e6")
const color_vector = Color("3ac5e6")

const COLORS = {
	ANY: Color.WHITE,
	BOOLEAN: Color("2DE4FF"),
	NUMBER: Color("2EB7FF"),
	STRING: Color("2988FF"),
	VECTOR2: Color("7D2BFF"),
	VECTOR3: Color("BA24FF"),
	VECTOR4: Color("9615d1"),

	NODE_2D: Color("B6FF63"),
	TEXTURE_2D: Color("69EB63"),
	CURVE_FUNC: Color("6BFF9F"),
	MATERIAL: Color("6BFFD9"),
	NOISE: Color("4ce0a0"),

	NODE_3D: Color("e9001e"),
	CURVE_3D: Color("f6450d"),
	MESH_3D: Color("fb6f10"),
	MASK_3D: Color("fc9224"),
	POLYLINE_3D: Color("fdb136"),
	HEIGHTMAP: Color("fecf46"),

	MISC: Color.BLACK,
	}

const NAMES = {
	ANY: "Any",
	BOOLEAN: "Bool",
	NUMBER: "Number",
	STRING: "String",
	VECTOR2: "Vector2",
	VECTOR3: "Vector3",
	VECTOR4: "Vector4",

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
		"Curves":
			return COLORS[CURVE_3D].darkened(0.25)
		"Debug":
			return Color.BLACK
		"Function Curves":
			return COLORS[CURVE_FUNC]
		"Heightmaps":
			return COLORS[HEIGHTMAP].darkened(0.3)
		"Inputs":
			return Color.STEEL_BLUE
		"Masks":
			return COLORS[MASK_3D]
		"Maths":
			return COLORS[NUMBER].darkened(0.25)
		"Meshes":
			return COLORS[MESH_3D].darkened(0.2)
		"Nodes":
			return COLORS[NODE_3D].darkened(0.2)
		"Noises":
			return COLORS[NOISE].darkened(0.4)
		"Numbers":
			return COLORS[NUMBER].darkened(0.25)
		"Output":
			return Color.BLACK
		"Polylines":
			return COLORS[POLYLINE_3D].darkened(0.25)
		"Strings":
			return COLORS[STRING].darkened(0.25)
		"Transforms":
			return Color.MAROON
		"Utilities":
			return Color("4371b5")
		"Vectors":
			return COLORS[VECTOR2].darkened(0.25)
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
