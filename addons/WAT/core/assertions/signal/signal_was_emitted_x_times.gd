extends "../base.gd"

func _init(emitter, event: String, times: int, context: String) -> void:
	var passed: String = "signal: %s was emitted from %s %s" % [event, emitter, times as String]
	var failed: String = "signal: %s was not emitted from %s %s" % [event, emitter, times as String]
	self.context = context
	self.success = emitter.get_meta("watcher").watching[event].emit_count == times
	self.expected = passed
	self.result = passed if self.success else failed
