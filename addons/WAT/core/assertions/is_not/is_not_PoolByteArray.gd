extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: PoolByteArray" % value
	var failed: String = "%s is builtin: PoolByteArray" % value
	self.context = context
	self.success = not value is PoolByteArray
	self.expected = passed
	self.result = passed if self.success else failed