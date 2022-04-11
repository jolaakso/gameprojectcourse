class_name BlockData
extends Reference

# Must be powers of 2
var length
var width
var height

var blocks_amount

var blocks: PoolByteArray

var UNTOUCHED = 255

func _init(length = 16, width = 16, height = 16, initial_type = 0):
	self.length = length
	self.width = width
	self.height = height
	
	self.blocks_amount = length * width * height
	
	blocks = PoolByteArray()
	blocks.resize(blocks_amount)
	
	# zero out in beginning
	for i in range(blocks_amount):
		blocks.set(i, initial_type)

func set_block_to(type, coords: Array):
	blocks.set(coords_to_index(coords), type)

func set_block_at_index_to(type, ix: int):
	blocks.set(ix, type)

func at_index(ix: int):
	return blocks[ix]

func at_coords(x, y, z):
	return blocks[coords_to_index([x, y, z])]

func merge(diff: BlockData):
	for i in range(blocks.size()):
		if diff.at_index(i) != UNTOUCHED:
			set_block_at_index_to(diff.at_index(i), i)

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
