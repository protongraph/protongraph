extends "../base.gd"


func _init(emitter, _signal: String, context: String) -> void:
	self.context = context
	self.success = emitter.get_meta("watcher").watching[_signal].emit_count <= 0
	self.result = "Signal: %s was %s emitted from %s" % [_signal, ("not" if self.success else ""), emitter]
