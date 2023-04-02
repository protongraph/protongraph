extends ProtonNode


func _init() -> void:
	type_id = "create_pbr_material"
	title = "Create PBR Material"
	category = "Generators/Materials"
	description = "Creates a standard PBR material"

	create_input("albedo_color", "Color", DataType.COLOR, SlotOptions.new(Color.WHITE))

	var opts := SlotOptions.new()
	opts.value = 0.5
	opts.step = 0.01
	opts.min_value = 0.0
	opts.max_value = 1.0
	opts.allow_greater = false
	opts.allow_lesser = false
	create_input("roughness", "Roughness", DataType.NUMBER, opts)
	create_input("metallic", "Metallic", DataType.NUMBER, opts.get_copy())

	create_input("albedo_texture", "Diffuse map", DataType.TEXTURE_2D)
	create_input("normal_texture", "Normal map", DataType.TEXTURE_2D)
	create_input("roughness_texture", "Roughness map", DataType.TEXTURE_2D)
	create_input("metallic_texture", "Metallic map", DataType.TEXTURE_2D)

	create_output("out", "Material", DataType.MATERIAL)


func _generate_outputs() -> void:

	var material := StandardMaterial3D.new()
	material.albedo_color = get_input_single("albedo_color", Color.WHITE)
	material.albedo_texture = get_input_single("albedo_texture", null)
	material.normal_texture = get_input_single("normal_texture", null)
	material.roughness = get_input_single("roughness", 0.5)
	material.roughness_texture = get_input_single("roughness_texture", null)
	material.metallic = get_input_single("metallic", 0.5)
	material.metallic_texture = get_input_single("metallic_texture", null)

	set_output("out", material)
