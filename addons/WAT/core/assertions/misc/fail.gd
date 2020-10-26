extends "../base.gd"

func _init(context: String) -> void:
	# Intentionally Fails Test
	var failed: String = "Test Not Implemented"
	self.context = context
	self.success = false
	self.expected = "N/A"
	self.result = "N/A"
