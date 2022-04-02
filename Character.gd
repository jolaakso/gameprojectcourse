extends KinematicBody

export var gravity: Vector3 = Vector3(0, -1, 0)
export var mouse_sens: float = 1

var acceleration: Vector3
var velocity: Vector3

func _ready():
	acceleration = Vector3.ZERO
	velocity = Vector3.ZERO

func _physics_process(delta):
	var move_dir = get_input().rotated(-rotation.y)
	var move_acceleration = movement_acceleration(delta, move_dir)
	acceleration += move_acceleration
	acceleration += friction(delta)
	velocity += (acceleration + gravity) * delta
	move_and_slide(Vector3(move_dir.x, 0, move_dir.y) * 5, Vector3.UP)

func friction(delta):
	var friction_delta = -velocity * 4 * delta
	if is_on_floor():
		return Vector3(friction_delta.x, 0, friction_delta.z)
	return Vector3.ZERO

func movement_acceleration(delta, dir: Vector2) -> Vector3:
	var move_global = dir.rotated(-rotation.y).normalized()
	return Vector3(move_global.x, 0, move_global.y) * delta

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
