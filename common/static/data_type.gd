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
