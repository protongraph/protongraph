extends "../base.gd"

func _init(emitter: Object, event: String, arguments: Array, context: String) -> void:
	var passed: String = "Signal: %s was emitted from %s with arguments: %s" % [event, emitter, arguments]
	var failed: String = "Signal: %s was not emitted from %s with arguments: %s" % [event, emitter, arguments]
	var alt_failure: String = "Signal: %s was not emitted from %s" % [event, emitter]
	self.context = context
	self.expected = passed

	var data = emitter.get_meta("watcher").watching[event]
	if data.emit_count <= 0:
		self.success = false
		self.result = alt_failure

	elif _found_matching_call(arguments, data.calls):
		self.success = true
		self.result = passed

	else:
		self.success = false
		self.result = failed

func _found_matching_call(args, calls) -> bool:
	for call in calls:
		if _match(args, call.args):
			return true
	return false

func _match(args, call_args) -> bool:
	for i in args.size():
		if args[i] != call_args[i]:
			return false
	return true
