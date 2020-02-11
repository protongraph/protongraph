tool
class_name ConceptNodeMakeVector
extends ConceptNode


var _vector_input: ConceptNodeGuiVectorInput


func _init() -> void:
	set_output(0, "Vector", ConceptGraphDataType.VECTOR)


func _ready() -> void:
	_vector_input = ConceptNodeGuiVectorInput.new()
	add_child(_vector_input)
	_vector_input.connect("value_changed", self, "reset")


func get_node_name() -> String:
	return "Vector"


func get_category() -> String:
	return "Vectors"


func get_description() -> String:
	return "A vector constant"


func get_output(idx: int) -> Vector3:
	return _vector_input.get_vector()


func export_custom_data() -> Dictionary:
	var output = {}
	output["vec3"] = _vector_input.get_value()
	return output


func restore_custom_data(data: Dictionary) -> void:
	if data and data.has("vec3"):
		_vector_input.set_value(data["vec3"])
