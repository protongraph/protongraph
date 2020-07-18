extends Node
class_name Signals


static func safe_connect(source: Object, signal_name: String, dest: Object, func_name: String, binds := [], flags := 0):
	if not source or not dest:
		return

	if not source.is_connected(signal_name, dest, func_name):
		var err := source.connect(signal_name, dest, func_name, binds, flags)
		if err != OK:
			print("Could not connect ", signal_name, " from ", source, " on ", dest, ".", func_name, " - Code ", err)

