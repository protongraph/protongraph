extends "../base.gd"

func _init(obj: Object, method: String, context: String) -> void:
	var passed: String = "%s has method: %s" % [obj, method]
	var failed: String = "%s does not have method: %s" % [obj, method]
	self.context = context
	self.success = obj.has_method(method)
	self.expected = passed
	self.result = passed if self.success else failed
