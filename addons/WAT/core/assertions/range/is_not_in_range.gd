extends "../base.gd"

func _init(value, low, high, context: String) -> void:
	var passed: String = "%s is not in range(%s, %s)" % [value, low, high]
	var failed: String = "%s is in range(%s, %s)" % [value, low, high]
	self.context = context
	self.success = not value in range(low, high)
	self.expected = passed
	self.result = passed if self.success else failed
