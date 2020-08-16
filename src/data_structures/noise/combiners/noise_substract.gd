extends ConceptGraphNoiseCombiner
class_name ConceptGraphNoiseSubstract


func _init(noise1: ConceptGraphNoise = null, noise2: ConceptGraphNoise = null):
	._init(noise1, noise2)


func _combine_noise(x: float, y: float, z = null) -> float:
	if z == null:
		return noise.get_noise_2d(x, y) - second_noise.get_noise_2d(x, y)
	else:
		return noise.get_noise_3d(x, y, z) - second_noise.get_noise_3d(x, y, z)
