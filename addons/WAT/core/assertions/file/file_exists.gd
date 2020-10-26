extends "../base.gd"


func _init(path: String, context: String) -> void:
	var passed: String = "%s exists" % path
	var failed: String = "%s does not exist" % path
	self.context = context
	self.success = File.new().file_exists(path)
	self.expected = "%s exists" % path
	self.result = passed if self.success else failed
