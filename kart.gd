extends CharacterBody3D

@export var max_speed: float = 4.0
@export var acceleration: float = 8.0
@export var deceleration: float = 4.0
@export var steering_speed: float = 25.0
@export var fall_acceleration = 30.0

var speed: float = 0.0
var fall_speed: float = 0.0


func _physics_process(delta: float) -> void:
	# Accelerate/decelerate
	if Input.is_action_pressed("accelerate"):
		speed = move_toward(speed, -max_speed, acceleration * delta)
	else:
		speed = move_toward(speed, 0, deceleration * delta)

	# Fall
	if is_on_floor():
		fall_speed = 0.0
	else:
		fall_speed -= fall_acceleration * delta

	# Steering
	var steering = Input.get_axis("steer_right", "steer_left")
	rotate_y(steering * deg_to_rad(steering_speed) * delta)

	# Apply velocity
	var forward = - global_basis.z
	forward.y = 0.0
	velocity = forward.normalized() * -speed
	velocity.y = fall_speed
	move_and_slide()
