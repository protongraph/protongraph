extends ProtonNode

# Ported from Sebastian Lague Hydraulic Erosion project
# https://github.com/SebLague/Hydraulic-Erosion


var _rng := RandomNumberGenerator.new()
var _brush := []
var _brush_diameter := 1


func _init() -> void:
	unique_id = "heightmap_droplet_erosion"
	display_name = "Hydraulic Erosion"
	category = "Modifiers/Heightmaps"
	description = "Erode the heightmap by simulating rainfall"

	set_input(0, "Heightmap", DataType.HEIGHTMAP)
	set_input(1, "Seed", DataType.SCALAR, {"step": 1})
	
	set_input(2, "Iterations", DataType.SCALAR, 
		{"min": 0, "allow_lesser": false, "value": 1000})
	
	# Multiplier for how much sediment a droplet can carry
	set_input(3, "Carry Capacity", DataType.SCALAR, 
		{"min": 0, "allow_lesser": false})
		
	set_input(4, "Evaporation", DataType.SCALAR)
	
	# At zero, water will instantly change direction to flow downhill. At 1, water will never change direction
	set_input(5, "Inertia", DataType.SCALAR, 
		{"min": 0, "max": 1, "value": 0.05, "allow_higher": false, "allow_lesser": false})
		
	set_input(6, "Radius", DataType.SCALAR)
	set_input(7, "Gravity", DataType.SCALAR)
	set_input(8, "Erosion Speed", DataType.SCALAR)
	set_input(9, "Deposit Speed", DataType.SCALAR)

	set_output(0, "", DataType.HEIGHTMAP)


func _generate_outputs() -> void:
	# Node parameters
	var heightmap: Heightmap = get_input_single(0)
	
	var custom_seed: int = get_input_single(1, 0)
	var iterations: int = get_input_single(2, 1000)
	var carry_capacity: float = get_input_single(3, 0.5)
	var evaporate_speed: float = get_input_single(4, 0.01)
	var inertia: float = get_input_single(5, 0.5)
	var radius: float = get_input_single(6, 2)
	var gravity: float = get_input_single(7, 2)
	var erode_speed: float = get_input_single(8, 2)
	var deposit_speed: float = get_input_single(9, 2)
	
	_rng.set_seed(custom_seed)
	_generate_brush(radius, heightmap)
	
	var map_size: Vector2 = heightmap.size
	var lifetime := (map_size.x / 100) * 25

	var area = PI * pow(_brush_diameter / 2.0, 2.0)

	for i in iterations:
		# Create a water droplet

		var pos := Vector2.ZERO
		pos.x = _rng.randf_range(0, heightmap.size.x - 1)
		pos.y = _rng.randf_range(0, heightmap.size.y - 1)
		
		var dir := Vector2.ZERO
		var water = 1
		var speed = 1
		var sediment = 0
		
		for j in lifetime:
			# Get droplet height and direction
			var hg = _get_height_and_gradient(pos, heightmap)
			var height = hg[0]
			var gx = hg[1]
			var gy = hg[2]
			
			dir.x = dir.x * inertia - gx * (1 - inertia)
			dir.y = dir.y * inertia - gy * (1 - inertia)

			# Early stop if the droplet stopped moving
			if dir == Vector2.ZERO:
				break
			
			dir = dir.normalized()
			var new_pos = pos + dir
			
			# Early stop if the droplet went outside of the map
			if _is_outside_boundaries(new_pos, map_size):
				break

			# Find new height and delta height
			var new_height = _get_height_and_gradient(new_pos, heightmap)[0]
			var delta_height = new_height - height
			
			var capacity = max(-delta_height * speed * water * carry_capacity, 0.01)
			
			if sediment > capacity or delta_height > 0:
				var amount_to_deposit = (sediment - capacity) * deposit_speed
				if delta_height > 0:
					amount_to_deposit = min(delta_height, sediment)

				#sediment -= amount_to_deposit
				#_deposit_old(pos, amount_to_deposit, heightmap)
				sediment -= _deposit(pos, amount_to_deposit, heightmap)
			
			else:
				# Erode a fraction of the droplet's current carry capacity.
				# Clamp the erosion to the change in height so that it doesn't dig a hole in the terrain behind the droplet
				var amount_to_erode = min((capacity - sediment) * erode_speed, -delta_height)

				sediment += _erode(pos, amount_to_erode, heightmap)

			# Update droplet's speed and water content
			speed = sqrt(speed * speed + delta_height * gravity)
			water *= (1 - evaporate_speed)
			pos = new_pos

	output[0].push_back(heightmap)


