extends "../base.gd"

func _init(a, b, context: String) -> void:
	var typeofa = type2str(a)
	var typeofb = type2str(b)
	var passed: String = "|%s| %s is less than |%s| %s" % [typeofa, a, typeofb, b]
	var failed: String = "|%s| %s is equal or greater than |%s| %s" % [typeofa, a, typeofb, b]
	self.context = context
	self.success = (a < b)
	self.expected = passed
	self.result = passed if self.success else failed
