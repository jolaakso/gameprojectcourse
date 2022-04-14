extends KinematicBody

export var gravity: Vector3 = Vector3(0, -10, 0)
export var mouse_sens: float = 1

var acceleration_press: float = 10

var acceleration: Vector3
var friction: float = 3.0
var velocity: Vector3

signal place_block(chunk_coords, local_coords)
signal mine_block(chunk_coords, local_coords)

func _ready():
	acceleration = Vector3.ZERO
	velocity = Vector3.ZERO
	get_node("Head/RayCast").add_exception(self)

func _physics_process(delta):
	var move_dir = get_input().rotated(-rotation.y)
	if is_on_floor():
		velocity = velocity_after_friction(delta)
	else:
		velocity += gravity * delta
	# apply friction
	velocity = movement_acceleration(delta, move_dir)
	move_and_slide(velocity, Vector3.UP, true)

func velocity_after_friction(delta):
	return velocity * max(1 - friction * delta, 0)

func preview():
	var raycast = get_node("Head/RayCast")
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("get_chunk_coords_adjacent"):
			var chunk_and_coord = collider.get_chunk_coords_adjacent(raycast.get_collision_point(),
																	 raycast.get_collision_normal())
			return chunk_and_coord
	return null

func movement_acceleration(delta, dir: Vector2) -> Vector3:
	var move_global_xy = dir.normalized()

	var move_global = Vector3(move_global_xy.x, 0, move_global_xy.y)
	var move_local = transform.basis * move_global
	var acceleration_length = acceleration_press * delta
	var projected_velocity = move_global.dot(velocity)
	
	return velocity + move_global * acceleration_length

func jump():
	if is_on_floor():
		velocity += Vector3(0, 7, 0)

func get_input():
	var move_direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("place_block"):
		place_block()
	elif Input.is_action_just_pressed("mine_block"):
		mine_block()
	
	if Input.is_action_just_pressed("jump"):
		jump()
	
	if Input.is_action_pressed("move_forward"):
		move_direction += Vector2.UP
	if Input.is_action_pressed("move_backward"):
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("move_right"):
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		move_direction += Vector2.LEFT
	
	return move_direction

func rotate_character(rotations):
	rotate_y(rotations / (2 * PI))

func tilt_head(tilt_rotations):
	var head = get_node("Head")
	var current_rotation = head.rotation.x
	var tilt_radians = tilt_rotations / (2 * PI)
	var next_rotation = clamp(tilt_radians + current_rotation, -PI/3, PI/2)
	head.rotation = Vector3(next_rotation, 0, 0)

func place_block():
	var raycast = get_node("Head/RayCast")
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("get_chunk_coords_adjacent"):
			var chunk_and_coord = collider.get_chunk_coords_adjacent(raycast.get_collision_point(),
																	 raycast.get_collision_normal())
			emit_signal("place_block", chunk_and_coord.chunk, chunk_and_coord.local_coords)

func mine_block():
	var raycast = get_node("Head/RayCast")
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("get_chunk_coords_pointed"):
			var chunk_and_coord = collider.get_chunk_coords_pointed(raycast.get_collision_point(),
																	 raycast.get_collision_normal())
			collider.remove_block(chunk_and_coord.local_coords)

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_character(-event.relative.x * mouse_sens / 100.0)
		tilt_head(-event.relative.y * mouse_sens / 100.0)
