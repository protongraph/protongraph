class_name PathUtil


# Origin is absolute
static func get_relative_path(absolute_path: String, origin: String) -> String:
	var relative_path = ""

	var t1: Array = absolute_path.split("/")
	var t2: Array = origin.split("/")

	while t1[0] == t2[0]:
		t1.remove(0)
		t2.remove(0)

	for i in t2.size() - 1: # -1 to remove the file name
		relative_path += "../"

	for i in t1.size():
		relative_path += t1[i]
		if i != t1.size() - 1:
			relative_path += "/"

	return relative_path


# Origin is absolute
static func get_absolute_path(relative_path: String, origin: String):
	var absolute_path := ""

	var t1: Array = relative_path.split("/")
	var t2: Array = origin.split("/")
	t2.remove(t2.size() - 1) # remove the file name

	while t1[0] == "..":
		t1.remove(0)
		t2.remove(t2.size() - 1)

	for token in t2:
		absolute_path += token + "/"

	for i in t1.size():
		absolute_path += t1[i]
		if i != t1.size() - 1:
			absolute_path += '/'

	return absolute_path
