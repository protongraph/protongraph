extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: bool" % value
	var failed: String = "%s is not builtin: bool" % value
	self.context = context
	self.success = value is bool
	self.expected = passed
	self.result = passed if self.success else failed