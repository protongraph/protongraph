extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: RID" % value
	var failed: String = "%s is builtin: RID" % value
	self.context = context
	self.success = not value is RID
	self.expected = passed
	self.result = passed if self.success else failed