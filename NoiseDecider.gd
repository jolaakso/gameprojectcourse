class_name NoiseDecider
extends BlockDecider

var noise_generator: OpenSimplexNoise
var offset_x: int
var offset_y: int
var offset_z: int

func _init(offset_x: int = 0, offset_y: int = 0, offset_z: int = 0, random_seed: int = 0xBEEF1B01):
	self.noise_generator = OpenSimplexNoise.new()
	noise_generator.seed = random_seed
	self.offset_x = offset_x
	self.offset_y = offset_y
	self.offset_z = offset_z

func get_block_type(x, y, z):
	var column_height = noise_generator.get_noise_2d(x + offset_x, z + offset_z)
	if y <= column_height + offset_y:
		return 1
	else:
		return 0
