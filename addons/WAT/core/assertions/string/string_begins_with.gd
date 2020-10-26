extends "../base.gd"

func _init(value: String, string: String, context: String) -> void:
	var passed: String = "%s begins with %s" % [string, value]
	var failed: String = "%s does not begins with %s" % [string, value]
	self.context = context
	self.success = string.begins_with(value)
	self.expected = passed
	self.result = passed if self.success else failed
