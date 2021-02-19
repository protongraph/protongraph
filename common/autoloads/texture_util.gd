extends Node


var _cache := {}
var _table := {
	DataType.ANY: "icon_any.svg",
	DataType.BOOLEAN: "icon_bool.svg",
	DataType.MASK_3D: "icon_selector_box.svg",
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
	DataType.POLYLINE_3D: "icon_vector_curve.svg",
}

var _empty_texture: ImageTexture
var _square_textures := {}


func get_slot_icon(type: int) -> Texture:
	var path = "res://ui/icons/icon_graph.svg" # Default icon
	var root = "res://ui/icons/data_types/"

	if _table.has(type):
		path = root + _table[type]

	return get_texture(path)


func get_texture(path) -> Texture:
	if _cache.has(path):
		return _cache[path]

	var texture = load(path)
	if not texture is Texture:
		print(path, " is not a texture")
		return null

	var scale = EditorUtil.get_editor_scale() / 4.0
	if scale != 1.0:
		var image: Image = texture.get_data()
		image.resize(int(texture.get_width() * scale), int(texture.get_height() * scale))
		texture = ImageTexture.new()
		texture.create_from_image(image)

	_cache[path] = texture
	return texture


# Returns a square texture or a given color. Used in the 'Add node panel' to
# display a colored square next to each node based on their category.
func get_square_texture(color: Color) -> ImageTexture:
	if _square_textures.has(color):
		return _square_textures[color]

	var d = 10 * EditorUtil.get_editor_scale()
	var image = Image.new()
	image.create(d, d, false, Image.FORMAT_RGBA8)
	image.fill(color)

	var image_texture = ImageTexture.new()
	image_texture.create_from_image(image)
	image_texture.resource_name = "square " + String(color.to_rgba32())
	_square_textures[color] = image_texture

	return image_texture


func get_input_texture(multi) -> Texture:
	if multi:
		return get_texture("res://ui/icons/input_slot_multi.svg")

	return get_texture("res://ui/icons/input_slot.svg")


func get_output_texture() -> Texture:
	return get_texture("res://ui/icons/output_slot.svg")


# Returns a 0x0 texture. Used by the ProtonNode class to hide the slots.
func get_empty_texture() -> ImageTexture:
	if not _empty_texture:
		var image = Image.new()
		image.create(0, 0, false, Image.FORMAT_RGBA8)

		_empty_texture = ImageTexture.new()
		_empty_texture.create_from_image(image)
		_empty_texture.resource_name = "cg_empty_texture"

	return _empty_texture
