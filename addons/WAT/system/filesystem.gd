extends Reference

const DO_NOT_SEARCH_PARENT_DIRECTORIES: bool = true

static func test_folder():
	return ProjectSettings.get_setting("WAT/Test_Directory")

static func scripts(path: String = test_folder()) -> PoolStringArray:
	if path.ends_with(".gd"):
		var list: PoolStringArray = [path]
		return list
	else:
		return _parse_for_tests("file_exists", _list_dir(path))
	
static func directories(path: String = test_folder()) -> PoolStringArray:
	return _parse_for("dir_exists", _list_dir(path))
	
static func _list_dir(path: String) -> PoolStringArray:
	var list: PoolStringArray = []
	var subdirectories: PoolStringArray = []
	
	var directory: Directory = Directory.new()
	directory.open(path)
	directory.list_dir_begin(DO_NOT_SEARCH_PARENT_DIRECTORIES)
	var name: String = directory.get_next()
	while name != "":
		
		var absolute_path: String = "%s/%s" % [path, name]
		if directory.dir_exists(absolute_path):
			subdirectories.append(absolute_path)
		list.append(absolute_path)
		name = directory.get_next()
	directory.list_dir_end()
	
	for subdirectory in subdirectories:
		list += _list_dir(subdirectory)
		
	return list
	
static func _parse_for(what_exists: String, list: PoolStringArray) -> PoolStringArray:
	var output: PoolStringArray = []
	var directory: Directory = Directory.new()
	for path in list:
		if directory.call(what_exists, path):
			output.append(path)
	return output

static func _parse_for_tests(what_exists: String, list: PoolStringArray) -> PoolStringArray:
	var output: PoolStringArray = []
	var directory: Directory = Directory.new()
	for path in list:
		if directory.call(what_exists, path):
			if path.ends_with(".gd"):
				output.append(path)
	return output

static func templates():
	var template_directory: String = ProjectSettings.get_setting("editor/script_templates_search_path")
	var dir: Directory = Directory.new()
	if not dir.dir_exists(template_directory):
		dir.make_dir_recursive(template_directory)
	var test_template: String = "wat.test.gd"
	var scripts: Array = scripts(template_directory)
	var template_exist = false
	for script in scripts:
		var title = script.substr(script.find_last("/") + 1, -1)
		if title == test_template:
			template_exist = true
			break
	return {savepath = template_directory, exists = template_exist}
