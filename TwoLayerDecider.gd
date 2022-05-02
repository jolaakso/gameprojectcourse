class_name TwoLayerDecider
extends BlockDecider

var soil_generator: OpenSimplexNoise
var rock_generator: OpenSimplexNoise
var offset_x: int
var offset_y: int
var offset_z: int

var coordinate_cache = {}

func _init(offset_x: int = 0, offset_y: int = 0, offset_z: int = 0, the_seed: int = 0xFACEBEEF):
	self.soil_generator = OpenSimplexNoise.new()
	soil_generator.seed = the_seed
	self.rock_generator = OpenSimplexNoise.new()
	rock_generator.seed = -the_seed
	self.offset_x = offset_x
	self.offset_y = offset_y
	self.offset_z = offset_z

func sample_noise(x, z):
	var key = [x, z].hash()
	if coordinate_cache.has(key):
		return coordinate_cache[key]
	var soil_sample = soil_generator.get_noise_2d(x + offset_x, z + offset_z)
	var rock_sample = rock_generator.get_noise_2d(x + offset_x, z + offset_z)
	
	var samples = { rock_sample = rock_sample, soil_sample = soil_sample }
	
	coordinate_cache[key] = samples
	
	return samples

func get_block_type(x, y, z):
	var samples = sample_noise(x, z)
	var soil_height = samples.soil_sample * 2
	var rock_height = samples.rock_sample * 2 - 5
	if y + offset_y <= rock_height:
		return 1
	elif y + offset_y <= soil_height:
		if y + offset_y + 1 <= soil_height:
			return 2
		else:
			return 3
	else:
		return 0
