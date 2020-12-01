extends ProtonNode


const moore_range := [-1, 0, 1, -1, 1, -1, 0, 1]
const neumann_range := [-1, 1, -1, 1]

var _heightmap: Heightmap
var _threshold: float = 0.0


func _init() -> void:
	unique_id = "heightmap_thermal_erosion"
	display_name = "Thermal Erosion"
	category = "Modifiers/Heightmaps"
	description = "Erode the heightmap by simulating matter deposit based on slopes"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Iterations", DataType.SCALAR, {"step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Slope Angle", DataType.SCALAR)
	
	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var start_time = OS.get_ticks_msec()

	_heightmap = get_input_single(0)
	if not _heightmap:
		return
	
	# Node parameters
	var iterations: int = get_input_single(1, 1)
	_threshold = deg2rad(get_input_single(2, 0.0))

	for i in iterations:
		_erosion_step()

	output[0].push_back(_heightmap)

	var gen_time = OS.get_ticks_msec() - start_time
	print("Erosion: " + str(gen_time) + "ms")


func _erosion_step():
	var cell_size = _heightmap.mesh_size / _heightmap.size
	for x in _heightmap.size.x:
		for y in _heightmap.size.y:
			var h = _heightmap.get_point_transformed(x, y)
			var data = _get_max_slope_and_diff(x, y)
			var slope_dir: Vector2 = data[0]
			var diff: float = data[1]
			if slope_dir == Vector2.ZERO:
				continue
			var slope = atan(diff / cell_size.x)
			if slope >= _threshold:
				var amount = diff * 0.25
				var new_height = h - amount
				_heightmap.set_point_transformed(x, y, new_height)
				new_height = _heightmap.get_point_transformed(x + slope_dir.x, y + slope_dir.y) + amount
				_heightmap.set_point_transformed(x + slope_dir.x, y + slope_dir.y, new_height)


func _get_max_slope_and_diff(x: int, y: int) -> Array:
	var h = _heightmap.get_point_transformed(x, y)
	var res = Vector2.ZERO
	var max_diff = 0.0
	
	for i in neumann_range:
		for j in neumann_range:
			if not _is_inside_boundaries(x + i, y + j):
				continue
			var nh = _heightmap.get_point_transformed(x + i, y + j)
			var diff = h - nh
			if diff > max_diff:
				max_diff = diff
				res.x = i
				res.y = j
	
	return [res, max_diff]


func _is_inside_boundaries(x: int, y: int) -> bool:
	var sx = _heightmap.size.x
	var sy = _heightmap.size.y
	
	if x < 0 or y < 0:
		return false
	
	if x >= sx or y >= sy:
		return false
	
	return true
