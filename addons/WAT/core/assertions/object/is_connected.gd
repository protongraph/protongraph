extends "../base.gd"

func _init(sender: Object, _signal: String, receiver: Object, method: String, context: String) -> void:
	var passed: String = "%s.%s is connected to %s.%s" % [sender, _signal, receiver, method]
	var failed: String = "%s.%s is not connected to %s.%s" % [sender, _signal, receiver, method]
	self.context = context
	self.success = sender.is_connected(_signal, receiver, method)
	self.expected = passed
	self.result = passed if self.success else failed
