extends "../base.gd"

func _init(double, method: String, context: String) -> void:
	var passed: String = "%s was not called" % method
	var failed: String = "%s was called" % method
	self.context = context
	self.success = double.call_count(method) <= 0
	self.expected = passed
	self.result = passed if self.success else failed
