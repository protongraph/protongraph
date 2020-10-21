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
	for key in dict.keys():
		var new_key = format_value(key)
		var value = format_value(dict[key])
		
		if value is Dictionary:
			value = fix_types(value)

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
	
	if value is float:
		if is_equal_approx(round(value), value):
			return int(value)

	return value
