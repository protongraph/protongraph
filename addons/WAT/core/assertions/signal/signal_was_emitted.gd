extends "../base.gd"

func _init(emitter, event: String, context: String) -> void:
	var passed: String = "signal: %s was emitted from %s" % [event, emitter]
	var failed: String = "signal: %s was not emitted from %s" % [event, emitter]
	self.context = context
	self.success = emitter.get_meta("watcher").watching[event].emit_count > 0
	self.expected = passed
	self.result = passed if self.success else failed
