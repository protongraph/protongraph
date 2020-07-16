tool
extends ConceptNode

"""
Deform a mesh along a curve.
"""

# Muzz: currently this node remaps the Y axis to match the curve.
#  Todo:
# - User set initial axis
# - Flip the winding of triangles if the start and end are inverted
# - bool to lock the length? Right now it stretches the object along the entire
#  curve, but might be good to have an option lock this, post thoughts in the thread?
# - Could a scalar to project the verts out wider or less. Fairly trivial
#  hook that up to a 2d Curve as well.

func _init() -> void:
	unique_id = "deform_along_path"
	display_name = "Deform Along Curve"
	category = "Modifiers/Meshes"
	description = "Deforms a mesh's y axis along a curve."

	set_input(0, "Input mesh", ConceptGraphDataType.MESH_3D)
	set_input(1, "Path curve", ConceptGraphDataType.CURVE_3D)
	set_input(2, "Start offset", ConceptGraphDataType.SCALAR,{"min": 0, "value": 0.0})
	set_input(3, "End offset", ConceptGraphDataType.SCALAR,{"min": 0, "value": 1.0})
	set_input(4, "Tilt", ConceptGraphDataType.BOOLEAN)
	set_input(5, "Rotate", ConceptGraphDataType.SCALAR,{"min": 0, "value": 1.0})
	set_output(0, "Mesh", ConceptGraphDataType.MESH_3D)

func _generate_outputs() -> void:
	var mesh : Mesh = get_input_single(0).mesh
	var paths := get_input(1)
	var start_offset : float = get_input_single(2,0.0)
	var end_offset : float = get_input_single(3,1.0)
	var tilt: bool = get_input_single(4,false)

	# this is in radians
	var rotate_along_axis : float = get_input_single(5,0.0)

	start_offset =  clamp(start_offset, 0, 1)
	end_offset =  clamp(end_offset, 0.01, 1)

	# NOTE:
	# Primitive meshes seem to be rejected by the mesh_data_tool
	# Muzz: this code below seems to work for generated meshes, not imported meshes, so the below is here
	# for if we decide to make it work with primitive meshes

	# var temporary_mesh = ArrayMesh.new()
	# var verts = mesh.get_faces()
	# var arrays = Array()
	# arrays.resize(ArrayMesh.ARRAY_MAX)
	# arrays[ArrayMesh.ARRAY_VERTEX] = verts
	# temporary_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)

	# Muzz: would potentially be faster if I use ArrayMesh instead but the data tool
	# makes things a fair bit easier.
	var mesh_data_tool = MeshDataTool.new()
	mesh_data_tool.create_from_surface(mesh, 0)
	var rotate_angle = Vector2(cos(rotate_along_axis), sin(rotate_along_axis))

	# Muzz: this transform puts the verts into the correct axis that the next transform expects.
	var pre_transform: Transform
	var pre_look_at = Vector3(rotate_angle.x,rotate_angle.y,0)
	pre_transform = pre_transform.looking_at(pre_look_at , Vector3(0, 0, 1))

	# Muzz: if there are multiple paths, we'll duplicate the mesh for every single one.
	# Output doesn't handle this yet though.
	for path in paths:
		if path.curve.get_point_count() < 2:
			return

		# this is really buggy, this will break if up vector is not enabled
		# Will investigate how to fix.
		if not path.curve.is_up_vector_enabled():
			# this can't work if this is off, so we just disable the node and print a warning.
			print("Up vector in curve must be enabled for mesh deform node.")
			return

		var curve: Curve3D = path.curve
		var length: float = curve.get_baked_length()
		var vertex_count = mesh_data_tool.get_vertex_count()

		var min_mesh_height = -1000000
		var max_mesh_height = 1000000

		# Muzz: find the highest and lowest parts of the mesh, so we can stretch between.
		# floating vertexes will really mess this up, so be clean with your meshes.
		for i in range(vertex_count):
			var y = mesh_data_tool.get_vertex(i).y
			min_mesh_height = max(y,min_mesh_height)
			max_mesh_height = min(y,max_mesh_height)

		var offset = 0.0

		# Muzz: iterate over all the verticies, literally doesn't matter which, this is deterministic
		for i in range(vertex_count):
			var vert = mesh_data_tool.get_vertex(i)
			var normal = mesh_data_tool.get_vertex_normal(i)

			if min_mesh_height < 0:
				offset = (vert.y + min_mesh_height) / (max_mesh_height+min_mesh_height)
			else:
				offset = (vert.y - min_mesh_height) / (max_mesh_height-min_mesh_height)

			offset = range_lerp(offset,0,1,start_offset,end_offset)
			offset = offset * length
			var position_on_curve: Vector3 = curve.interpolate_baked(offset)

			# I should add a check that there is an up vector in the curve.
			var up: Vector3 = curve.interpolate_baked_up_vector (offset,tilt)
			var position_look_at: Vector3

			if offset + 0.05 < length:
				position_look_at = curve.interpolate_baked(offset + 0.05)
			else:
				position_look_at = curve.interpolate_baked(offset - 0.05)
				position_look_at += 2.0 * (position_on_curve - position_look_at)

			# Muzz: cancel out all the vertical location so that we can replace it
			# with the curves location.
			vert.y = 0

			# Muzz: the only way i could work out to do this was to rotate the verts
			# first to a preliminary position, otherwise it wouldn't be oriented correctly
			# this will have to be modified when I modify it to take different axis
			vert =  pre_transform.xform(vert)
			normal = pre_transform.xform(normal)
			var transform: Transform
			var look_at = position_look_at - position_on_curve
			transform = transform.looking_at(look_at, up)

			normal = transform.xform(normal)
			vert =  transform.xform(vert)

			mesh_data_tool.set_vertex(i,vert+position_on_curve)
			mesh_data_tool.set_vertex_normal(i,normal)

		var temporary_mesh = ArrayMesh.new()
		var arrays = Array()
		arrays.resize(ArrayMesh.ARRAY_MAX)
		mesh_data_tool.commit_to_surface(temporary_mesh)

		var mesh_instance = MeshInstance.new()
		mesh_instance.transform = path.transform
		mesh_instance.mesh = temporary_mesh

		# will need to fix this output if we want it to output a separate mesh for each path.
		output[0].append(mesh_instance)
