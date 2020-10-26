extends "../base.gd"

func _init(value: String, string: String, context: String) -> void:
	var passed: String = "%s does not begin with %s" % [string, value]
	var failed: String = "%s begins with %s" % [string, value]
	self.context = context
	self.success = not string.begins_with(value)
	self.expected = passed
	self.result = passed if self.success else failed
