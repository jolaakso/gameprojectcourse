class_name BlockData
extends Reference

# Must be powers of 2
var length
var width
var height

var blocks_amount

var blocks: PoolByteArray

var UNTOUCHED = 255

func is_untouched():
	for byte in blocks:
		if byte != UNTOUCHED:
			return false
	return true

func serialize():
	return Marshalls.raw_to_base64(blocks)

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
	blocks.set(coords_to_index(coords[0], coords[1], coords[2]), type)

func set_block_at_index_to(type, ix: int):
	blocks.set(ix, type)

func at_index(ix: int):
	return blocks[ix]

func at_coords(x: int, y: int, z: int):
	return blocks[coords_to_index(x, y, z)]

func neighborhood_at(x, y, z) -> Array:
	var neighborhood = PoolByteArray()
	neighborhood.resize(6)
	
	if x != 0:
		neighborhood.set(0, at_coords(x-1, y, z))
	else:
		neighborhood.set(0, 255)

	if x != length-1:
		neighborhood.set(1, at_coords(x+1, y, z))
	else:
		neighborhood.set(1, 255)
	
	if y != 0:
		neighborhood.set(2, at_coords(x, y-1, z))
	else:
		neighborhood.set(2, 255)

	if y != height-1:
		neighborhood.set(3, at_coords(x, y+1, z))
	else:
		neighborhood.set(3, 255)

	if z != 0:
		neighborhood.set(4, at_coords(x, y, z-1))
	else:
		neighborhood.set(4, 255)

	if z != width-1:
		neighborhood.set(5, at_coords(x-1, y, z+1))
	else:
		neighborhood.set(5, 255)

	return neighborhood

func merge(diff: BlockData):
	for i in range(blocks.size()):
		if diff.at_index(i) != UNTOUCHED:
			set_block_at_index_to(diff.at_index(i), i)

func index_to_coords(ix: int) -> Array:
	var x = ix % length
	var y = (ix / length) % width
	var z = ix / (width * length)
	
	return [x, y, z]

func coords_to_index(x: int, y: int, z: int) -> int:
	return z * width * length + y * length + x

func set_data(blocks_data: PoolByteArray):
	if blocks_data.size() == blocks.size():
		for i in range(blocks_data.size()):
			blocks.set(i, blocks_data[i])
