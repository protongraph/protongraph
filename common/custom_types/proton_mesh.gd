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
