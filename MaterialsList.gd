extends Node

var materials = [
	preload("res://materials/gray.material"),
	preload("res://materials/soil.material"),
	preload("res://materials/grass_shader.material"),
]

func get_matching_material(block_type):
	return materials[(block_type - 1) % materials.size()]
