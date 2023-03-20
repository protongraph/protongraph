class_name NoiseBlend
extends NoiseCombiner


var blend_amount: float = 0.5:
	set(val):
		blend_amount = clamp(val, 0.0, 1.0)


func _init(noise1: ProtonNoise = null, noise2: ProtonNoise = null, amount := 0.0):
	super(noise1, noise2)
	blend_amount = amount


func _combine_noise(x: float, y: float, z = null) -> float:
	var val1 = 0.0
	var val2 = 0.0

	if z == null:
		val1 = noise_a.get_noise_2d(x, y)
		val2 = noise_b.get_noise_2d(x, y)
	else:
		val1 = noise_a.get_noise_3d(x, y, z)
		val2 = noise_b.get_noise_3d(x, y, z)

	return lerp(val1, val2, blend_amount)
