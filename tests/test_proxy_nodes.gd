extends WAT.Test


var template: Template
var proxy_in: ConceptNode
var proxy_out: ConceptNode


func pre():
	template = Template.new()
	proxy_in = template.create_node("proxy_in")
	proxy_out = template.create_node("proxy_out")
	
	proxy_in.set_default_gui_value(0, "proxy_name")
	proxy_out.set_default_gui_value(0, "proxy_name")


func post():
	template.clear_editor()
	template.queue_free()


func test_should_mirror_slot_type() -> void:
	describe("ProxyOut should mirror the input type of ProxyIn")
	
	# Get the default type, make sure they match.
	var source_type = proxy_in.get_input_type(0)
	var output_type = proxy_out.get_output_type(0)
	
	asserts.is_not_equal(source_type, -1, "ProxyIn has a valid type")
	asserts.is_not_equal(output_type, -1, "ProxyOut has a valid type")
	asserts.is_equal(source_type, output_type, "Proxy In and Out matches")
	
	# Create a new node, make sure it has a different type.
	var input_node = template.create_node("create_cube_primitive")
	var input_type = input_node.get_output_type(0)
	asserts.is_not_equal(input_type, source_type, "New node has a different type")
	
	# Connect the new node to the ProxyIn, make sure the changes propagated.
	var err = template.connect_node(input_node.name, 0, proxy_in.name, 0)
	asserts.is_equal(err, OK, "New node successfully connected to ProxyIn")
	
	source_type = proxy_in.get_input_type(0)
	output_type = proxy_out.get_output_type(0)
	
	asserts.is_equal(input_type, source_type, "Connected node type matches ProxyIn type")
	asserts.is_equal(source_type, output_type, "Proxy In and Out matches")
