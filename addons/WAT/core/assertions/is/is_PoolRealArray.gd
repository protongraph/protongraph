extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: PoolRealArray" % value
	var failed: String = "%s is not builtin: PoolRealArray" % value
	self.context = context
	self.success = value is PoolRealArray
	self.expected = passed
	self.result = passed if self.success else failed