extends ProtonNode


const moore_range := [-1, 0, 1, -1, 1, -1, 0, 1]
const neumann_range := [-1, 1, -1, 1]

var _source: Heightmap
var _target: Heightmap
var _threshold: float
var _rate: float


func _init() -> void:
	unique_id = "heightmap_thermal_erosion"
	display_name = "Thermal Erosion"
	category = "Modifiers/Heightmaps"
	description = "Erode the heightmap by simulating matter deposit based on slopes"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Iterations", DataType.SCALAR, {"step": 1, "min": 0, "allow_lesser": false})
	set_input(2, "Slope Angle", DataType.SCALAR)
	set_input(3, "Erosion Rate", DataType.SCALAR, 
		{"value": 0.5, "min": 0.0, "max": 1.0, "allow_lesser": false, "allow_greater": false})
	set_output(0, "", DataType.HEIGHTMAP)
	set_extra(0, Constants.UI_PREVIEW_2D, {"output_index": 0})
	
	debug_mode = true
	ignore = true


# Doesn't work reliably yet
func _gpu_generate_outputs() -> void:
	var heightmap: Heightmap = get_input_single(0)
	var iterations: int = int(get_input_single(1, 16))
	var threshold: float = deg2rad(get_input_single(2, 0.0))
	var rate: float = get_input_single(2, 0.0)
	
	var material: ShaderMaterial = load("res://common/lib/heightmap_thermal_erosion.tres")
	material.set_shader_param("mesh_size", heightmap.mesh_size.x)
	material.set_shader_param("texture_size", heightmap.size.x)
	material.set_shader_param("scale", heightmap.height_scale)
	material.set_shader_param("threshold", threshold)
	material.set_shader_param("erosion_rate", rate)

	var color_rect: ColorRect = ColorRect.new()
	color_rect.rect_min_size = heightmap.size
	color_rect.material = material

	var viewport: Viewport = Viewport.new()
	viewport.size = heightmap.size
	viewport.add_child(color_rect)
	
	var texture: ImageTexture = ImageTexture.new()
	texture.create_from_image(heightmap.get_texture().get_data())
	for i in iterations:
		material.set_shader_param("map", texture)
		RenderTargetsPool.render(viewport)
		while not RenderTargetsPool.is_ready(viewport):
			OS.delay_msec(16)
		texture.create_from_image(viewport.get_texture().get_data())
	
	heightmap.set_from_image(texture.get_data())
	output[0].push_back(heightmap)
		
	viewport.queue_free()


func _generate_outputs() -> void:
	_source = get_input_single(0)
	if not _source:
		return
	
	# Node parameters
	var iterations: int = get_input_single(1, 1)
	_threshold = deg2rad(get_input_single(2, 0.0))
	_rate = get_input_single(3, 0.20)

	for i in iterations:
		_erosion_step()

	output[0].push_back(_source)


func _erosion_step():
	_target = _source.duplicate(null)
	var cell_size = _source.mesh_size / _source.size
	for x in _source.size.x:
		for y in _source.size.y:
			var h = _source.get_point_transformed(x, y)
			var data = _get_max_slope_and_diff(x, y)
			var slope_dir: Vector2 = data[0]
			var diff: float = data[1]
			if slope_dir == Vector2.ZERO:
				continue
			var slope = atan(diff / cell_size.x)
			if slope >= _threshold:
				var amount = diff * _rate
				var new_height = h - amount
				_target.set_point_transformed(x, y, new_height)
				new_height = _source.get_point_transformed(x + slope_dir.x, y + slope_dir.y) + amount
				_target.set_point_transformed(x + slope_dir.x, y + slope_dir.y, new_height)
	_source = _target


func _get_max_slope_and_diff(x: int, y: int) -> Array:
	var h = _source.get_point_transformed(x, y)
	var res = Vector2.ZERO
	var max_diff = 0.0
	
	for i in neumann_range:
		for j in neumann_range:
			if not _is_inside_boundaries(x + i, y + j):
				continue
			var nh = _source.get_point_transformed(x + i, y + j)
			var diff = h - nh
			if diff > max_diff:
				max_diff = diff
				res.x = i
				res.y = j
	
	return [res, max_diff]


func _is_inside_boundaries(x: int, y: int) -> bool:
	var sx = _source.size.x
	var sy = _source.size.y
	
	if x < 0 or y < 0:
		return false
	
	if x >= sx or y >= sy:
		return false
	
	return true
