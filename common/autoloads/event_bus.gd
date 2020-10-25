extends Node
class_name EventBus

var listeners : Dictionary = {}
var signal_manager = SignalManager.new()


func register_listener(object, event, function_name):
	var row = {"object": object,
			"function": function_name}
	DictUtil.append_to(listeners, event, row)
	Signals.safe_connect(signal_manager, event, object, function_name)


func dispatch(event, args = []):
	if typeof(args) != TYPE_ARRAY:
		args = [args]
	signal_manager.call_emit_signal([event] + args)
