tool
class_name ConceptGraphNoise_Simplex
extends ConceptGraphNoise

func _init():
	noise = OpenSimplexNoise.new()

# wrap noise functions in ._calc_noise()
func get_noise_2d(x:float, y:float) -> float:
	return ._calc_noise(noise.get_noise_2d(x, y), x, y)

func get_noise_2dv(v:Vector2) -> float:
	return ._calc_noise(noise.get_noise_2dv(v), v.x, v.y)

func get_noise_3d(x:float, y:float, z:float) -> float:
	return ._calc_noise(noise.get_noise_3d(x, y, z), x, y, z)

func get_noise_3dv(v:Vector3) -> float:
	return ._calc_noise(noise.get_noise_3dv(v), v.x, v.y, v.z)
