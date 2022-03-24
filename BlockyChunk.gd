extends Spatial

# Must be powers of 2
var length = 16
var width = 16
var height = 16

var blocks_amount = length * width * height

var blocks: Array

func _ready():
	for i in range(blocks_amount):
		if i % 2 == 0:
		  blocks.append(0)
		else:
		  blocks.append(1)
	refresh_blocks()

func refresh_blocks():
	var blocks_mesher = get_node("BlocksMesher")
	for i in range(blocks_amount):
		if blocks[i] == 1:
			blocks_mesher.set_block(i, index_to_coords(i))

func index_to_coords(ix: int) -> Array:
	var x = ix % length
	var y = (ix / length) % width
	var z = ix / (width * length)
	
	return [x, y, z]

func coords_to_index(coords: Array) -> int:
	var x = coords[0]
	var y = coords[1]
	var z = coords[2]
	return z * width * length + y * length + x
