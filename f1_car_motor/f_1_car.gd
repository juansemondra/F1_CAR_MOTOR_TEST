extends CharacterBody3D

var SPEED = 0.0
var ACCELERATION = 0.0 # Will be calculated dynamically
var BREAK_VALUE = 5.0
var DECELERATION = 2.5
var MAX_SPEED = 100.0
var CURRENT_GEAR = 0
var ACCELERATION_FORCE = 0.0 # Will be calculated dynamically

var ROTATION_SPEED = 2.0
var STEERING_ANGLE = 0.0

var GRAVITY = -9.8
var VELOCITY_Y = 0.0

var CAR_MASS = 740  # Approximate F1 car weight in kg

# Engine Parameters
var RPM = 3000
var MIN_RPM = 3000
var MAX_RPM = 12000
var THROTTLE = 0.0
var TORQUE = 0.0
var POWER = 0.0

var IGNITION_TIMING = 0.0
var MANIFOLD_PRESSURE = 0.0
var EXHAUST_FLOW = 0.0
var AFR = 14.7  # Air-Fuel Ratio
var FUEL_RATE = 0.0
var FREQUENCY = 0.0
var EFFICIENCY = 0.0

var GEAR_RATIOS = [0.1, 3.5, 2.8, 2.2, 1.8, 1.4, 1.1]  # Gear transmission ratios
var MAX_SPEED_PER_GEAR = [0.0, 40.0, 60.0, 70.0, 75.0, 90.0, 100.0]  # Max speed in m/s per gear
var FINAL_DRIVE_RATIO = 3.9  # Differential ratio
var WHEEL_RADIUS = 0.33

var CONTACT = false

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		VELOCITY_Y -= GRAVITY * delta * -1.0 # Apply gravity when the car is not touching the ground
	else:
		VELOCITY_Y = 0  # Reset gravity effect when on the ground
	
	# Car basic controls
	if Input.is_action_pressed("throttle"):
		THROTTLE = min(THROTTLE + 0.02, 1.0)
	elif Input.is_action_pressed("brake"):
		SPEED = max(SPEED - (BREAK_VALUE * delta), 0)
	else:
		THROTTLE = max(THROTTLE - 0.01, 0.0)
	
	if Input.is_action_just_pressed("gear_up") and CURRENT_GEAR < 6:
		CURRENT_GEAR += 1
		RPM = max(MIN_RPM, RPM * 0.7)
	
	if Input.is_action_just_pressed("gear_down") and CURRENT_GEAR > 0:
		CURRENT_GEAR -= 1
		RPM = min(MAX_RPM, RPM * 1.3)
		SPEED = max(SPEED * 0.8, 0.0)
	
	# Update RPM based on throttle & gear
	if CURRENT_GEAR != 0:
		RPM += THROTTLE * (MAX_RPM / GEAR_RATIOS[CURRENT_GEAR]) * delta
	RPM = clamp(RPM, MIN_RPM, MAX_RPM)
	
	TORQUE = get_torque_from_rpm(RPM)
	POWER = (TORQUE * (2 * PI * (RPM / 60))) / 1000
	
	if CURRENT_GEAR != 0:
		ACCELERATION_FORCE = (TORQUE * FINAL_DRIVE_RATIO * GEAR_RATIOS[CURRENT_GEAR]) / WHEEL_RADIUS  # Force (N)
		ACCELERATION = ACCELERATION_FORCE / CAR_MASS  # Newton's Second Law
	else:
		ACCELERATION = 0.0
		
	SPEED += ACCELERATION * delta
	SPEED -= DECELERATION * delta if SPEED > 0 and THROTTLE == 0 else 0
	SPEED = clamp(SPEED, 0, MAX_SPEED)
	
	# Steering Control
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
	self.velocity.y = VELOCITY_Y
	move_and_slide()
	
	rotate_y(STEERING_ANGLE * delta) 
	print("Speed: " + str(SPEED))
	print("Current Gear: " + str(CURRENT_GEAR))
	print("RPM: " + str(RPM))

func get_torque_from_rpm(rpm: float) -> float:
	if rpm < 7000:
		return 300 + (rpm - 6000) * 0.05
	elif rpm < 9000:
		return 350
	else:
		return 350 - ((rpm - 9000) * 0.05)

func _on_body_entered(body: Node) -> void:
	CONTACT = true
