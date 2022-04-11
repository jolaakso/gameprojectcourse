extends StaticBody

# Must be powers of 2
var length = 16
var width = 16
var height = 16

var blocks: BlockData
var blocks_diff: BlockData

func _ready():
	blocks = BlockData.new(length, width, height)
	blocks_diff = BlockData.new(length, width, height, 255)
	refresh_blocks()

func place_block(block_type, global_loc, normal):
	var local_coords = to_local(global_loc)
	print_debug(local_coords)
	
	#change_block(block_type, [local_coords.x, local_coords.y, local_coords.z])
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
