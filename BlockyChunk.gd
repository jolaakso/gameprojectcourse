extends StaticBody

# Must be powers of 2
var length = 16
var width = 16
var height = 16

var blocks: BlockData
var blocks_diff: BlockData

var chunk_coordinates

func _ready():
	blocks = BlockData.new(length, width, height)
	blocks_diff = BlockData.new(length, width, height, 255)
	refresh_blocks()

func is_empty(x, y, z):
	return blocks.at_coords(x, y, z) == 0

func get_chunk_coords_pointed(global_loc, normal):
	print(global_loc)
	var local_coords = to_local(global_loc).floor()
	# Global_loc comes from raycasting, there is a problem when normal is in
	# the positive half space, flooring the local coords gives *the adjacent*
	# block, not the pointed
	if normal.dot(Vector3.ONE) > 0:
		local_coords -= normal
	var chunk_coords = [int(local_coords[0]) / length + chunk_coordinates[0],
						int(local_coords[1]) / height + chunk_coordinates[1],
						int(local_coords[2]) / width + chunk_coordinates[2]]
	var adjacent_local_coords_vec = local_coords.posmodv(Vector3(length, height, width))
	var adjacent_local_coords = [int(adjacent_local_coords_vec.x),
								 int(adjacent_local_coords_vec.y),
								 int(adjacent_local_coords_vec.z)]

	return { chunk = chunk_coords, local_coords = adjacent_local_coords }

func get_chunk_coords_adjacent(global_loc, normal):
	var local_coords = to_local(global_loc).floor()
	# Global_loc comes from raycasting, there is a problem when normal is in
	# the negative half space, flooring the local coords gives *the pointed*
	# block, not the adjacent
	if normal.dot(Vector3.ONE) < 0:
		local_coords += normal
	var chunk_coords = [int(local_coords[0]) / length + chunk_coordinates[0],
						int(local_coords[1]) / height + chunk_coordinates[1],
						int(local_coords[2]) / width + chunk_coordinates[2]]
	var adjacent_local_coords_vec = local_coords.posmodv(Vector3(length, height, width))
	var adjacent_local_coords = [int(adjacent_local_coords_vec.x),
								 int(adjacent_local_coords_vec.y),
								 int(adjacent_local_coords_vec.z)]

	return { chunk = chunk_coords, local_coords = adjacent_local_coords }

func place_block(block_type, coords: Array):
	if !is_empty(coords[0], coords[1], coords[2]):
		return
	change_block(block_type, coords)
	refresh_blocks()

func remove_block(coords: Array):
	print(coords)
	if is_empty(coords[0], coords[1], coords[2]):
		return
	change_block(0, coords)
	refresh_blocks()

func set_block(block_type, coords: Array):
	blocks.set_block_to(block_type, coords)

func change_block(block_type, coords: Array):
	blocks.set_block_to(block_type, coords)
	blocks_diff.set_block_to(block_type, coords)

func apply_diff():
	blocks.merge(blocks_diff)

func refresh_blocks():
	var blocks_mesher = get_node("BlocksMesher")
	blocks_mesher.refresh_mesh(blocks)
	var mesh = blocks_mesher.mesh
	if mesh:
		get_node("ChunkCollision").shape = mesh.create_trimesh_shape()

func coords_to_index(coords: Array) -> int:
	var x = coords[0]
	var y = coords[1]
	var z = coords[2]
	return z * width * length + y * length + x
