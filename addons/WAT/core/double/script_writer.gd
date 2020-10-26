extends Reference


func write(double) -> String:
	var source: String = ""
	source += _extension_to_string(double)
	
	if double.base_methods.has("_init"):
		source += _constructor_to_string(double.base_methods["_init"])

	for name in double.methods:
		var m = double.methods[name]
		source += _method_to_string(double.get_instance_id(), m)
	for klass in double.klasses:
		source += _inner_class(klass)
	source = source.replace(",)", ")")
	return source
	
func _extension_to_string(double) -> String:
	if double.is_built_in:
		return 'extends %s' % double.klass
	if double.inner_klass != "":
		return 'extends "%s".%s\n' % [double.klass, double.inner_klass]
	return 'extends "%s"\n' % double.klass
	
func _constructor_to_string(parameters: String) -> String:
	var constructor: String = ""
	constructor += "\nfunc _init(%s).(%s):" % [parameters, parameters]
	constructor += "\n\tpass\n"
	return constructor

func _method_to_string(id: int, method: Object) -> String:
	var text: String
	text += "{keyword}func {name}({args}):"
	text += "\n\tvar args = [{args}]"
	text += "\n\tvar method = ProjectSettings.get_setting('WAT/TestDouble').method({id}, '{name}')"
	text += "\n\tmethod.add_call(args)"
	text += "\n\tif method.executes(args):"
	text += "\n\t\treturn .{name}({args})"  # We may want to add a retval check here
	text += "\n\treturn method.primary(args)\n\n"
	text = text.format({"id": id, "keyword": method.keyword, 
	                    "name": method.name, "args": method.args})
	return text

func _inner_class(klass: Dictionary) -> String:
	return "\nclass %s extends '%s'.%s:\n\tconst PLACEHOLDER = 0" % [klass.name, klass.director.klass, klass.name]
