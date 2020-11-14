extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: PoolByteArray" % value
	var failed: String = "%s is not builtin: PoolByteArray" % value
	self.context = context
	self.success = value is PoolByteArray
	self.expected = passed
	self.result = passed if self.success else failed