extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: Vector2" % value
	var failed: String = "%s is not builtin: Vector2" % value
	self.context = context
	self.success = value is Vector2
	self.expected = passed
	self.result = passed if self.success else failed