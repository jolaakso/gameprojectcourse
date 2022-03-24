extends Node

var saved_data
export var save_file_path = "user://save0.gpf"

func saved_game_present() -> bool:
	var file = File.new()
	return file.file_exists(save_file_path)

func load_save():
	var save_file = File.new()
	save_file.open(save_file_path, File.READ)
	var save_file_text = save_file.get_as_text()
	saved_data = JSON.parse(save_file_text).result
	save_file.close()
