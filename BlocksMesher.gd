extends MeshInstance

func refresh_mesh(blocks: BlockData) -> void:
	var block_dict = mesh_blocks(blocks)
	var block_vertices = block_dict.vertices
	var block_normals = block_dict.normals
	
	if block_vertices.size() == 0:
		return
	
	var array_mesh = ArrayMesh.new()
	var mesh_data = []
	mesh_data.resize(array_mesh.ARRAY_MAX)
	mesh_data[array_mesh.ARRAY_VERTEX] = block_vertices
	mesh_data[array_mesh.ARRAY_NORMAL] = block_normals
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	mesh = array_mesh

func mesh_blocks(blocks: BlockData) -> Dictionary:
	var vertices = PoolVector3Array()
	var normals = PoolVector3Array()
	
	for x in range(blocks.length):
		for y in range(blocks.height):
			for z in range(blocks.width):
				var block_mesh = mesh_single_block(blocks, x, y, z)
				for vert in block_mesh.verts:
					vertices.push_back(vert)
				for normal in block_mesh.normals:
					normals.push_back(normal)
	return { vertices = vertices, normals = normals }

func mesh_single_block(blocks, x, y, z) -> Dictionary:
	var this_block_type = blocks.at_coords(x, y, z)
	if this_block_type == 0:
		return { verts = [], normals = [] }
	var coords_vec = Vector3(x, y, z)
	# Create a copy
	var cube_model = Cube.new()
	var cube_verts = []
	var cube_normals = []
	
	if z == blocks.width - 1 || this_block_type != blocks.at_coords(x, y, z+1):
		cube_verts.append_array(cube_model.BACK_FACE)
		cube_normals.append_array(cube_model.BACK_NORMALS)

	if z == 0 || this_block_type != blocks.at_coords(x, y, z-1):
		cube_verts.append_array(cube_model.FRONT_FACE)
		cube_normals.append_array(cube_model.FRONT_NORMALS)
	
	if y == blocks.height - 1 || this_block_type != blocks.at_coords(x, y+1, z):
		cube_verts.append_array(cube_model.UP_FACE)
		cube_normals.append_array(cube_model.UP_NORMALS)

	if y == 0 || this_block_type != blocks.at_coords(x, y-1, z):
		cube_verts.append_array(cube_model.DOWN_FACE)
		cube_normals.append_array(cube_model.DOWN_NORMALS)

	if x == blocks.length - 1 || this_block_type != blocks.at_coords(x+1, y, z):
		cube_verts.append_array(cube_model.RIGHT_FACE)
		cube_normals.append_array(cube_model.RIGHT_NORMALS)

	if x == 0 || this_block_type != blocks.at_coords(x-1, y, z):
		cube_verts.append_array(cube_model.LEFT_FACE)
		cube_normals.append_array(cube_model.LEFT_NORMALS)

	for i in range(0, cube_verts.size()):
		cube_verts[i] += coords_vec
	return { verts = cube_verts, normals = cube_normals }
