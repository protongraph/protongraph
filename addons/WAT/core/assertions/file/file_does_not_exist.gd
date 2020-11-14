extends "../base.gd"

func _init(path: String, context: String) -> void:
	var passed: String = "%s does not exist" % path
	var failed: String = "%s exists" % path
	self.context = context
	self.success = not File.new().file_exists(path)
	self.expected = "%s does not exist" % path
	self.result = passed if self.success else failed
