extends "../base.gd"

func _init(value: String, string: String, context: String) -> void:
	var passed: String = "%s contains %s" % [string, value]
	var failed: String = "%s does not contain %s" % [string, value]
	self.context = context
	self.success = value in string
	self.expected = passed
	self.result = passed if self.success else failed
