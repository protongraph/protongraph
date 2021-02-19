extends Object
class_name DictUtil


# When your Dictionary uses this format {key: [values]}, this function creates
# the array if it doesn't exists, or append the new value to the existing array.
static func append_to(dict, key, row):
	if dict.has(key):
		dict[key].append(row)
	else:
		dict[key] = [row]


# Dictionaries received from the websocket sometimes have small inconsistencies
# like having everything as strings, even numerical values, or having integers
# stored as floats. This method (along with format_value) attempt to fix that.
static func fix_types(dict: Dictionary) -> Dictionary:
	var res := {}
	for key in dict:
		var new_key = format_value(key)
		var value

		if dict[key] is Dictionary:
			value = fix_types(dict[key])
		else:
			value = format_value(dict[key])

		res[new_key] = value

	return res


# Takes an arbitrary value and try to recover the base type. Returns the
# original value if nothing can be infered.
# This is not directly related to the DictUtil class but it's mostly used from
# fix_types() above and I don't know where else to define this function.
static func format_value(value):
	if value is String:
		if value.is_valid_integer():
			return value.to_int()

		if value.is_valid_float():
			return value.to_float()

		var vector = string_to_vector(value)
		if vector:
			return vector

	if value is float:
		if is_equal_approx(round(value), value):
			return int(value)

	if value is Array:
		for i in value.size():
			if value[i] is Dictionary:
				value[i] = fix_types(value[i])
			else:
				value[i] = format_value(value[i])

	return value


# Converts a string like this "(0.0, 1.1, 0.5)" into a Vector object
# Detects wether it's a Vector2 or Vector3 automatically.
static func string_to_vector(string: String):
	if not string.begins_with('(') or not string.ends_with(')'):
		return null

	string = string.trim_prefix('(')
	string = string.trim_suffix(')')
	var tokens = string.split(',', false)
	if tokens.size() == 2:
		var vec2 = Vector2.ZERO
		for i in tokens.size():
			tokens[i] = tokens[i].strip_edges()
			if not tokens[i].is_valid_float():
				return null

		vec2.x = tokens[0].to_float()
		vec2.y = tokens[1].to_float()
		return vec2

	elif tokens.size() == 3:
		var vec3 = Vector3.ZERO
		for i in tokens.size():
			tokens[i] = tokens[i].strip_edges()
			if not tokens[i].is_valid_float():
				return null

		vec3.x = tokens[0].to_float()
		vec3.y = tokens[1].to_float()
		vec3.z = tokens[2].to_float()
		return vec3

	return null
