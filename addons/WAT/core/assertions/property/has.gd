extends "../base.gd"

func _init(value, container, context: String) -> void:
	var passed: String = "%s has %s" % [container, value]
	var failed: String = "%s has %s" % [container, value]
	self.context = context
	self.success = container.has(value)
	self.expected = "%s has %s" % [container, value]
	self.result = passed if self.success else failed

