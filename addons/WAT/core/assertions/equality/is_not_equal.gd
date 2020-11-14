extends "../base.gd"


func _init(a, b, context: String) -> void:
	self.success = (a != b)
	self.context = context
	self.expected = "|%s| %s != |%s| %s" % [type2str(a), a, type2str(b), b]
	self.result = "|%s| %s %s |%s| %s" % [type2str(a), a, ("is not equal to" if self.success else "is equal to"), type2str(b),b]