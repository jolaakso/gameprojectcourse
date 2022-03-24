extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_block(block_id: int, coords: Array):
	var x = coords[0]
	var y = coords[1]
	var z = coords[2]
	multimesh.set_instance_transform(block_id, Transform(Basis(), Vector3(x, y, -z)))
