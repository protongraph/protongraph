extends NoiseCombiner
class_name NoiseOverlay


func _init(noise1: Noise = null, noise2: Noise = null):
	._init(noise1, noise2)


func _combine_noise(x: float, y: float, z = null) -> float:
	var a
	var b
	if z == null:
		a = noise.get_noise_2d(x, y)
		b = second_noise.get_noise_2d(x, y)
	else:
		a = noise.get_noise_3d(x, y, z)
		b = second_noise.get_noise_3d(x, y, z)
	
	if a < 0.5:
		return 2 * a * b
	return 1 - 2 * (1 - a) * (1 - b)
