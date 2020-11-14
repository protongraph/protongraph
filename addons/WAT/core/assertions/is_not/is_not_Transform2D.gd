extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: Transform2D" % value
	var failed: String = "%s is builtin: Transform2D" % value
	self.context = context
	self.success = not value is Transform2D
	self.expected = passed
	self.result = passed if self.success else failed