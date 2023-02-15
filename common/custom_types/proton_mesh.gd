class_name ProtonMesh
extends ArrayMesh


# The mesh type used accross the application.
#
# Make sure every MeshInstance3D use this type of mesh intead of the
# Godot provided mesh types.
#
# TODO: Figure out how vertex attributes works in other software and replicate
# that here.

static func create_from_primitive(source: PrimitiveMesh) -> ProtonMesh:
	var arrays := source.get_mesh_arrays()
	var proton_mesh := ProtonMesh.new()
	proton_mesh.add_surface_from_arrays(PRIMITIVE_TRIANGLES, arrays)

	return proton_mesh


# Creates a single surface mesh
static func create_from_arrays(arrays) -> ProtonMesh:
	var proton_mesh := ProtonMesh.new()
	proton_mesh.add_surface_from_arrays(PRIMITIVE_TRIANGLES, arrays)

	return proton_mesh


static func create_from_array_mesh(array_mesh: ArrayMesh) -> ProtonMesh:
	var proton_mesh := ProtonMesh.new()

	for i in array_mesh.get_surface_count():
		proton_mesh.add_surface_from_arrays(PRIMITIVE_TRIANGLES, array_mesh.surface_get_arrays(i))

	return proton_mesh
