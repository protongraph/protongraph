extends NoiseCombiner
class_name NoiseBlend


var blend_amount: float = 0.5 setget set_blend_amount


func set_blend_amount(amount) -> void:
	blend_amount = clamp(amount, 0.0, 1.0)


func _init(noise1: Noise = null, noise2: Noise = null, amount := 0.0):
	._init(noise1, noise2)
	set_blend_amount(amount)


func _combine_noise(x: float, y: float, z = null) -> float:
	var val1 = 0.0
	var val2 = 0.0

	if z == null:
		val1 = noise.get_noise_2d(x, y)
		val2 = second_noise.get_noise_2d(x, y)
	else:
		val1 = noise.get_noise_3d(x, y, z)
		val2 = second_noise.get_noise_3d(x, y, z)

	return lerp(val1, val2, blend_amount)
