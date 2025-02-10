extends CharacterBody3D


var SPEED = 0.0
var ACCELERATION = 5.0
var BREAK_VALUE = 0
var DECELERATION = 4.0
var MAX_SPEED = 40.0
var CURRENT_GEAR = 1

var ROTATION_SPEED = 2.0
var STEERING_ANGLE = 0.0

var GRAVITY = -9.8
# var VELOCITY_Y = 0.0

var RPM = 0
var MIN_RPM = 3000
var MAX_RPM = 12000

var CONTACT = false

func _physics_process(delta: float) -> void:
	
	# VELOCITY_Y += GRAVITY * delta
	
	if Input.is_action_pressed("throttle"):
		SPEED += ACCELERATION * delta 
	else:
		SPEED -= DECELERATION * delta
	if Input.is_action_pressed("break"):
		SPEED -= BREAK_VALUE * delta
		
	SPEED = clamp(SPEED, 0, MAX_SPEED)
	RPM = lerp(MIN_RPM, MAX_RPM, SPEED / MAX_SPEED)
	
	if Input.is_action_pressed("steering_left"):
		STEERING_ANGLE += ROTATION_SPEED * delta
	elif Input.is_action_pressed("steering_right"):
		STEERING_ANGLE -= ROTATION_SPEED * delta
	if Input.is_action_just_released("steering_left"):
		while (STEERING_ANGLE > 0.1):
			STEERING_ANGLE = STEERING_ANGLE / 2
		STEERING_ANGLE = 0
	elif Input.is_action_just_released("steering_right"):
		while (STEERING_ANGLE < -0.1):
			STEERING_ANGLE = STEERING_ANGLE / 2
		STEERING_ANGLE = 0
	
	STEERING_ANGLE  = clamp(STEERING_ANGLE, -0.5, 0.5)
	
	self.velocity = -transform.basis.z * SPEED
	# self.velocity.y = VELOCITY_Y
	move_and_slide()
	
	rotate_y(STEERING_ANGLE * delta) 


func _on_body_entered(body: Node) -> void:
	CONTACT = true
