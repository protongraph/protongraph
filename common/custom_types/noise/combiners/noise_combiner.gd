class_name NoiseCombiner
extends ProtonNoise


var noise_a: ProtonNoise
var noise_b: ProtonNoise


func _init(n1: ProtonNoise = null, n2: ProtonNoise = null):
	noise_a = n1
	noise_b = n2


func get_noise_2d(x:float, y:float) -> float:
	return _combine_noise(x, y)


func get_noise_2dv(v: Vector2) -> float:
	return _combine_noise(v.x, v.y)


func get_noise_3d(x: float, y: float, z: float) -> float:
	return _combine_noise(x, y, z)


func get_noise_3dv(v: Vector3) -> float:
	return _combine_noise(v.x, v.y, v.z)


func _combine_noise(x:float, y: float, z = null) -> float:
	if z == null:
		return noise_b.get_noise_2d(x, y)

	else:
		return noise_b.get_noise_3d(x, y, z)
