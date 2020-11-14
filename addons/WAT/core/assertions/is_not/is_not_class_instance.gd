extends "../base.gd"

func _init(instance, klass: Script, context: String) -> void:
	var passed: String = "%s is not instance of class: %s" % [instance, klass]
	var failed: String = "%s is instance of class: %s" % [instance, klass]
	self.context = context
	self.success = not instance is klass
	self.expected = passed
	self.result = passed if self.success else failed
