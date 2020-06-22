tool
extends ConceptNode

func _init() -> void:
	unique_id = "heightmap_apply_image"
	display_name = "Apply Image"
	category = "Modifiers/Heightmaps/3D"
	description = "Apply an image to a heightmap"

	set_input(0, "Heightmap", ConceptGraphDataType.HEIGHTMAP)
	set_input(1, "Image", ConceptGraphDataType.TEXTURE)
	set_input(2, "Scale", ConceptGraphDataType.VECTOR3, {"value": 1})
	set_input(3, "Offset", ConceptGraphDataType.VECTOR3)
	set_input(4, "Rotation", ConceptGraphDataType.SCALAR)
	set_input(5, "Curve", ConceptGraphDataType.CURVE_FUNC)

	set_output(0, "", ConceptGraphDataType.HEIGHTMAP)


func _generate_outputs() -> void:
	var heightmap: ConceptGraphHeightmap = get_input_single(0)
	var texture: Texture = get_input_single(1)
	var scale: Vector3 = get_input_single(2, Vector3.ONE)
	var offset: Vector3 = get_input_single(3, Vector3.ZERO)
	var rotation: float = get_input_single(4, 0)
	var curve: Curve = get_input_single(5)

	var data: Array = heightmap.data # looping on a local var is faster
	var map_size: Vector2 = heightmap.size
	var mesh_size: Vector2 = heightmap.mesh_size
	
	var image: Image
	if texture:
		image = texture.get_data()
	
	if image:
		var v2_scale = Vector2(scale.x, scale.z)
		var v2_offset = Vector2(offset.x, offset.z)
		
		var image_size = image.get_size()
		var image_center = image_size * 0.5
		
		var new_size = map_size * v2_scale
		var ratio = image_size / new_size
		
		var total_offset = (new_size - map_size) * 0.5
		total_offset += map_size * v2_offset# * 0.5
		
		var c: Color
		var pos: Vector2
		var h := 0.0
		var i := 0
		
		image.lock()
		
		for y in map_size.y:
			for x in map_size.x:
				pos = (Vector2(x, y) + total_offset) * ratio
				
				if rotation:
					pos = (pos - image_center).rotated(deg2rad(rotation)) + image_center
				
				if pos.x < 0 or pos.x >= image_size.x: continue
				if pos.y < 0 or pos.y >= image_size.y: continue
				
				c = image.get_pixel(pos.x, pos.y)
				h = (c.r + c.g + c.b) / 3
				
				if curve:
					h = curve.interpolate_baked(h)
				
				data[y * map_size.y + x] += (h + offset.y) * scale.y
		
		image.unlock()
	
	heightmap.data = data
	output[0].append(heightmap)
