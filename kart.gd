extends CharacterBody3D

enum DriftState {DRIVING, HOPPING, DRIFTING}

@export var max_speed: float = 4.0
@export var acceleration: float = 8.0
@export var deceleration: float = 4.0
@export var steering_speed: float = 60.0
@export var drift_steering_speed: float = 100.0
@export var fall_acceleration: float = 60.0
@export var jump_impulse: float = 8.0
@export_range(0.01, 1.0, 0.01) var drift_wide_turn_ratio: float = 0.5
@export var drift_grip: float = 3.0

var speed: float = 0.0
var fall_speed: float = 0.0
var drift_state := DriftState.DRIVING
var drift_direction: float = 0.0
var velocity_angle: float = 0.0


func _physics_process(delta: float) -> void:
	var grounded := is_on_floor()
	var jump_held := Input.is_action_pressed("jump")
	var steering := Input.get_axis("steer_right", "steer_left")

	# Accelerate/decelerate
	if Input.is_action_pressed("accelerate"):
		speed = move_toward(speed, -max_speed, acceleration * delta)
	else:
		speed = move_toward(speed, 0, deceleration * delta)

	# Falling/Jumping
	if grounded:
		if Input.is_action_just_pressed("jump"):
			fall_speed = jump_impulse
			velocity_angle = atan2(global_basis.z.x, global_basis.z.z) # Current kart heading
			drift_state = DriftState.HOPPING
		else:
			fall_speed = 0.0
	else:
		fall_speed -= fall_acceleration * delta

	if not jump_held or (drift_state == DriftState.DRIFTING and (not grounded or is_zero_approx(speed))):
		drift_state = DriftState.DRIVING

	# Rotate the heading of the kart
	var turn_rate := steering * steering_speed
	if drift_state == DriftState.DRIFTING:
		var drift_input := steering * drift_direction
		var turn_weight := (drift_input + 1.0) * 0.5
		var wide_turn_speed := drift_steering_speed * drift_wide_turn_ratio
		turn_rate = drift_direction * lerpf(wide_turn_speed, drift_steering_speed, turn_weight)
	rotate_y(deg_to_rad(turn_rate) * delta)

	# Rotate the course direction
	var heading_angle := atan2(global_basis.z.x, global_basis.z.z) # Current kart heading
	if drift_state == DriftState.DRIFTING:
		velocity_angle = lerp_angle(velocity_angle, heading_angle, 1.0 - exp(-drift_grip * delta))
	elif drift_state == DriftState.DRIVING:
		velocity_angle = heading_angle

	# Apply velocity
	velocity = Vector3.FORWARD.rotated(Vector3.UP, velocity_angle) * -speed
	velocity.y = fall_speed
	move_and_slide()

	# A held jump becomes a drift only once the hop lands while turning.
	if drift_state == DriftState.HOPPING and is_on_floor():
		if not is_zero_approx(speed) and not is_zero_approx(steering):
			drift_direction = signf(steering)
			drift_state = DriftState.DRIFTING
		else:
			drift_state = DriftState.DRIVING
