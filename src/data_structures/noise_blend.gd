tool
class_name ConceptGraphNoiseBlend
extends ConceptGraphNoise


var blend_noise: ConceptGraphNoise
var blend_amount: float = 0.5 setget set_blend_amount


func set_blend_amount(amount) -> void:
	blend_amount = clamp(amount, 0.0, 1.0)


func _init(_noise: ConceptGraphNoise, _blend_noise: ConceptGraphNoise, _blend_amount: float):
	noise = _noise
	blend_noise = _blend_noise
	set_blend_amount(_blend_amount)


func get_noise_2d(x:float, y:float) -> float:
	return _blend_noise(x, y)


func get_noise_2dv(v: Vector2) -> float:
	return _blend_noise(v.x, v.y)


func get_noise_3d(x: float, y: float, z: float) -> float:
	return _blend_noise(x, y, z)


func get_noise_3dv(v: Vector3) -> float:
	return _blend_noise(v.x, v.y, v.z)


func _blend_noise(x:float, y: float, z = null) -> float:
	var val1 = 0.0
	var val2 = 0.0

	if z == null:
		val1 = noise.get_noise_2d(x, y)
		val2 = blend_noise.get_noise_2d(x, y)
	else:
		val1 = noise.get_noise_3d(x, y, z)
		val2 = blend_noise.get_noise_3d(x, y, z)

	return lerp(val1, val2, blend_amount)
