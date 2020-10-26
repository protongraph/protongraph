extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: PoolVector3Array" % value
	var failed: String = "%s is builtin: PoolVector3Array" % value
	self.context = context
	self.success = not value is PoolVector3Array
	self.expected = passed
	self.result = passed if self.success else failed