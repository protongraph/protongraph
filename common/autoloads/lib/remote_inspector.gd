class_name RemoteInspector

# Used to replicate the clients inspector values when they request a build


var _values := {}


func update_variables(variables: Array) -> void:
	_values = {}

	# Variable format : {"name": "var_name", "value": value}
	for v in variables:
		var vname = v["name"].to_lower()
		if not _values.has(vname):
			_values[vname] = v["value"]


func get_value(name):
	name = name.to_lower()
	if _values.has(name):
		return _values[name]

	return null


func get_all_values(storage := false) -> Dictionary:
	return _values


func set_all_values(values) -> void:
	pass
