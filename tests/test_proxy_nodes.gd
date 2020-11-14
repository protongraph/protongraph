extends WAT.Test

# Proxy nodes are utility nodes linking one part of the graph to another
# branch, usually far appart but still within the same Template.
# ProxyIn takes anything in input, and exposes it to ProxyOut.
# Proxies are named and that how they find each others.


var template: Template
var proxy_in: ProtonNode
var proxy_out: ProtonNode


func pre():
	template = Template.new()
	add_child(template)

	proxy_in = template.create_node("proxy_in")
	proxy_out = template.create_node("proxy_out")
	
	proxy_in.set_default_gui_value(1, "proxy_name")
	proxy_out.set_default_gui_value(0, "proxy_name")


func post():
	template.clear_editor()
	template.queue_free()


func test_should_mirror_slot_type() -> void:
	describe("ProxyOut should mirror the input type of ProxyIn")
	
	# Get the default type, make sure they match.
	var source_type = get_input_type(proxy_in)
	var output_type = get_output_type(proxy_out)
	
	asserts.is_not_equal(source_type, -1, "ProxyIn has a valid type")
	asserts.is_not_equal(output_type, -1, "ProxyOut has a valid type")
	asserts.is_equal(source_type, output_type, "Proxy In and Out matches")
	
	# Create a new node, make sure it has a different type.
	var input_node = template.create_node("create_cube_primitive")
	var input_type = input_node.get_output_type(0)
	asserts.is_not_equal(input_type, source_type, "New node has a different type")
	
	# Connect the new node to the ProxyIn, make sure the changes propagated.
	template._on_connection_request(input_node.name, 0, proxy_in.name, 0)
	
	source_type = get_input_type(proxy_in)
	output_type = get_output_type(proxy_out)
	
	asserts.is_equal(input_type, source_type, "Connected node type matches ProxyIn type")
	asserts.is_equal(source_type, output_type, "Proxy In and Out matches")


func test_should_reset_proxy_out_automaically() -> void:
	describe("When ProxyIn is reset, ProxyOut should be reset too")
	
	# Create an input node and connect it to ProxyIn
	var input_value := 42
	var input_node = template.create_node("value_scalar")
	input_node.set_default_gui_value(0, input_value)
	template._on_connection_request(input_node.name, 0, proxy_in.name, 0)

	var final_result = proxy_out.get_output_single(0, -1)
	asserts.is_equal(final_result, input_value, "Initial input value was propagated to ProxyOut")
	
	var new_value := 24
	input_node.set_default_gui_value(0, 24)
	final_result = proxy_out.get_output_single(0, -1)
	
	asserts.is_not_equal(input_value, new_value, "New assigned value is different from the old one")
	asserts.is_equal(final_result, new_value, "New value was propagated to the ProxyOut")


func get_input_type(node: ProtonNode) -> int:
	if node.is_input_connected(0):
		return node.get_connected_input_type(0)
	return node.get_local_input_type(0)


func get_output_type(node: ProtonNode) -> int:
	return node.get_output_type(0)