"""
Returns the gradient and height at the given position
Because the x and y values are float instead of int, we have to interpolate
the final values from the 4 pixels around that (px, py) point

# TODO : Maybe move this to the heightmap class?
"""
func _get_height_and_gradient(pos: Vector2, heightmap: Heightmap) -> Array:
	var ix = int(pos.x)
	var iy = int(pos.y)
	var x = pos.x - ix
	var y = pos.y - iy

	var nw = heightmap.get_point(ix, iy)
	var ne = heightmap.get_point(ix + 1, iy)
	var sw = heightmap.get_point(ix, iy + 1)
	var se = heightmap.get_point(ix + 1, iy + 1)
	
	# Use Bilinear interpolation to calculate the gradient and height
	var gx = (ne - nw) * (1 - y) + (se - sw) * y
	var gy = (sw - nw) * (1 - x) + (se - ne) * x

	var height = nw * (1 - x) * (1 - y) + ne * x * (1 - y) + sw * (1 - x) * y + se * x * y
	
	return [height, gx, gy]


"""
Add the sediment to the four nodes of the current cell using bilinear interpolation
Deposition is not distributed over a radius (like erosion) so that it can fill small pits
"""
func _deposit_old(pos, amount, heightmap) -> void:
	var ix = int(pos.x)
	var iy = int(pos.y)
	var x = pos.x - ix
	var y = pos.y - iy
	
	var size_y = heightmap.size.y
	var idx = iy * size_y + ix
	heightmap.data[idx] += amount * (1 - x) * (1 - y)
	
	idx = iy * size_y + ix + 1
	heightmap.data[idx] += amount * x * (1 - y)
	
	idx = (iy + 1) * size_y + ix
	heightmap.data[idx] += amount * (1 - x) * y
	
	idx = (iy + 1) * size_y + ix + 1
	heightmap.data[idx] += amount * x * y


func _deposit(pos: Vector2, amount: float, heightmap: Heightmap) -> float:
	var acc = 0.0
	var r = _brush_diameter / 2.0
	var area = PI * r * r
	
	for y in _brush_diameter:
		for x in _brush_diameter:
			var p := pos + Vector2(x - r, y - r)
			if _is_outside_boundaries(p, heightmap.size):
				continue

			var current_height = heightmap.get_point(p.x, p.y)
			var brush_index = y * _brush_diameter + x
			var weight: float = _brush[brush_index]
			var delta_sediment = amount * weight

			heightmap.set_point(p.x, p.y, current_height + delta_sediment)
			acc += delta_sediment / area

	return acc


func _erode(pos: Vector2, amount: float, heightmap: Heightmap) -> float:
	var acc = 0.0
	var r = _brush_diameter / 2.0
	var area = PI * r * r
		
	for y in _brush_diameter:
		for x in _brush_diameter:
			var p := pos + Vector2(x - r, y - r)
			if _is_outside_boundaries(p, heightmap.size):
				continue

			var current_height = heightmap.get_point(p.x, p.y)
			var brush_index = y * _brush_diameter + x
			var weight: float = _brush[brush_index]
			var delta_sediment = amount * weight
			if delta_sediment > current_height:
				delta_sediment = current_height

			heightmap.set_point(p.x, p.y, current_height - delta_sediment)
			acc += delta_sediment / area

	return acc


func _generate_brush(radius_percent, heightmap) -> void:
	var diameter: int = max(2 * (heightmap.size.x / 100.0) * radius_percent, 1)
	var radius = diameter / 2.0
	var radius2 = radius * radius
	
	_brush_diameter = diameter
	_brush.resize(diameter * diameter)
	var center = Vector2(int(radius), int(radius))
	
	for y in diameter:
		for x in diameter:
			#var value: float = max(1.0 - (Vector2(x, y).distance_squared_to(center) / radius2), 0.0)
			var value: float = max(1.0 - (Vector2(x, y).distance_to(center) / radius), 0.0)
			_brush[y * diameter + x] = value
	
	return
	for y in diameter:
		var buf = ""
		for x in diameter:
			buf += String(_brush[y * diameter + x]) + ", "
		print(buf)


func _is_outside_boundaries(pos: Vector2, size) -> bool:
	if int(pos.x) < 0 or int(pos.y) < 0:
		return true
	
	if int(pos.x) >= size.x - 1 or int(pos.y) >= size.y - 1:
		return true
	
	return false 
