extends "../base.gd"

func _init(value: String, string: String, context: String) -> void:
	var passed: String = "%s ends with %s" % [string, value]
	var failed: String = "%s does not end with %s" % [string, value]
	self.context = context
	self.success = string.ends_with(value)
	self.expected = passed
	self.result = passed if self.success else failed
