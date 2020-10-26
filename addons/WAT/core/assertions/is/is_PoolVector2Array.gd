extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: PoolVector2Array" % value
	var failed: String = "%s is not builtin: PoolVector2Array" % value
	self.context = context
	self.success = value is PoolVector2Array
	self.expected = passed
	self.result = passed if self.success else failed