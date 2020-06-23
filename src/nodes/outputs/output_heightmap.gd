tool
extends ConceptNode

var _material: Material = preload("res://addons/concept_graph/src/resources/heightmap/heightmap.material")


func _init() -> void:
	unique_id = "output_heightmap"
	display_name = "Output Heightmap"
	category = "Output"
	description = "Outputs a heightmap as a PlaneMesh with vertex shader"
	
	set_input(0, "HeightMap", ConceptGraphDataType.HEIGHTMAP)
	set_input(1, "Subdivide", ConceptGraphDataType.SCALAR, {"value": 64, "step":1, "min":1, "allow_lesser": false})


func _generate_outputs() -> void:
#	var start_time = OS.get_ticks_msec()
	
	var heightmap: ConceptGraphHeightmap = get_input_single(0)
	var subdivide: int = get_input_single(1, 64)
	
	if not heightmap:
		return
	
	output.append(get_plane_mesh(heightmap, subdivide))
	
#	var gen_time = OS.get_ticks_msec() - start_time
#	print("Heightmap created in " + str(gen_time) + "ms")


func get_plane_mesh(heightmap: ConceptGraphHeightmap, subdivide: int) -> MeshInstance:
	
	var size: Vector2 = heightmap.mesh_size - Vector2(1,1)
	var height: float = heightmap.height_scale
	var offset: float = heightmap.height_offset
	
	var data = heightmap.data
	var heighest := 0.0
	var lowest := 0.0
	for h in data:
		h *= height
		if h > heighest:
			heighest = h 
		if h < lowest:
			lowest = h
	
	var image = heightmap.get_image()
	var texture := ImageTexture.new()
	texture.create_from_image(image, Texture.FLAG_FILTER)
	_material.set_shader_param("heightmap", texture)
	_material.set_shader_param("height", height)
	_material.set_shader_param("offset", offset)
	
	var plane := PlaneMesh.new()
	plane.size = size
	plane.subdivide_width = subdivide
	plane.subdivide_depth = subdivide
	plane.material = _material
	plane.custom_aabb = AABB(
		Vector3(size.x * -0.5, lowest, size.y * -0.5),
		Vector3(size.x, heighest, size.y)
	)
	
	var mi = MeshInstance.new()
	mi.mesh = plane
	mi.translate(Vector3(size.x * 0.5, 0.0, size.y * 0.5))
	
	return mi


func is_final_output_node() -> bool:
	return true


func reset() -> void:
	.reset()
	emit_signal("node_changed", self, true)
