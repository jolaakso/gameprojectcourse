extends WorldEnvironment

func _ready():
	var rolling_chunks = get_node("RollingChunks")
	rolling_chunks.spawn_chunks_around(0, 0, 0, true, 2, 1, 2)
	call_deferred("spawn_perimeter")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if GameSave.saved_data:
		for obj in GameSave.saved_data:
			if obj["id"] == "TestBlocky":
				get_node("TestBlocky").deserialize(obj)

func _process(delta):
	var preview_block = get_node("PreviewBlock")
	var character = get_node("Character")
	
	var previewing_chunk_block = character.preview()

	if previewing_chunk_block:
		var chunk_coords = previewing_chunk_block.chunk
		var local_coords = previewing_chunk_block.local_coords
		var global_preview_coords = get_node("RollingChunks").previewable_global_coordinates(chunk_coords,
																							 local_coords)
		if global_preview_coords:
			preview_block.visible = true
			preview_block.translation = global_preview_coords + Vector3.ONE * 0.5
		else:
			preview_block.visible = false
	else:
		preview_block.visible = false

func serialized_state():
	var persistables = get_tree().get_nodes_in_group('persistent')
	var serialized = []
	for persistable in persistables:
		serialized.append(persistable.serialize())
	return JSON.print(serialized)

func save_game(save_file: File):
	var state_json = serialized_state()
	save_file.store_line(state_json)

func _on_PauseMenu_game_saved():
	var save_file = File.new()
	save_file.open(GameSave.save_file_path, File.WRITE)
	save_game(save_file)
	save_file.close()
	get_node("PauseMenu").confirm_game_saved()

func spawn_perimeter():
	var rolling_chunks = get_node("RollingChunks")
	rolling_chunks.spawn_chunks_around(0, 0, 0)

func _on_Character_place_block(chunk_coords, local_coords):
	get_node("RollingChunks").place_block_in_chunk(chunk_coords, local_coords)


func _on_Character_mine_block(chunk_coords, local_coords):
	get_node("RollingChunks").mine_block_in_chunk(chunk_coords, local_coords)
