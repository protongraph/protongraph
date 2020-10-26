extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is not builtin: Basis" % value
	var failed: String = "%s is builtin: Basis" % value
	self.context = context
	self.success = not value is Basis
	self.expected = passed
	self.result = passed if self.success else failed
