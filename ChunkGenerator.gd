extends Spatial

var decider: BlockDecider = BlockDecider.new()
var loaded = false

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

func serialize_coords():
	var chunk_location = get_chunk_coordinates()
	return "%dx%dy%dz" % [chunk_location[0], chunk_location[1], chunk_location[2]]

func generate():
	var chunk = get_node("BlockyChunk")
	var chunk_coords = chunk.chunk_coordinates
	var chunk_diff = RegionLoader.load_chunk(chunk_coords[0], chunk_coords[1], chunk_coords[2])
	if chunk_diff:
		chunk.set_diff(chunk_diff)
	for x in range(chunk.length):
		for y in range(chunk.height):
			for z in range(chunk.width):
				var block_type = get_block_type(x, y, z)
				chunk.set_block(block_type, [x, y, z])
	chunk.apply_diff()
	chunk.refresh_blocks()
	
	# If player inside chunk when it generates, teleport to last known safe
	# location to prevent player from getting stuck inside the collision mesh
	var bodies = get_node("ChunkBoundary").get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("teleport_to_last_safe"):
			body.teleport_to_last_safe()
	
	loaded = true

func save_chunk():
	var chunk = get_node("BlockyChunk")
	if !chunk.dirty:
		return
	var chunk_coords = get_chunk_coordinates()
	RegionLoader.save_chunk(serialize_coords(), chunk_coords[0], chunk_coords[1], chunk_coords[2], chunk.blocks_diff.blocks)

func unload():
	save_chunk()
	queue_free()

func _on_ChunkBoundary_body_entered(body):
	var chunk = get_node("BlockyChunk")
	if loaded:
		if body.has_method("save_last_safe"):
			body.save_last_safe()
		var chunk_coordinates = chunk.chunk_coordinates
		emit_signal("chunk_entered", chunk_coordinates[0], chunk_coordinates[1], chunk_coordinates[2])
	elif(body.has_method("teleport_to_last_safe")):
		body.teleport_to_last_safe()
