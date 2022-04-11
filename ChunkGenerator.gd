extends Spatial

var decider: BlockDecider = BlockDecider.new()

func get_chunk_dimensions():
	var chunk = get_node("BlockyChunk")
	return [chunk.length, chunk.height, chunk.width]

# Intended to be overwritten
func get_block_type(x, y, z):
	return decider.get_block_type(x, y, z)

func set_block_decider(decider: BlockDecider):
	self.decider = decider

func set_block_diff(diff: BlockData):
	get_node("BlockyChunk").blocks_diff(diff)

func generate():
	var chunk = get_node("BlockyChunk")
	for x in range(chunk.length):
		for y in range(chunk.height):
			for z in range(chunk.width):
				var block_type = get_block_type(x, y, z)
				chunk.set_block(block_type, [x, y, z])
	chunk.apply_diff()
	chunk.refresh_blocks()
