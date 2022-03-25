extends WorldEnvironment

func _ready():
	var f = get_node("ChunkGenerator")
	f.set_block_decider(FlatDecider.new(1))
	f.generate()
	var f2 = get_node("ChunkGenerator2")
	f2.set_block_decider(FlatDecider.new(10))
	f2.generate()
	if GameSave.saved_data:
		for obj in GameSave.saved_data:
			if obj["id"] == "TestBlocky":
				get_node("TestBlocky").deserialize(obj)

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
