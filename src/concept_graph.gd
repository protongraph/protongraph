tool
extends Spatial

class_name ConceptGraph

"""
The main class of this plugin.
When adding a ConceptGraph to a scene, you can access and edit its internal network for the editor.
This node then travel through the ConceptGraphNetwork to generate content on the fly.
"""

var network: ConceptNodeNetwork


func generate() -> void:
	pass


