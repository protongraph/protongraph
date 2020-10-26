extends "../base.gd"

func _init(double, method: String, args: Array, context: String) -> void:
	var passed: String = "method: %s was called with arguments: %s" % [method, args]
	var failed: String = "method: %s was not called with arguments: %s" % [method, args]
	var alt_failed: String = "method: %s was not called at all" % method
	self.context = context
	self.expected = passed

	if double.call_count(method) == 0:
		self.success = false
		self.result = alt_failed
	elif double.found_matching_call(method, args):
		self.success = true
		self.result = passed
	else:
		self.success = false
		self.result = failed
