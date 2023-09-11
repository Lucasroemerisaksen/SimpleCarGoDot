extends CharacterBody2D

var wheel_base = 70
var steering_angle = 30
var engine_power = 600
var friction = -0.6
var drag = -0.001
var braking = -400
var max_speed_reverse = 200
var slip_speed = 350

var traction_fast = 0.06
var traction_slow = 0.85 

#var velocity = Vector2.ZERO
var steer_direction
var acceleration = Vector2.ZERO

func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	#velocity = move_and_slide()
	move_and_slide()
func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += drag_force + friction_force
	
	
func get_input():
	var turn = 0
	if Input.is_action_pressed("d"):
		turn += 1
	if Input.is_action_pressed("a"):
		turn -= 1
	steer_direction = turn * deg_to_rad(steering_angle)

	if Input.is_action_pressed("w"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("s"):
		acceleration = transform.x * braking
		
func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base/2.0
	var front_wheel = position + transform.x * wheel_base/2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()
