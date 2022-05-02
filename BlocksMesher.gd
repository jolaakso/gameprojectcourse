extends MeshInstance

func refresh_mesh(blocks: BlockData) -> void:
	var block_dict = mesh_blocks(blocks)
	var array_mesh = ArrayMesh.new()
	var block_types = block_dict.keys()

	for block_type in block_types:
		var block_vertices = PoolVector3Array(block_dict[block_type].vertices)
		var block_normals = PoolVector3Array(block_dict[block_type].normals)
		var block_uvs = PoolVector2Array(block_dict[block_type].uvs)
	
		if block_vertices.size() == 0:
			return

		var mesh_data = []
		mesh_data.resize(array_mesh.ARRAY_MAX)
		mesh_data[array_mesh.ARRAY_VERTEX] = block_vertices
		mesh_data[array_mesh.ARRAY_NORMAL] = block_normals
		mesh_data[array_mesh.ARRAY_TEX_UV] = block_uvs
	
		array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	var materials = MaterialsList.materials
	var materials_amount = materials.size()
	for i in range(block_types.size()):
		array_mesh.surface_set_material(i, materials[(block_types[i] - 1) % materials_amount])

	mesh = array_mesh

func mesh_blocks(blocks: BlockData) -> Dictionary:
	var mesh_by_types = {}
	
	for x in range(blocks.length):
		for y in range(blocks.height):
			for z in range(blocks.width):
				var block_mesh = mesh_single_block(blocks, x, y, z)
				var type = block_mesh.block_type
				
				if type != 0 && !mesh_by_types.has(block_mesh.block_type):
					mesh_by_types[type] = {
						vertices = [],
						normals = [],
						uvs = []
					}
				
				for vert in block_mesh.verts:
					mesh_by_types[type].vertices.push_back(vert)
				for normal in block_mesh.normals:
					mesh_by_types[type].normals.push_back(normal)
				for uv in block_mesh.uvs:
					mesh_by_types[type].uvs.push_back(uv)
	return mesh_by_types

func mesh_single_block(blocks, x, y, z) -> Dictionary:
	var this_block_type = blocks.at_coords(x, y, z)
	if this_block_type == 0:
		return { verts = [], normals = [], uvs = [], block_type = 0 }
	var coords_vec = Vector3(x, y, z)
	# Create a copy
	var cube_model = Cube.new()
	var cube_verts = []
	var cube_normals = []
	var cube_uvs = []
	
	if z == blocks.width - 1 || this_block_type != blocks.at_coords(x, y, z+1):
		cube_verts.append_array(cube_model.BACK_FACE)
		cube_normals.append_array(cube_model.BACK_NORMALS)
		cube_uvs.append_array(cube_model.BACK_UVS)

	if z == 0 || this_block_type != blocks.at_coords(x, y, z-1):
		cube_verts.append_array(cube_model.FRONT_FACE)
		cube_normals.append_array(cube_model.FRONT_NORMALS)
		cube_uvs.append_array(cube_model.FRONT_UVS)
	
	if y == blocks.height - 1 || this_block_type != blocks.at_coords(x, y+1, z):
		cube_verts.append_array(cube_model.UP_FACE)
		cube_normals.append_array(cube_model.UP_NORMALS)
		cube_uvs.append_array(cube_model.UP_UVS)

	if y == 0 || this_block_type != blocks.at_coords(x, y-1, z):
		cube_verts.append_array(cube_model.DOWN_FACE)
		cube_normals.append_array(cube_model.DOWN_NORMALS)
		cube_uvs.append_array(cube_model.DOWN_UVS)

	if x == blocks.length - 1 || this_block_type != blocks.at_coords(x+1, y, z):
		cube_verts.append_array(cube_model.RIGHT_FACE)
		cube_normals.append_array(cube_model.RIGHT_NORMALS)
		cube_uvs.append_array(cube_model.RIGHT_UVS)

	if x == 0 || this_block_type != blocks.at_coords(x-1, y, z):
		cube_verts.append_array(cube_model.LEFT_FACE)
		cube_normals.append_array(cube_model.LEFT_NORMALS)
		cube_uvs.append_array(cube_model.LEFT_UVS)

	for i in range(0, cube_verts.size()):
		cube_verts[i] += coords_vec
	return { verts = cube_verts, normals = cube_normals, uvs = cube_uvs, block_type = this_block_type }
