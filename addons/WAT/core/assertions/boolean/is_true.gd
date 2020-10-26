extends "../base.gd"

func _init(value, context: String) -> void:
	var type = type2str(value)
	var passed: String = "|%s| %s == true" % [type, value]
	var failed: String = "|%s| %s != true" % [type, value]
	self.context = context
	self.success = (value == true)
	self.expected = passed
	self.result = passed if self.success else failed
