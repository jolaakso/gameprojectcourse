class_name FlatDecider
extends BlockDecider

var height
var height_offset

func _init(height = 1, height_offset = 0):
	self.height = height
	self.height_offset = height_offset

func get_block_type(x, y, z):
	if y <= height + height_offset:
		return 1
	else:
		return 0
