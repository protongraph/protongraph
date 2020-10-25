class_name Signals


static func safe_connect(source: Object, signal_name: String, target: Object, func_name: String, binds := [], flags := 0):
	if not source or not target:
		return

	if not source.is_connected(signal_name, target, func_name):
		var err := source.connect(signal_name, target, func_name, binds, flags)
		if err != OK:
			print("Could not connect ", signal_name, " from ", source, " on ", target, ".", func_name, " - Code ", err)


static func safe_disconnect(source: Object, signal_name: String, target: Object, func_name: String):
	if not source or not target:
		return

	if source.is_connected(signal_name, target, func_name):
		source.disconnect(signal_name, target, func_name)
