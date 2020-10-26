extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: Rect2" % value
	var failed: String = "%s is not builtin: Rect2" % value
	self.context = context
	self.success = value is Rect2
	self.expected = passed
	self.result = passed if self.success else failed