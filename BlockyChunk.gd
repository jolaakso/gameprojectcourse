extends StaticBody

# Must be powers of 2
var length = 16
var width = 16
var height = 16

var blocks: BlockData

func _ready():
	blocks = BlockData.new(length, width, height)
	refresh_blocks()

func set_block(block_type, coords: Array):
	blocks.set_block_to(block_type, coords)

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
