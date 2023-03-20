class_name ProtonNoise
extends RefCounted


var curve: Curve


func get_noise_2d(_x: float, _y: float) -> float:
	return 0.0


func get_noise_2dv(_v: Vector2) -> float:
	return 0.0


func get_noise_3d(_x: float, _y: float, _z: float) -> float:
	return 0.0


func get_noise_3dv(_v: Vector3) -> float:
	return 0.0


func get_image(width: int, height: int, scale = 1.0, offset = Vector2()) -> Image:
	var bytes = PackedByteArray()
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
			bytes[i + 1] = color.g8
			bytes[i + 2] = color.b8
			i += 3

	return Image.create_from_data(width, height, false, Image.FORMAT_RGB8, bytes)


func apply_curve(noise_value: float) -> float:
	if not curve is Curve:
		return noise_value

	return clamp(
		curve.sample_baked(noise_value * 0.5 + 0.5) * 2.0 - 1.0,
		-1.0,
		1.0
	)
