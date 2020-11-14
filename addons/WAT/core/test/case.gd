extends Reference

var total: int = 0
var passed: int = 0
var title: String
var path: String
var methods: Array = []
var success: bool = false
var time_taken: float = 0.0

func _init(test_title: String, test_path: String) -> void:
	title = test_title
	path = test_path
	
func add_method(name: String) -> void:
	name = name.replace("_", " ").lstrip("test")
	methods.append({context = name, assertions = [], total = 0, passed = 0, success = false, time = 0.0})

func _on_test_method_described(description: String) -> void:
	methods.back().context = description
	
func _on_asserted(assertion: Object) -> void:
	methods.back().assertions.append(assertion.to_dictionary())
	
func calculate() -> void:
	for method in methods:
		for assertion in method.assertions:
			method.passed += assertion.success as int
		method.total = method.assertions.size()
		method.success = method.total > 0 and method.total == method.passed
		passed += method.success as int
	total = methods.size()
	success = total > 0 and total == passed
	
func to_dictionary() -> Dictionary:
	return { "total": total, 
			 "passed": passed, 
			 "context": title, 
			 "methods": methods, 
			 "success": success,
			 "path": path,
			 "time_taken": time_taken
			}
