class_name FlatDecider
extends BlockDecider

var height = 1

func _init(height):
	self.height = height

func get_block_type(x, y, z):
	if y <= height:
		return 1
	else:
		return 0
