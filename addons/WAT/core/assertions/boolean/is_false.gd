extends "../base.gd"

func _init(value, context: String) -> void:
	var type = type2str(value)
	var passed: String = "|%s| %s == false" % [type, value]
	var failed: String = "|%s| %s != false" % [type, value]
	self.context = context
	self.success = (value == false)
	self.expected = passed
	self.result = passed if self.success else failed
