extends KinematicBody

export var gravity: Vector3 = Vector3(0, -10, 0)
export var mouse_sens: float = 1

var acceleration_press: float = 10

var acceleration: Vector3
var friction: float = 3.0
var velocity: Vector3
var snap = Vector3.DOWN

var max_velocity_ground = 50.0
var max_velocity_air = 75.0

var last_safe_location = Vector3.ZERO

var selected_block_type = 1

signal place_block(chunk_coords, local_coords, block_type)
signal mine_block(chunk_coords, local_coords)

func _ready():
	acceleration = Vector3.ZERO
	velocity = Vector3.ZERO
	get_node("Head/RayCast").add_exception(self)
	get_node("Head/SelectedBlock").material_override = MaterialsList.get_matching_material(selected_block_type)

func serialize():
	return {
		"id": "Character",
		"x_pos": translation.x,
		"y_pos": translation.y,
		"z_pos": translation.z,
		"y_rot": rotation.y,
	}

func deserialize(dict: Dictionary):
	translation.x = dict["x_pos"]
	translation.y = dict["y_pos"]
	translation.z = dict["z_pos"]
	rotation.y = dict["y_rot"]
	
	last_safe_location = translation

func teleport_to_last_safe():
	translation = last_safe_location

func save_last_safe():
	last_safe_location = translation

func _physics_process(delta):
	if is_on_floor() && snap == Vector3.ZERO:
		snap = Vector3.DOWN
		
	var move_dir = get_input().rotated(-rotation.y)
	if is_on_floor():
		velocity = velocity_after_friction(delta)
	elif is_on_wall(): 
		velocity = velocity_after_friction(delta)
		velocity += gravity * delta
	else:
		velocity += gravity * delta
	# apply friction
	velocity = movement_acceleration(delta, move_dir)
	move_and_slide_with_snap(velocity, snap, Vector3.UP)

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
	
	var max_velocity = max_velocity_air
	
	if is_on_floor():
		max_velocity = max_velocity_ground
	if acceleration_length + projected_velocity > max_velocity:
		acceleration_length = max_velocity - projected_velocity
	
	return velocity + move_global * acceleration_length

func jump():
	if is_on_floor():
		snap = Vector3.ZERO
		velocity += Vector3(0, 7, 0)
		play_jump_sound()

func switch_camera():
	var first_person = get_node("Head/Camera")
	var third_person = get_node("Head/ThirdPersonCamera")
	var block = get_node("Head/SelectedBlock")
	if first_person.current:
		first_person.current = false
		third_person.current = true
		block.place_in_hand()
	else:
		first_person.current = true
		third_person.current = false
		block.place_next_to_head()

func play_walk_animation():
	var animation = get_node("DuckWhite/Skeleton/AnimationPlayer").play("ArmatureAction")

func reset_walk_animation():
	var animation = get_node("DuckWhite/Skeleton/AnimationPlayer").play("RESET")

func stop_walk_animation():
	var animation = get_node("DuckWhite/Skeleton/AnimationPlayer").stop()

func play_walk_sound():
	var walk_sound = get_node("WalkSound")
	if !walk_sound.playing:
		walk_sound.play()

func stop_walk_sound():
	var walk_sound = get_node("WalkSound")
	if walk_sound.playing:
		walk_sound.stop()

func play_jump_sound():
	var jump_sound = get_node("JumpSound")
	jump_sound.play(0.0)

func play_plop_sound():
	var plop_sound = get_node("PlopSound")
	plop_sound.play(0.0)

func play_remove_sound():
	var remove_sound = get_node("RemoveSound")
	remove_sound.play(0.0)

func select_block(block_type):
	selected_block_type = block_type
	get_node("Head/SelectedBlock").material_override = MaterialsList.get_matching_material(selected_block_type)

func get_input():
	var move_direction = Vector2.ZERO
	
	if Input.is_action_just_pressed("switch_camera"):
		switch_camera()
	
	if Input.is_action_just_pressed("place_block"):
		place_block()
	elif Input.is_action_just_pressed("mine_block"):
		mine_block()
	
	if Input.is_action_just_pressed("jump"):
		jump()
	
	var is_moving = false
	
	if Input.is_action_pressed("move_forward"):
		is_moving = true
		move_direction += Vector2.UP
	if Input.is_action_pressed("move_backward"):
		is_moving = true
		move_direction += Vector2.DOWN
	if Input.is_action_pressed("move_right"):
		is_moving = true
		move_direction += Vector2.RIGHT
	if Input.is_action_pressed("move_left"):
		is_moving = true
		move_direction += Vector2.LEFT
	
	if is_moving && is_on_floor():
		play_walk_animation()
		play_walk_sound()
	elif !is_on_floor():
		stop_walk_animation()
		stop_walk_sound()
	else:
		reset_walk_animation()
		stop_walk_sound()
	
	if Input.is_action_just_pressed("block_1"):
		select_block(1)
	elif Input.is_action_just_pressed("block_2"):
		select_block(2)
	elif Input.is_action_just_pressed("block_3"):
		select_block(3)
	elif Input.is_action_just_pressed("block_4"):
		select_block(4)
	return move_direction

func rotate_character(rotations):
	rotate_y(rotations / (2 * PI))

func push_away_from(global_point):
	var current_velocity = velocity
	velocity = Vector3(-current_velocity.x, -3 * current_velocity.y, -current_velocity.z)

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
			emit_signal("place_block", chunk_and_coord.chunk, chunk_and_coord.local_coords, selected_block_type)
			play_plop_sound()

func mine_block():
	var raycast = get_node("Head/RayCast")
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.has_method("get_chunk_coords_pointed"):
			var chunk_and_coord = collider.get_chunk_coords_pointed(raycast.get_collision_point(),
																	 raycast.get_collision_normal())
			collider.remove_block(chunk_and_coord.local_coords)
			play_remove_sound()

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_character(-event.relative.x * mouse_sens / 100.0)
		tilt_head(-event.relative.y * mouse_sens / 100.0)
