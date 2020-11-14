extends Noise
class_name NoiseSimplex


func _init():
	noise = OpenSimplexNoise.new()


func get_noise_2d(x:float, y:float) -> float:
	return _apply_curve(noise.get_noise_2d(x, y))


func get_noise_2dv(v:Vector2) -> float:
	return _apply_curve(noise.get_noise_2dv(v))


func get_noise_3d(x:float, y:float, z:float) -> float:
	return _apply_curve(noise.get_noise_3d(x, y, z))


func get_noise_3dv(v:Vector3) -> float:
	return _apply_curve(noise.get_noise_3dv(v))
