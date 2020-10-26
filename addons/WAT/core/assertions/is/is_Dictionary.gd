extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: Dictionary" % value
	var failed: String = "%s is not builtin: Dictionary" % value
	self.context = context
	self.success = value is Dictionary
	self.expected = passed
	self.result = passed if self.success else failed
