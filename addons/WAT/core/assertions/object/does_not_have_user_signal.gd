extends "../base.gd"

func _init(obj: Object, _signal: String, context: String) -> void:
	var passed: String = "%s does not have user signal: %s" % [obj, _signal]
	var failed: String = "%s has user signal: %s" % [obj, _signal]
	self.context = context
	self.success = not obj.has_user_signal(_signal)
	self.expected = passed
	self.result = passed if self.success else failed
