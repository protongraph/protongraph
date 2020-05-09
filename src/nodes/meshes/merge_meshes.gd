tool
extends ConceptNode

"""
Combine all meshes into one
"""


func _init() -> void:
	unique_id = "merge_meshes"
	display_name = "Merge meshes"
	category = "Meshes"
	description = "Combine all the MeshInstances into a single one"

	set_input(0, "Meshes", ConceptGraphDataType.MESH)
	set_output(0, "", ConceptGraphDataType.MESH)


func _generate_outputs() -> void:
	var mesh_instances := get_input(0)
	if not mesh_instances or mesh_instances.size() <= 1:
		return

	var array_mesh = ArrayMesh.new()
	for instance in mesh_instances:
		if not instance is MeshInstance:
			continue

		var mesh: Mesh = instance.mesh
		var surface_count = mesh.get_surface_count()

		for i in surface_count:
			var arrays = mesh.surface_get_arrays(i)
			var length = arrays[ArrayMesh.ARRAY_VERTEX].size()

			for j in length:
				var pos: Vector3 = arrays[ArrayMesh.ARRAY_VERTEX][j]
				pos = instance.transform.xform(pos)
				arrays[ArrayMesh.ARRAY_VERTEX][j] = pos

			array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var instance = MeshInstance.new()
	instance.mesh = array_mesh
	output[0] = instance

