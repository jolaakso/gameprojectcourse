extends Spatial

var decider: BlockDecider = BlockDecider.new()

signal chunk_entered(x, y, z)

func _ready():
	var chunk = get_node("BlockyChunk")
	var boundary_volume = get_node("ChunkBoundary/CollisionCube")
	boundary_volume.scale.x *= chunk.length
	boundary_volume.scale.y *= chunk.height
	boundary_volume.scale.z *= chunk.width

func get_chunk_dimensions():
	var chunk = get_node("BlockyChunk")
	return [chunk.length, chunk.height, chunk.width]

func set_chunk_coordinates(coordinates):
	get_node("BlockyChunk").chunk_coordinates = coordinates

func get_chunk_coordinates():
	return get_node("BlockyChunk").chunk_coordinates

# Intended to be overwritten
func get_block_type(x, y, z):
	return decider.get_block_type(x, y, z)

func set_block_decider(decider: BlockDecider):
	self.decider = decider

func set_block_diff(diff: BlockData):
	get_node("BlockyChunk").blocks_diff(diff)

func get_chunk():
	return get_node("BlockyChunk")

func generate():
	var chunk = get_node("BlockyChunk")
	for x in range(chunk.length):
		for y in range(chunk.height):
			for z in range(chunk.width):
				var block_type = get_block_type(x, y, z)
				chunk.set_block(block_type, [x, y, z])
	chunk.apply_diff()
	chunk.refresh_blocks()
	# if not set, will not pick up when player entered chunk
	get_node("ChunkBoundary").monitoring = true

func _on_ChunkBoundary_body_entered(body):
	var chunk_coordinates = get_node("BlockyChunk").chunk_coordinates
	print(chunk_coordinates)
	emit_signal("chunk_entered", chunk_coordinates[0], chunk_coordinates[1], chunk_coordinates[2])
