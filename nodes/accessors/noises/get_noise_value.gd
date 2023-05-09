extends ProtonNode


func _init() -> void:
	type_id = "get_noise_value"
	title = "Get noise value"
	category = "Accessors/Noise"
	description = "Returns the noise value at the given coordinates."

	create_input("noise", "Noise", DataType.NOISE)

	var opts := SlotOptions.new()
	opts.add_dropdown_item(DataType.VECTOR2, "Vector 2")
	opts.add_dropdown_item(DataType.VECTOR3, "Vector 3")
	opts.value = DataType.VECTOR2
	create_input("vec_type", "", DataType.MISC, opts)

	opts = SlotOptions.new()
	opts.supports_field = true
	create_input("coords", "Position", DataType.VECTOR2, opts)

	create_output("out", "Noise value", DataType.NUMBER, opts.get_copy())

	local_value_changed.connect(_on_local_value_changed)


func _generate_outputs() -> void:
	var noise: ProtonNoise = get_input_single("noise", null)

	if not noise:
		return

	var noise_value_field := Field.new()
	var vector_type = get_input_single("vec_type")
	var coords: Field

	match vector_type:
		DataType.VECTOR2:
			coords = get_input_single("coords", Vector2.ZERO)
			noise_value_field.set_generator(_get_value_2d.bind(noise, coords))

		DataType.VECTOR3:
			coords = get_input_single("coords", Vector3.ZERO)
			noise_value_field.set_generator(_get_value_3d.bind(noise, coords))

	set_output("out", noise_value_field)



func _get_value_2d(noise: ProtonNoise, coords: Field) -> float:
	return noise.get_noise_2dv(coords.get_value())


func _get_value_3d(noise: ProtonNoise, coords: Field) -> float:
	return noise.get_noise_3dv(coords.get_value())


func _on_local_value_changed(idx: String, _value) -> void:
	if idx != "vec_type":
		return

	var vec_type: int = get_input_single("vec_type", DataType.VECTOR3)
	var coords_slot: ProtonNodeSlot = inputs["coords"]
	coords_slot.type = vec_type

	# Notify to rebuild this node UI
	layout_changed.emit()
