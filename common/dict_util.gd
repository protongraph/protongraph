extends Object
class_name DictUtil


# When your Dictionary uses this format {key: [values]}, this function creates
# the array if it doesn't exists, or append the new value to the existing array.
static func append_to(dict, key, row):
	if dict.has(key):
		dict[key].append(row)
	else:
		dict[key] = [row]
