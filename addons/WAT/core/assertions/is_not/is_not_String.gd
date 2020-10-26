extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: String" % value
	var failed: String = "%s is builtin: String" % value
	self.context = context
	self.success = not value is String
	self.expected = passed
	self.result = passed if self.success else failed