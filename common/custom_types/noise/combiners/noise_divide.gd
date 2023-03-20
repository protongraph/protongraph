class_name NoiseDivide
extends NoiseCombiner


func _combine_noise(x: float, y: float, z = null) -> float:
	if z == null:
		return clamp(noise_a.get_noise_2d(x, y) / max(0.001, noise_a.get_noise_2d(x, y)), -1.0, 1.0)
	else:
		return clamp(noise_a.get_noise_3d(x, y, z) / max(0.001, noise_b.get_noise_3d(x, y, z)), -1.0, 1.0)
