extends Object
class_name SignalManager

# Declare every signal used across the application here. This will be used by
# the EventBus class that needs to know about every possible events in advance.
# Alphabetically ordered

signal template_requested
signal generation_requested
signal purge_requested


func call_emit_signal(args):
	callv("emit_signal", args)
