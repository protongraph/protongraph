tool
class_name ConceptGraphEditorUtil


static func get_dpi_scale() -> float:
	return 1.0


"""
Returns the path to res://addons/concept_graph, no matter how the user renamed the addon folder
"""
static func get_plugin_root_path() -> String:
	var dummy = ConceptGraphNodePool.new()
	var path = dummy.get_script().get_path()
	dummy.queue_free()
	return path.replace("src/core/node_pool.gd", "")


"""
Returns a square texture or a given color. Used in GraphNodes that accept multiple connections
on the same slot.
"""
static func get_square_texture(color: Color) -> ImageTexture:
	var image = Image.new()
	image.create(10, 10, false, Image.FORMAT_RGBA8)
	image.fill(color)

	var imageTexture = ImageTexture.new()
	imageTexture.create_from_image(image)
	imageTexture.resource_name = "square " + String(color.to_rgba32())

	return imageTexture
