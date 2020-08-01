tool
class_name ConceptGraphNoise
extends Object


var noise: Object
var curve: Curve


func _init():
	pass #noise = noise_object_to_wrap


# wrap return values in ._apply_curve()
func get_noise_2d(x: float, y: float) -> float:
	return 0.0 #._apply_curve(value)


func get_noise_2dv(v: Vector2) -> float:
	return 0.0 #._apply_curve(value)


func get_noise_3d(x: float, y: float, z: float) -> float:
	return 0.0 #._apply_curve(value)


func get_noise_3dv(v: Vector3) -> float:
	return 0.0 #._apply_curve(value)


func get_image(width: int, height: int, scale = 1.0, offset = Vector2()) -> Image:
	var bytes = PoolByteArray()
	bytes.resize(width * height * 3)

	var color
	var val = 0
	var i = 0

	for y in height:
		for x in width:
			val = get_noise_2d(
				offset.x + (x * scale),
				offset.y + (y * scale)
			) * 0.5 + 0.5
			color = Color(val, val, val)
			bytes[i]   = color.r8
			bytes[i+1] = color.g8
			bytes[i+2] = color.b8
			i += 3

	var img = Image.new()
	img.create_from_data(width, height, false, Image.FORMAT_RGB8, bytes)

	return img


func _apply_curve(noise_value: float) -> float:
	if not curve is Curve:
		return noise_value

	return clamp(
		curve.interpolate_baked(noise_value * 0.5 + 0.5) * 2.0 - 1.0,
		-1.0, 1.0)
