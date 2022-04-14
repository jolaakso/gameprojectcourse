extends Spatial

var box_length = 5
var box_height = 1
var box_width = 5
var generator_scene = load("res://ChunkGenerator.tscn")
var random_noise: OpenSimplexNoise = OpenSimplexNoise.new()
var chunk_worker: Thread = Thread.new()
var generator_queue: Array = []
var generator_queue_mutex: Mutex = Mutex.new()

class SpiralSorter:
	var origin
	func _init(x, y, z):
		origin = Vector3(x, y, z)
	# sorts array of arrays of 3 integers so that the ones
	# that are closer to origin are first
	func sort_spiral(a, b):
		# print_debug(origin)
		# print_debug(a)
		# print_debug(b)
		var a_dist = Vector3(a[0], a[1], a[2]).distance_squared_to(origin)
		var b_dist = Vector3(b[0], b[1], b[2]).distance_squared_to(origin)
		# print_debug(a_dist)
		# print_debug(b_dist)
		return a_dist < b_dist

func _process(_delta):
	if !chunk_worker.is_alive() && !generator_queue.empty():
		chunk_worker.wait_to_finish()
		chunk_worker = Thread.new()
		chunk_worker.start(self, "process_generation")

func place_block_in_chunk(chunk_coords, local_coords):
	var chunk_gen = get_node_or_null(serialize_chunk_name(chunk_coords))
	if !chunk_gen:
		return
	var chunk = chunk_gen.get_chunk()
	chunk.place_block(1, local_coords)

func mine_block_in_chunk(chunk_coords, local_coords):
	var chunk_gen = get_node_or_null(serialize_chunk_name(chunk_coords))
	if !chunk_gen:
		return
	var chunk = chunk_gen.get_chunk()
	chunk.remove_block(local_coords)

func previewable_global_coordinates(chunk_coords, block_coords):
	var chunk_gen = get_node_or_null(serialize_chunk_name(chunk_coords))
	if !chunk_gen:
		return null
	var chunk = chunk_gen.get_chunk()
	if !chunk || !chunk.is_empty(block_coords[0], block_coords[1], block_coords[2]):
		return null
	return chunk.to_global(Vector3(block_coords[0], block_coords[1], block_coords[2]))

func block_empty(chunk_coords, block_coords):
	var chunk = get_node_or_null(serialize_chunk_name(chunk_coords))
	if !chunk:
		return
	return chunk.is_empty(block_coords[0], block_coords[1], block_coords[2])

func queue_generation(generator):
	generator_queue_mutex.lock()
	generator_queue.append(generator)
	generator_queue_mutex.unlock()

func process_generation():
	var generator = null
	generator_queue_mutex.lock()
	if !generator_queue.empty():
		generator = generator_queue.pop_front()
	generator_queue_mutex.unlock()
	if generator != null:
		generator.generate()
		process_generation()

func set_seed(noise_seed: int):
	var noise = OpenSimplexNoise.new()
	noise.seed = noise_seed
	random_noise = noise

func box_at(x, y, z, length = box_length, height = box_height, width = box_width):
	var box_indices = []
	for i in range(x - length/2 - 1, x + length/2):
		for j in range(y - height/2 - 1, y + height/2 + 1):
			for k in range(z - width/2 - 1, z + width/2 + 1):
				box_indices.append([i, j, k])
	box_indices.sort_custom(SpiralSorter.new(x, y, z), "sort_spiral")
	return box_indices

func get_current_chunk_coordinates() -> Array:
	var coordinates = []
	for chunk in get_children():
		coordinates.append(chunk.get_chunk_coordinates())
	return coordinates

func remove_overlap(a: Array, b: Array):
	for b_item in b:
		for i in range(a.size()-1, -1, -1):
			if a[i][0] ==  b_item[0] && a[i][1] ==  b_item[1] && a[i][2] ==  b_item[2]:
				a.remove(i)
				break

func _chunk_entered(x, y, z):
	# print("sdafsadf")
	# print([x, y, z])
	spawn_chunks_around(x, y, z)

func serialize_chunk_name(chunk_location):
	return "%dx%dy%dz" % [chunk_location[0], chunk_location[1], chunk_location[2]]

func spawn_chunks_around(x, y, z, immediate = false, length = box_length, height = box_height, width = box_width):
	var box = box_at(x, y, z, length, height, width)
	remove_overlap(box, get_current_chunk_coordinates())
	for chunk_location in box:
		var generator = generator_scene.instance()
		generator.set_chunk_coordinates([chunk_location[0], chunk_location[1], chunk_location[2]])
		var chunk_dimensions = generator.get_chunk_dimensions()

		var world_x = chunk_location[0] * chunk_dimensions[0]
		var world_y = chunk_location[1] * chunk_dimensions[1]
		var world_z = chunk_location[2] * chunk_dimensions[2]

		var decider = NoiseDecider.new(world_x, world_y, world_z, random_noise)
		generator.set_block_decider(decider)
		generator.connect("chunk_entered", self, "_chunk_entered")
		generator.set_name(serialize_chunk_name(chunk_location))

		generator.translation.x = world_x
		generator.translation.y = world_y
		generator.translation.z = world_z
		add_child(generator)
		if immediate:
			generator.generate()
		else:
			queue_generation(generator)
