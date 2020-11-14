extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: PoolStringArray" % value
	var failed: String = "%s is not builtin: PoolStringArray" % value
	self.context = context
	self.success = value is PoolStringArray
	self.expected = passed
	self.result = passed if self.success else failed