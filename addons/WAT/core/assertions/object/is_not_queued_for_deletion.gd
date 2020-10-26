extends "../base.gd"

func _init(obj: Object, context: String) -> void:
	var passed: String = "%s is not queued for deletion" % obj
	var failed: String = "%s is queued for deletion" % obj
	self.context = context
	self.expected = passed
	self.success = not obj.is_queued_for_deletion()
	self.result = passed if self.success else failed
