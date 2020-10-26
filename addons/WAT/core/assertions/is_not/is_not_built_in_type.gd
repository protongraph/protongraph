extends "../base.gd"

func _init(value, type: int, context: String) -> void:
	self.success = not (typeof(value)) == type
	self.context = context
	var string_type = type2str(type)
	self.result = "|%s| %s %s %s" % [type2str(value), value, ("is not builtin type: " if self.success else "is builtin type: "), string_type]
