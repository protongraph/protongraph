"""
Define the constants used when setting up the GraphNodes slots type. Each of these values should
have an associated color in the COLORS dictionnary.
"""

class_name ConceptGraphDataType
extends Node


const BOOLEAN = 0
const SCALAR = 1
const VECTOR = 2
const TRANSFORM = 3
const NODE = 4
const CURVE = 5
const NOISE = 6

# Common types also used in the VisualShader editor share the same color
const COLORS = {
	BOOLEAN: Color("8ca6f4"),
	SCALAR: Color("61d9f5"),
	VECTOR: Color("d67ded"),
	TRANSFORM: Color("f6a868"),
	NODE: Color.crimson,
	CURVE: Color.yellowgreen,
	NOISE: Color.darkcyan
}
