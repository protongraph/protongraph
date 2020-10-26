extends "../base.gd"

func _init(value: String, string: String, context: String) -> void:
	var passed: String = "%s does not contain %s" % [string, value]
	var failed: String = "%s contains %s" % [string, value]
	self.context = context
	self.success = not value in string
	self.expected = passed
	self.result = passed if self.success else failed
