extends Node

# Autoload
# Parses the command line arguments passed when this project was started.
# Stores everything in a dictionnary for later access without have to parse
# everything again.

var _args = {}


func _ready():
	for arg in OS.get_cmdline_args():
		if arg.find("=") > -1:
			var tokens = arg.split("=")
			var key: String = tokens[0].lstrip("--")
			var value: String = tokens[1]
			
			if value.is_valid_integer():
				_args[key] = value.to_int()
			elif value.is_valid_float():
				_args[key] = value.to_float()
			else:
				_args[key] = value


func get_arg(arg_name: String):
	if _args.has(arg_name):
		return _args[arg_name]
	return null
