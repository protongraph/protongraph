tool
extends ConceptNode

"""
Create plane mesh from transforms
"""


func _init() -> void:
	unique_id = "plane_mesh_from_transforms"
	display_name = "Create Plane Mesh from Transforms"
	category = "Generators/Meshes"
	description = "Creates a plane mesh from a grid of transforms"

	set_input(0, "Nodes", ConceptGraphDataType.NODE_3D)
	set_input(1, "Use collision", ConceptGraphDataType.BOOLEAN)
	set_input(2, "Wireframe", ConceptGraphDataType.BOOLEAN)
	set_output(0, "", ConceptGraphDataType.MESH_3D)
	ConceptGraphDataType.NODE_2D


func _generate_outputs() -> void:
	var nodes := get_input(0)
	var use_collision = get_input_single(1)
	var wireframes = get_input_single(2)

	var verts_total = nodes.size()
	var verts_side = int(sqrt(verts_total))
	var indices_total = (verts_side-1) * (verts_side-1) * 6

	var verts   = PoolVector3Array()
#	var points  = PoolVector2Array()
	var indices = PoolIntArray()
	var normals = PoolVector3Array()
	var uvs     = PoolVector2Array()

	verts.resize(verts_total)
	indices.resize(indices_total)
#	points.resize(verts_total)
	normals.resize(verts_total)
	uvs.resize(verts_total)

	var x
	var z
	var i = 0
	var j = 0
	var pos: Vector3

	for node in nodes:
		x = i % verts_side
		z = i / verts_side
		pos = node.translation
		verts[i] = pos
#		points[i] = Vector2(Vector2(pos.x, pos.z))
		uvs[i] = Vector2(z / float(verts_side), x / float(verts_side))
		if x and z:
			indices[j]   = i-verts_side
			indices[j+1] = i-verts_side-1
			indices[j+2] = i
			indices[j+3] = i-verts_side-1
			indices[j+4] = i-1
			indices[j+5] = i
			j += 6
		i += 1

#	var indices = Geometry.triangulate_delaunay_2d(points)
#	indices.invert()

	# calculate the normal for each triangle
	# add it to each of the triangles vertex normals
	for k in indices.size() / 3:
		var i1 = indices[k * 3]
		var i2 = indices[k * 3 + 1]
		var i3 = indices[k * 3 + 2]
		var a = verts[i1]
		var b = verts[i2]
		var c = verts[i3]
		var n = (c - a).cross(b - a)
		normals[i1] += n
		normals[i2] += n
		normals[i3] += n

	# then normalize the blended normals of each vertex
	for k in verts_total:
		normals[k] = normals[k].normalized()

	var arrays = Array()
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	arrays[Mesh.ARRAY_INDEX] = indices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
#	arrays[Mesh.ARRAY_TEX_UV2] = uvs

	var array_mesh = ArrayMesh.new()

	if wireframes:
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	else:
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var instance = MeshInstance.new()
	instance.mesh = array_mesh

	output[0].append(instance)
	if use_collision:
		var body = StaticBody.new()
		var colshape = CollisionShape.new()
		colshape.shape = array_mesh.create_trimesh_shape()
		body.add_child(colshape)
		body.hide()
		output[0].append(body)

