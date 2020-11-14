extends NoiseCombiner
class_name NoiseDivide


func _init(noise1: Noise = null, noise2: Noise = null):
	._init(noise1, noise2)


func _combine_noise(x: float, y: float, z = null) -> float:
	if z == null:
		return clamp(noise.get_noise_2d(x, y) / max(0.001, second_noise.get_noise_2d(x, y)), -1.0, 1.0)
	else:
		return clamp(noise.get_noise_3d(x, y, z) / max(0.001, second_noise.get_noise_3d(x, y, z)), -1.0, 1.0)
