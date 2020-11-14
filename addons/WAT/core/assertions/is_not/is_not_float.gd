extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: float" % value
	var failed: String = "%s is builtin: float" % value
	self.context = context
	self.success = not value is float
	self.expected = passed
	self.result = passed if self.success else failed