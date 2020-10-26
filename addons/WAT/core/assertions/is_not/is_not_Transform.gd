extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: Transform" % value
	var failed: String = "%s is builtin: Transform" % value
	self.context = context
	self.success = not value is Transform
	self.expected = passed
	self.result = passed if self.success else failed