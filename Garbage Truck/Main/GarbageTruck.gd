class_name RigidTruck
extends RigidBody3D

@export var power: float
@export var maxSpeed: float = 30
@export var restDist: float
@export var strength: float
@export var damping: float 
@export var slidingFrictionBack: float
@export var slidingFrictionFront: float
@export var slidingFrictionConst: float
@export var brakeForce: float = .4
@export var constantBrakeForce: float 
@export var steeringWheels: Array[Wheel]
@export var drivingWheels: Array[Wheel]
@export var steeringSpeed: float = .2
@export var steeringAngle: float = 45
@export var drivingView: Vector3
@export var pickingUpView: Vector3
@export var backUpView: Vector3
@export var powerband: Curve

var realSteerAngle: float = 0
var realSteer = 0
var zoomed: bool = false

func _ready():
	for wheel: Wheel in drivingWheels:
		wheel.slidingFric = slidingFrictionBack
		wheel.strength = strength
		wheel.restDist = restDist
		wheel.damping = damping
	for wheel: Wheel in steeringWheels:
		wheel.slidingFric = slidingFrictionFront
		wheel.strength = strength
		wheel.restDist = restDist
		wheel.damping = damping

func _physics_process(delta):
	handleSteeringKeyBoard(delta)
	handlePower(delta)
	#handleSteeringController(delta)

func handlePower(delta):
	var realPower = powerband.sample(global_basis.x.dot(linear_velocity)/maxSpeed) * power
	var dirForward = global_basis.z
	var forwardVel: float = linear_velocity.dot(dirForward)
	if Input.is_action_pressed("forward"):
		for wheel in drivingWheels + steeringWheels:
			wheel.drive(realPower)
	if Input.is_action_pressed("backward"):
		for wheel in drivingWheels:
			wheel.drive(-realPower)
	if Input.is_action_pressed("shift"):
		for wheel in drivingWheels:
			wheel.brake()

func handleSteeringController(delta):
	var axis: float = Input.get_axis("joyLeft", 'joyRight')
	realSteer = lerpf(realSteer, steeringAngle * axis, delta * steeringSpeed)
	if axis == 0:
		realSteer = 0
	else:
		for wheel in steeringWheels:
				wheel.rotation_degrees.y = -realSteer

func handleSteeringKeyBoard(delta):
	if Input.is_action_pressed("left"):
		realSteerAngle = lerpf(realSteerAngle, steeringAngle, steeringSpeed * delta)
		steeringWheels[0].rotation_degrees.y = realSteerAngle + 180
		steeringWheels[1].rotation_degrees.y = realSteerAngle
	elif Input.is_action_pressed("right"):
		realSteerAngle = lerpf(realSteerAngle, -steeringAngle, steeringSpeed * delta)
		steeringWheels[0].rotation_degrees.y = realSteerAngle + 180
		steeringWheels[1].rotation_degrees.y = realSteerAngle
	else:
		realSteerAngle = 0
		steeringWheels[0].rotation_degrees.y = realSteerAngle + 180
		steeringWheels[1].rotation_degrees.y = realSteerAngle
