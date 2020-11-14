extends Noise
class_name NoiseCombiner


var second_noise: Noise


func _init(noise1: Noise = null, noise2: Noise = null):
	noise = noise1
	second_noise = noise2


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
		return second_noise.get_noise_2d(x, y)

	else:
		return second_noise.get_noise_3d(x, y, z)
