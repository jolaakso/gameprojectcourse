extends Spatial

# Intended to be overwritten
func get_block_type(x, y, z):
	return 1

func generate():
	var chunk = get_node("BlockyChunk")
	for x in range(chunk.length):
		for y in range(chunk.width):
			for z in range(chunk.height):
				var block_type = get_block_type(x, y, z)
				chunk.set_block(block_type, [x, y, z])
	chunk.refresh_blocks()
