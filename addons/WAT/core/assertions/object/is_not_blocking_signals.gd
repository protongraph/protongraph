extends "../base.gd"

func _init(obj, context: String) -> void:
	var passed: String = "%s is not blocking signals" % obj
	var failed: String = "%s is blocking signals" % obj
	self.context = context
	self.success = not obj.is_blocking_signals()
	self.expected = passed
	self.result = passed if self.success else failed
