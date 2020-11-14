extends NoiseCombiner
class_name NoiseAdd


func _init(noise1: Noise = null, noise2: Noise = null):
	._init(noise1, noise2)


func _combine_noise(x: float, y: float, z = null) -> float:
	if z == null:
		return clamp(noise.get_noise_2d(x, y) + second_noise.get_noise_2d(x, y), -1.0, 1.0)
	else:
		return clamp(noise.get_noise_3d(x, y, z) + second_noise.get_noise_3d(x, y, z), -1.0, 1.0)
