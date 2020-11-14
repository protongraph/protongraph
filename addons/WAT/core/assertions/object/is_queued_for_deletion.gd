extends "../base.gd"

func _init(obj: Object, context: String) -> void:
	var passed: String = "%s is queued for deletion" % obj
	var failed: String = "%s is not queued for deletion" % obj
	self.expected = passed
	self.context = context
	self.success = obj.is_queued_for_deletion()
	self.result = passed if self.success else failed
