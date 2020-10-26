extends "../base.gd"


func _init(value, type: int, context: String) -> void:
	self.success = (typeof(value)) == type
	self.context = context
	var string_type = type2str(type)
	self.result = "%s %s %s" % [value, ("is builtin type: " if self.success else "is not builtin type: "), string_type]
