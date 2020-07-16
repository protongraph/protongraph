tool
extends ConceptNode


var _noise: ConceptGraphNoise
var _preview: NoisePreview
var _is_preview_outdated := true


func _init() -> void:
	unique_id = "simplex_noise"
	display_name = "Simplex Noise"
	category = "Generators/Noises"
	description = "Create an OpenSimplexNoise to be used by other nodes"

	set_input(0, "Seed", ConceptGraphDataType.SCALAR, {"step": 1, "allow_lesser":true})
	set_input(1, "Octaves", ConceptGraphDataType.SCALAR, {"value": 3, "step": 1, "max": 6, "allow_greater":false})
	set_input(2, "Period", ConceptGraphDataType.SCALAR, {"value": 64, "step": 0.1})
	set_input(3, "Persistence", ConceptGraphDataType.SCALAR, {"value": 0.5, "max": 1, "allow_greater":false})
	set_input(4, "Lacunarity", ConceptGraphDataType.SCALAR, {"value": 2, "step": 0.01, "max":4, "allow_greater":false})
	set_input(5, "Curve", ConceptGraphDataType.CURVE_FUNC)
	set_output(0, "Noise", ConceptGraphDataType.NOISE)


func _ready() -> void:
	connect("input_changed", self, "_on_input_changed")


func _on_default_gui_ready() -> void:
	_preview = preload("res://views/nodes/noise_preview.tscn").instance()
	_preview.connect("preview_requested", self, "_on_preview_requested")
	_preview.connect("preview_hidden", self, "_on_preview_hidden")
	add_child(_preview)


func _generate_outputs() -> void:
	_noise = ConceptGraphNoiseSimplex.new()
	_noise.noise.seed = get_input_single(0, 0)
	_noise.noise.octaves = get_input_single(1, 3)
	_noise.noise.period = get_input_single(2, 64.0)
	_noise.noise.persistence = get_input_single(3, 0.5)
	_noise.noise.lacunarity = get_input_single(4, 2.0)
	_noise.curve = get_input_single(5)

	output[0] = _noise

	if _preview.is_displayed and _is_preview_outdated:
		_preview.create_from_noise(_noise)


func _on_input_changed(slot: int, _value) -> void:
	_is_preview_outdated = true
	if _preview.is_displayed:
		_generate_outputs()


func _on_preview_requested() -> void:
	_generate_outputs()
	emit_signal("raise_request")


func _on_preview_hidden() -> void:
	rect_size = Vector2.ZERO
	update()
