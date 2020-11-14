extends Reference

const FileSystem: Script = preload("res://addons/WAT/system/filesystem.gd")
var _tests: Array = []

func metadata() -> Resource:
	var path = ProjectSettings.get_setting("WAT/Test_Directory")
	var loadpath: String = "%s/.test/metadata.tres" % path
	var object = load(loadpath)
	return object

func deposit(tests: Array) -> void:
	_tests = tests
	
func last_failed() -> Array:
	_tests = load("res://addons/WAT/resources/results.tres").failures
	var tests = _load_tests()
	_tests = []
	return tests

func all() -> Array:
	_tests = FileSystem.scripts(ProjectSettings.get_setting("WAT/Test_Directory"))
	var tests = _load_tests()
	_tests = []
	return tests

func directory(_directory: String) -> Array:
	_tests = FileSystem.scripts(_directory)
	var tests = _load_tests()
	_tests = []
	return tests
	
func script(_script: String) -> Array:
	_tests = [_script]
	var tests = _load_tests()
	_tests = []
	return tests
	
func tag(tag: String) -> Array:
	var tagged: Array = []
	var path = ProjectSettings.get_setting("WAT/Test_Directory")
	var loadpath: String = "res://.test/metadata.tres"
	var Index = load(loadpath)
	for i in Index.scripts.size():
		if Index.tags[i].has(tag):
			tagged.append(Index.scripts[i].resource_path)
	_tests = tagged
	var tests = _load_tests()
	_tests = []
	return tests
	
func deposited() -> Array:
	return _tests
#	var tests = _tests.duplicate()
#	_tests = []
#	return tests
	
func _load_tests() -> Array:
	var tests: Array = []
	for path in _tests:
		# Can't load WAT.Test here for whatever reason
		if path is String and not path.ends_with(".gd"):
			path = path.substr(0, path.find(".gd") + 3)
		var test = load(path) if path is String else path
		if test.get("TEST") != null:
			tests.append(test)
		elif test.get("IS_WAT_SUITE") and Engine.get_version_info().minor == 2:
			tests += _suite_of_suites_3p2(test)
		elif test.get("IS_WAT_SUITE") and Engine.get_version_info().minor == 1:
			tests += _suite_of_suites_3p1(test)
	return tests

func _suite_of_suites_3p2(suite_of_suites) -> Array:
	var subtests: Array = []
	for constant in suite_of_suites.get_script_constant_map():
		var expression: Expression = Expression.new()
		expression.parse(constant)
		var subtest = expression.execute([], suite_of_suites)
		if subtest.get("TEST") != null:
			subtest.set_meta("path", "%s.%s" % [suite_of_suites.get_path(), constant])
			subtests.append(subtest)
	return subtests
	
func _suite_of_suites_3p1(suite_of_suites) -> Array:
	var subtests: Array = []
	var source = suite_of_suites.source_code
	for l in source.split("\n"):
		if l.begins_with("class"):
			var classname = l.split(" ")[1]
			var expr = Expression.new()
			expr.parse(classname)
			var subtest = expr.execute([], suite_of_suites)
			if subtest.get("TEST") != null:
				subtest.set_meta("path", "%s.%s" % [suite_of_suites.get_path(), classname])
				subtests.append(subtest)
	return subtests
