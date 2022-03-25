extends "res://ChunkGenerator.gd"

export var height = 1

func get_block_type(x, y, z):
	if y < height:
		return 1
	else:
		return 0
