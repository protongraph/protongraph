class_name MeshUtil
extends RefCounted


# Merge every surfaces found in every MeshInstance into a single mesh.
static func merge_mesh_surfaces(mesh_instances: Array[MeshInstance3D]) -> MeshInstance3D:
	var surface_tool := SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for mi in mesh_instances:
		if is_instance_valid(mi):
			var mesh : Mesh = mi.mesh
			for surface_i in mesh.get_surface_count():
				surface_tool.append_from(mesh, surface_i, mi.transform)

	var instance = MeshInstance3D.new()
	instance.mesh = ProtonMesh.create_from_arrays(surface_tool.commit_to_arrays())
	return instance


static func extrude_mesh(mesh_instance: MeshInstance3D) -> MeshInstance3D:
	var mesh: ProtonMesh = mesh_instance.mesh
	if not mesh:
		return null

	for surface_index in mesh.get_surface_count():
		var data_tool := MeshDataTool.new()
		data_tool.create_from_surface(mesh, surface_index)

		# Get mesh boundaries
		var boundaries: Array[int] = []

		# Duplicate triangles



	var extruded_mesh := MeshInstance3D.new()
	extruded_mesh.global_transform = mesh_instance.global_transform
	extruded_mesh.mesh = ProtonMesh.create_from_array_mesh(mesh)
	return extruded_mesh
