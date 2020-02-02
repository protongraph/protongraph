extends Node

class_name ConceptGraphDataType

"""
These constants are used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the ConceptGraphColor class.

Nodes that want to enforce a single instance or an array to their input can use the associated
_SINGLE or _ARRAY constant. If it's not explicitely stated, it is assumed that the node can handle
both arrays and single instances. 
"""


const NODE = 0
const NODE_SINGLE = 1
const NODE_ARRAY = 2

const TRANSFORM = 3
const TRANSFORM_SINGLE = 4
const TRANSFORM_ARRAY = 5

const CURVE = 6
const CURVE_SINGLE = 7
const CURVE_ARRAY = 8

const NUMBER = 9
const NUMBER_SINGLE = 10
const NUMBER_ARRAY = 11


# TODO : Test this a bit more but it seems there's a bug in how this is calculated, parameters 
# are in reverse order to make it work and it only works when connection a right to left slot
# but doesn't work the other way around. Or maybe I'm doing it wrong.
static func setup_valid_connections(graph: GraphEdit) -> void:
	graph.add_valid_connection_type(NODE, NODE_SINGLE)
	graph.add_valid_connection_type(NODE, NODE_ARRAY)
	
	graph.add_valid_connection_type(TRANSFORM_SINGLE, TRANSFORM)
	graph.add_valid_connection_type(TRANSFORM_ARRAY, TRANSFORM)
	
	graph.add_valid_connection_type(CURVE_SINGLE, CURVE)
	graph.add_valid_connection_type(CURVE_ARRAY, CURVE)
	
	graph.add_valid_connection_type(NUMBER_SINGLE, NUMBER)
	graph.add_valid_connection_type(NUMBER_ARRAY, NUMBER)
