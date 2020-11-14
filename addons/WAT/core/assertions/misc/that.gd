extends "../base.gd"

func _init(obj, method: String, arguments: Array, context: String, passed: String, failed: String) -> void:
	passed = passed % ([obj] + arguments)
	failed = failed % ([obj] + arguments)
	self.success = obj.callv(method, arguments)
	self.context = context
	self.result = passed if self.success else failed
