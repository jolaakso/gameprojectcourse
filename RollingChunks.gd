extends Spatial

var box_length = 5
var box_height = 1
var box_width = 5
var generator_scene = load("res://ChunkGenerator.tscn")
var random_seed = 0xFACEBEEF
var chunk_worker: Thread = Thread.new()
var worker_terminated = false
var generator_queue: Array = []
var generator_queue_mutex: Mutex = Mutex.new()
var latest_chunk_coords = [0, 0, 0]

class SpiralSorter:
	var origin
	func _init(x, y, z):
		origin = Vector3(x, y, z)
	# sorts array of arrays of 3 integers so that the ones
	# that are closer to origin are first
	func sort_spiral(a, b):
		var a_dist = Vector3(a[0], a[1], a[2]).distance_squared_to(origin)
		var b_dist = Vector3(b[0], b[1], b[2]).distance_squared_to(origin)
		return a_dist < b_dist

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		terminate_worker()

func terminate_worker():
	worker_terminated = true

	if chunk_worker.is_active():
		chunk_worker.wait_to_finish()

func _process(_delta):
	if !worker_terminated && !chunk_worker.is_alive() && !generator_queue.empty():
		if chunk_worker.is_active():
			chunk_worker.wait_to_finish()
		chunk_worker = Thread.new()
		chunk_worker.start(self, "process_generation")

func serialize():
	return {
		"id": "Chunks",
		"current_chunk_x": latest_chunk_coords[0],
		"current_chunk_y": latest_chunk_coords[1],
		"current_chunk_z": latest_chunk_coords[2],
	}

func place_block_in_chunk(chunk_coords, local_coords, block_type):
	var chunk_gen = get_node_or_null(serialize_chunk_name(chunk_coords))
	if !chunk_gen:
		return
	var chunk = chunk_gen.get_chunk()
	chunk.place_block(block_type, local_coords)

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
	if generator != null && is_instance_valid(generator):
		generator.generate()
		var paused = get_tree().paused
		if !paused:
			process_generation()

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
	spawn_chunks_around(x, y, z)
	unload_faraway_chunks(x, y, z)
	print(get_child_count())

func serialize_chunk_name(chunk_location):
	return "%dx%dy%dz" % [chunk_location[0], chunk_location[1], chunk_location[2]]

func unload_faraway_chunks(x, y, z,
						   max_x_dist = box_length/2 + 2,
						   max_y_dist = box_height/2 + 2,
						   max_z_dist = box_width/2 + 2):
	for chunk in get_children():
		var location: Array = chunk.get_chunk_coordinates()
		if abs(x - location[0]) > max_x_dist || abs(y - location[1]) > max_y_dist || abs(z - location[2]) > max_z_dist:
			chunk.unload()

func spawn_chunks_around(x, y, z, immediate = false, length = box_length, height = box_height, width = box_width):
	latest_chunk_coords = [x, y, z]
	var box = box_at(x, y, z, length, height, width)

	remove_overlap(box, get_current_chunk_coordinates())
	for chunk_location in box:
		var generator = generator_scene.instance()
		generator.set_chunk_coordinates([chunk_location[0], chunk_location[1], chunk_location[2]])
		var chunk_dimensions = generator.get_chunk_dimensions()

		var world_x = chunk_location[0] * chunk_dimensions[0]
		var world_y = chunk_location[1] * chunk_dimensions[1]
		var world_z = chunk_location[2] * chunk_dimensions[2]

		var decider = TwoLayerDecider.new(world_x, world_y, world_z, random_seed)
		generator.set_block_decider(decider)
		generator.connect("chunk_entered", self, "_chunk_entered")
		generator.set_name(generator.serialize_coords())

		generator.translation.x = world_x
		generator.translation.y = world_y
		generator.translation.z = world_z
		add_child(generator)
		if immediate:
			generator.generate()
		else:
			queue_generation(generator)
