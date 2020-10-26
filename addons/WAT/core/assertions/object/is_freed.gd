extends "../base.gd"

func _init(object: Object, context: String) -> void:
	var passed: String = "%s is freed from memory" % object
	var failed: String = "%s is not freed from memory" % object
	self.context = context
	self.success = not is_instance_valid(object)
	self.expected = passed
	self.result = passed if self.success else failed
