class_name NoiseAdd
extends NoiseCombiner


func _combine_noise(x: float, y: float, z = null) -> float:
	if z == null:
		return clamp(noise_a.get_noise_2d(x, y) + noise_b.get_noise_2d(x, y), -1.0, 1.0)
	else:
		return clamp(noise_a.get_noise_3d(x, y, z) + noise_b.get_noise_3d(x, y, z), -1.0, 1.0)
