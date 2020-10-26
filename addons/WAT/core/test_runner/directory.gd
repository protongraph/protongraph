extends Directory
# Not sure if we need tool?

# 1) On Plugin Or GUI Load: Initialize
# 2) Validate & Cache Scripts
# 3) Update Metadata (exist in dictionaries) // we loop through a tag array
# 4) We save a new dictionary (do we? yes for the test runner!) into the resource

var _directory: Resource
var _cache: Array = []
var _dir: Dictionary = {}

func _init():
	initialize()
	
func index(dir: String = test_directory()) -> void:
	
	var dirs: Array = []
	
	open(dir)
	_directory.directory.set(dir, [])
	
	list_dir_begin(true)
	
	var name = get_next()
	while name != "":
		var p = "%s/%s" % [dir, name]
		if p.ends_with(".gd") and file_exists(p):
			var test = load(p)
			if is_test(test):
				_cache.append(test)
				_dir[dir].append(p)
		elif dir_exists(p):
			dirs.append(p)
		name = get_next()
		
	list_dir_end()
	
	for dir in dirs:
		index(dir)
		
func is_test(test) -> bool:
	# Fix Up For Suite / if multi-suite, use ()
	return is_instance_valid(test) and test.get_instance_base_type() == "WAT.Test"
	
func initialize() -> void:
	var savepath: String = "%s/.test.tres" % test_directory()
	_directory = load(savepath) if file_exists(savepath) else Repo.new()
	index()
	# Implement Tag checks here?
	save()
	
func save() -> void:
	ResourceSaver.save("%s/.test.tres" % test_directory(), _directory)
	
func test_directory() -> String:
	return ProjectSettings.get_setting("WAT/Test_Directory")
	
func fetch() -> Array:
	var tests: Array = []
	var execution_path: String = ProjectSettings.get_setting("WAT/ActiveRunPath")
	for key in _directory.directory:
		if key.begins_with(execution_path):
			for t in _directory.directory.key:
				tests.append(load(t))
	return tests

class Repo extends Resource:
	
	export(Dictionary) var directory: Dictionary = {}
