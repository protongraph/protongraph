class_name Signals
extends RefCounted

# Utility class to avoid spamming error messages in the debugger when handling
# signals. safe_connect and safe_disconnect will do the extra check before
# actually connecting or disconnecting the signals.


static func safe_connect(s: Signal, callable: Callable) -> void:
	if not s.is_connected(callable):
		s.connect(callable)


static func safe_disconnect(s: Signal, callable: Callable) -> void:
	if s.is_connected(callable):
		s.disconnect(callable)
