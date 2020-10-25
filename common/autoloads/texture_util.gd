extends Node


var cache := {}
var table := {
	DataType.ANY: "icon_any.svg",
	DataType.BOOLEAN: "icon_bool.svg",
	DataType.BOX_3D: "icon_selector_box.svg",
	DataType.CURVE_2D: "icon_bezier.svg",
	DataType.CURVE_3D: "icon_bezier.svg",
	DataType.CURVE_FUNC: "icon_func_curve.svg",
	DataType.HEIGHTMAP: "icon_heightmap.svg",
	DataType.MATERIAL: "icon_material.svg",
	DataType.MESH_3D: "icon_mesh.svg",
	DataType.NODE_2D: "icon_node_2d.svg",
	DataType.NODE_3D: "icon_node_3d.svg",
	DataType.NOISE: "icon_noise.svg",
	DataType.SCALAR: "icon_float.svg",
	DataType.STRING: "icon_string.svg",
	DataType.TEXTURE_2D: "icon_texture.svg",
	DataType.VECTOR2: "icon_vector2.svg",
	DataType.VECTOR3: "icon_vector3.svg",
	DataType.VECTOR_CURVE_3D: "icon_vector_curve.svg",
}

"""

"""

var empty_texture: ImageTexture


func get_slot_icon(type: int, multi := false) -> Texture:
	var path = "res://ui/icons/icon_graph.svg" # Default icon
	var root = "res://ui/icons/data_types/"

	if table.has(type):
		path = root + table[type]
	
	return get_texture(path)


func get_texture(path) -> Texture:
	if cache.has(path):
		return cache[path]
	
	var texture = load(path)
	if not texture is Texture:
		print(path, " is not a texture")
		return null
	
	var scale = EditorUtil.get_editor_scale() / 4.0
	if scale != 1.0:
		var image: Image = texture.get_data()
		image.resize(round(texture.get_width() * scale), round(texture.get_height() * scale))
		texture = ImageTexture.new()
		texture.create_from_image(image)
		
	cache[path] = texture
	return texture


"""
Returns a square texture or a given color. Used in GraphNodes that accept multiple connections
on the same slot.
"""
static func get_square_texture(color: Color) -> ImageTexture:
	var image = Image.new()
	image.create(0, 10, false, Image.FORMAT_RGBA8)
	image.fill(color)

	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image)
	imageTexture.resource_name = "square " + String(color.to_rgba32())

	return imageTexture


func get_input_texture(multi) -> Texture:
	if multi:
		return get_texture("res://ui/icons/input_slot_multi.svg")
	
	return get_texture("res://ui/icons/input_slot.svg")


func get_output_texture() -> Texture:
	return get_texture("res://ui/icons/output_slot.svg")


"""
Returns a 0x0 texture. Used by the ConceptNode class to hide the slots.
"""
func get_empty_texture() -> ImageTexture:
	if not empty_texture:
		var image = Image.new()
		image.create(0, 0, false, Image.FORMAT_RGBA8)
		
		empty_texture = ImageTexture.new()
		empty_texture.create_from_image(image)
		empty_texture.resource_name = "cg_empty_texture"
	
	return empty_texture
