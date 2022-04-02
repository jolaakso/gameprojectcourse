extends KinematicBody

export var gravity: Vector3 = Vector3(0, -10, 0)
export var mouse_sens: float = 1

var acceleration_press: float = 10

var acceleration: Vector3
var friction: float = 3
var velocity: Vector3

func _ready():
	acceleration = Vector3.ZERO
	velocity = Vector3.ZERO

func _physics_process(delta):
	var move_dir = get_input().rotated(-rotation.y)
	# apply friction
	velocity = velocity_after_friction(delta)
	velocity = movement_acceleration(delta, move_dir)
	velocity += gravity * delta
	move_and_slide(velocity, Vector3.UP)

func velocity_after_friction(delta):
	var speed = velocity.length()
	if speed != 0:
		return velocity * max(1 - friction * delta, 0)
	return velocity

func movement_acceleration(delta, dir: Vector2) -> Vector3:
	var move_global_xy = dir.normalized()

	var move_global = Vector3(move_global_xy.x, 0, move_global_xy.y)
	var move_local = transform.basis * move_global
	var acceleration_length = acceleration_press * delta
	var projected_velocity = move_global.dot(velocity)
	
	return velocity + move_global * acceleration_length

func get_input():
	var move_direction = Vector2.ZERO
	
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
	var head = get_node("Camera")
	var current_rotation = head.rotation.x
	var tilt_radians = tilt_rotations / (2 * PI)
	var next_rotation = clamp(tilt_radians + current_rotation, -PI/3, PI/2)
	head.rotation = Vector3(next_rotation, 0, 0)

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_character(-event.relative.x * mouse_sens / 100.0)
		tilt_head(-event.relative.y * mouse_sens / 100.0)
