extends Node


var _server: IPCServer
var _node_serializer: NodeSerializer
var librdkafka

func _init():
	librdkafka = load("res://native/thirdparty/librdkafka/librdkafka.gdns").new()
	# If you'd like to test producing to Kafka, try this:
	# librdkafka.produce("look at me i'm writing to kafka")

func _ready():
	if not _node_serializer:
		_node_serializer = NodeSerializer.new()

	_start_server()
	GlobalEventBus.register_listener(self, "remote_build_completed", "_on_remote_build_completed")


func _start_server() -> void:
	if not _server:
		_server = IPCServer.new()
		add_child(_server)
		Signals.safe_connect(_server, "data_received", self, "_on_data_received")

	_server.start()


func _on_data_received(id: int , data: Dictionary) -> void:
	if not data.has("command"):
		return

	match data["command"]:
		"build":
			_on_remote_build_requested(id, data)

# Input msg for the fence.tpgn graph will take the following form:
# {
# 	command:build, 
# 	inputs: [{
# 		node: [{
# 			data: {
# 				points: [
# 					{ in:[0, 0, 0], out:[0, 0, 0], pos:[-4.35923, 0, -3.58755], tilt:0 }, 
# 					{ in:[-3.83067, -0.005032, -0.890189], out:[3.83067, 0.005032, 0.890189], pos:[1.26936, 0.002264, -4.18087], tilt:0 }, 
# 					{ in:[0.210581, 0, -1.57824], out:[-0.210581, 0, 1.57824], pos:[5.66448, 0, 1.26848], tilt:0 },
# 					{ in:[0, 0, 0], out:[0, 0, 0], pos:[4.15667, 0, 4.50781], tilt:0 }
# 				], 
# 				transform: {
# 					basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], 
# 					pos:[0, 0, 0]
# 				}
# 			}, 
# 			name:Path,
#			node_path_input:{Path:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/Path}
# 			type:curve_3d
# 		},
# 		{
# 			children:[{
# 				children:[{
# 					data:{
# 						mesh:{
# 							0:[[[ ... ]], Null, Null, Null, [ ... ]] /// (see below)
# 						},
# 						resource_path:res://assets/fences/models/fence_planks.glb::2,
# 						transform:{
# 							basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]],
# 							pos:[0, -0.05, 0]
# 						}
# 					},
# 					name:fence_planks,
#					node_path_input:{fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent/fence_planks}
# 					type:mesh
# 				}],
# 				data: {
# 					transform: {
# 						basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], pos:[0, 0, 0]
# 					}
# 				},
# 				name:tmpParent,
#				node_path_input:{tmpParent:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent}
# 				type:node_3d
# 			}],
# 			data: {
# 				transform: {
# 					basis:[[1, 0, 0], [0, 1, 0], [0, 0, 1]], pos:[0, 0, 0]
# 				}
# 			},
# 			name:fence_planks,
#			node_path_input:{fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks}
# 			type:node_3d
# 		}], 
# 		resources:[{
#			name:Path, 
#			node_path_input:{
#				Path:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/Path
#			}
#		}, 
#		{
#			children:[{
#				children:[{
#					name:fence_planks, 
#					node_path_input:{
#						fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent/fence_planks
#					}
#				}],
#				name:tmpParent,
#				node_path_input:{
#					tmpParent:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks/tmpParent
#				}
#			}],
#			name:fence_planks,
#			node_path_input:{
#				fence_planks:/root/EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@629/@@630/@@639/@@640/@@6275/@@6109/@@6110/@@6111/@@6112/@@6113/TestProtongraph/Fence/Inputs/fence_planks
#			}
#		}]
# 	}],
# 	inspector:[],
# 	path:/Users/Chris/code/token-cjg/TestProtongraphProject/templates/fence.tpgn
# }
#
#
# Where 0:[[[ ... ]], []] takes the form of an array of points, where each point is an array of 3 floats, tupled with a list of numbers,
# as well as several optional values.
func _on_remote_build_requested(id, msg: Dictionary) -> void:
	print("[IPC] Remote build requested")
	if not msg.has("path"):
		return

	var path: String = msg["path"]
	var inspector: Array = msg["inspector"] if msg.has("inspector") else null
	var generator_payload_data_array := []
	var generator_resources_data_array := []
	if msg.has("inputs"): # actually the generator payload of form [{ "node": [{inputs}], "resources": {}}]
		for generator_payload_data in msg["inputs"]: # of form { "node": [{inputs}], "resources": {}}
			generator_payload_data_array.append(_node_serializer.deserialize(generator_payload_data))
	generator_resources_data_array.append(_node_serializer._resources)
	var args := {
		"inspector": inspector,
		"generator_payload_data_array": generator_payload_data_array,
		"generator_resources_data_array": generator_resources_data_array
	}
	GlobalEventBus.dispatch("build_for_remote", [id, path, args])


func _on_remote_build_completed(id, data: Array) -> void:
	var msg = {"type": "build_completed"}
	msg["data"] = _node_serializer.serialize(data)
	# Based on whether Protongraph is operating in Kafka mode or not,
	# either respond to the request via the WebSocket / IPC Server connection or
	# produce a message on the configured Kafka topic.
	#
	# We determine whether Protongraph is operating in Kafka mode by checking
	# for the existence of kafka.config being set during object instantiation.
	#
	# In the case for osx, the kafka.config and secrets will sit within the app bundle
	# and be moved there during the Make process.
	if librdkafka.has_config():
		print("Kafka config found, producing to specified topic on Kafka broker.")
		librdkafka.produce(msg)
	else:
		print("Kafka config not found, falling back to default responder mode.")
		_server.send(id, msg)
