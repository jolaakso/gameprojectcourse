extends MultiMeshInstance

func set_block(block_id: int, coords: Array):
	var x = coords[0]
	var y = coords[1]
	var z = coords[2]
	multimesh.set_instance_transform(block_id, Transform(Basis(), Vector3(x, y, -z)))
