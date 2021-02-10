extends Object
class_name Heightmap


var size := Vector2(64, 64)
var mesh_size := Vector2(64, 64)
var height_scale := 0.0
var height_offset := 0.0
var data: Array
var transform: Transform


func init(_size: Vector2, _mesh_size: Vector2, _height_scale: float, _height_offset: float) -> void:
	size = _size# + Vector2(1, 1)
	mesh_size = _mesh_size + Vector2(1, 1)
	height_scale = _height_scale
	height_offset = _height_offset
	data = Array()
	data.resize(size.x * size.y)
	transform = Transform()


func duplicate(_opts):
	# Don't use Heightmap.new() here because it causes a cyclic dependency
	var res = get_script().new()
	res.size = size
	res.data = data.duplicate()
	res.transform = Transform(transform)
	res.mesh_size = mesh_size
	res.height_scale = height_scale
	res.height_offset = height_offset
	return res


func get_point_global(x: int, y: int, ignore_y_axis: bool = false) -> Vector3:
	var pos = Vector3.ZERO
	var ratio_x = (mesh_size.x - 1) / (size.x - 1)
	var ratio_y = (mesh_size.y - 1) / (size.y - 1)

	pos.x = x * ratio_x
	pos.z = y * ratio_y

	pos.y = 0.0
	if not ignore_y_axis:
		pos.y = data[y * size.y + x] * height_scale + height_offset

	pos += transform.origin

	return pos


func get_point(x: int, y: int) -> float:
	return data[y * size.y + x]


func get_point_transformed(x: int, y: int) -> float:
	return data[y * size.y + x] * height_scale + height_offset


func set_point(x: int, y: int, height: float) -> void:
	data[y * size.y + x] = height


func set_point_transformed(x: int, y: int, height: float) -> void:
	data[y * size.y + x] = (height - height_offset) / height_scale


func get_index(i: int) -> float:
	return data[i]


func set_index(i: int, height: float) -> void:
	data[i] = height


func get_image() -> Image:
	var bytes = PoolByteArray()
	bytes.resize(size.x * size.y * 3)

	var color
	var val = 0
	var i = 0

	for y in size.y:
		for x in size.x:
			val = get_point(x, y)
			color = Color(val, val, val)
			bytes[i] = color.r8
			bytes[i + 1] = color.g8
			bytes[i + 2] = color.b8
			i += 3

	var img = Image.new()
	img.create_from_data(size.x, size.y, false, Image.FORMAT_RGB8, bytes)

	return img


func set_from_image(image: Image) -> void:
	image.lock()
	for y in size.y:
		for x in size.x:
			set_point(x, y, image.get_pixel(x, y).r)

	image.unlock()
	

func get_texture() -> ImageTexture:
	var texture = ImageTexture.new()
	texture.create_from_image(get_image())
	return texture
