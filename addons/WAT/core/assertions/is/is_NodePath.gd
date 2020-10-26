extends "../base.gd"

func _init(value, context: String) -> void:
	var passed: String = "%s is builtin: NodePath" % value
	var failed: String = "%s is not builtin: NodePath" % value
	self.context = context
	self.success = value is NodePath
	self.expected = passed
	self.result = passed if self.success else failed