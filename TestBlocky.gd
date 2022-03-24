extends MeshInstance

var counter = 0

func _physics_process(delta):
	counter += delta
	translation.y += sin(counter * 2) * 0.0025

func serialize():
	return {
		"id": "TestBlocky",
		"counter": counter,
		"y_pos": translation.y,
	}

func deserialize(serialized):
	counter = serialized["counter"]
	translation.y = serialized["y_pos"]
