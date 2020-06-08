tool
class_name ConceptGraphNoise
extends Object

var noise: Object
var curve: Curve
var blend_noise: ConceptGraphNoise
var blend_amount: float = 0.5 setget set_blend_amount

# Implement these functions when inheriting from this class
func _init():
	pass

# wrap calls to the noise class in ._calc_noise()
func get_noise_2d(x:float, y:float) -> float:
	return 0.0 #_calc_noise(value, x, y)

func get_noise_2dv(v: Vector2) -> float:
	return 0.0 #_calc_noise(value, v.x, v.y)

func get_noise_3d(x: float, y: float, z: float) -> float:
	return 0.0 #_calc_noise(value, x, y, z)

func get_noise_3dv(v: Vector3) -> float:
	return 0.0 #_calc_noise(value, v.x, v.y, v.z)


func set_blend_amount(amount) -> void:
	blend_amount = clamp(amount, 0.0, 1.0)


func blend(_noise: ConceptGraphNoise, _amount: float) -> ConceptGraphNoise:
	var res = get_script().new()
	res.noise = self
	res.curve = null
	res.blend_noise = _noise
	res.blend_amount = _amount
	return res


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


func _calc_noise(noise_value: float, x: float, y:float, z = null) -> float:

	if curve is Curve:
		noise_value = clamp(
			curve.interpolate_baked(noise_value * 0.5 + 0.5) * 2.0 - 1.0,
			-1.0, 1.0)
	
	if not blend_noise: 
		return noise_value
	
	var blend_value := 0.0
	if z == null:
		blend_value = blend_noise.get_noise_2d(x, y)
	else:
		blend_value = blend_noise.get_noise_3d(x, y, z)
	
	return lerp(noise_value, blend_value, blend_amount)
