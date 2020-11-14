extends "../base.gd"

func _init(object: Object, meta: String, context: String) -> void:
	var passed: String = "%s does not have meta: %s" % [object, meta]
	var failed: String = "%s has meta: %s" % [object, meta]
	self.context = context
	self.success = not object.has_meta(meta)
	self.expected = passed
	self.result = passed if self.success else failed
