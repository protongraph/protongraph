tool
extends ConceptNode

class_name ConceptNodeNetwork

"""
This class stores multiple ConceptNodes and their connections. Each ConceptGraph object holds a
ConceptNodeNetwork to store its internal state. Networks are also passed to the EditorView for
edition and visualization. Since a Network is also a ConceptNode itself, it can hold sub Network
that can be used for grouping nodes together for easier edition.
A ConceptNodeNetwork always ends with an Output node which return a tree of generated nodes.
"""


var _output: ConceptNodeOutput


func get_name() -> String:
	return "Network"


func get_category() -> String:
	return "Base"


func get_description() -> String:
	return "A collection of ConceptNodes and their connections"
