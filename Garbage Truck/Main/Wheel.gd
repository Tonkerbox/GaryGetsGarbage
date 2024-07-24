class_name Wheel
extends RayCast3D

@export var driftWheel: bool

@onready var car: RigidTruck

var restDist: float
var strength: float
var damping: float 
var slidingFric: float
var contactPoint: Vector3 = Vector3.ZERO
var staticMult: float

var offset: float = 0
var totalForce: Vector3 = Vector3.ZERO
var lastDist: float
var velocityY: float
var velocityX: Vector3
var lastPos: Vector3
var maxSpeed: float

var wheel: Node3D

func _ready():
	car = get_parent().get_parent()
	#gets values from car
	restDist = car.restDist
	strength = car.strength
	damping = car.damping
	staticMult = car.slidingFrictionConst
	wheel = $Wheelholder

func _physics_process(delta):
	#handles suspension in y direciton
	if self.is_colliding():
		handleSuspension(delta)
		handleSlide(delta)
	handleWheel(delta)

func handleWheel(delta):
	var tireDir = self.global_basis.z
	if self.is_colliding():
		wheel.global_position = contactPoint
	wheel.position.y = clampf(wheel.position.y, 0, restDist + .1)
	$Wheelholder/whellHolderHolder.rotate_z(-tireDir.dot(car.linear_velocity)/10)

func handleSuspension(delta):
	#forces and directions
	var suspensionForce: float
	var dampingForce: float
	var dir = -global_basis.y
	
	#gets distance and stretch from contact point
	contactPoint = self.get_collision_point()
	var distance: float = contactPoint.distance_to(global_position)
	var stretch: float = abs(restDist - distance)
	
	#handles velocity
	velocityY = ((distance - lastDist) / delta)
	lastDist = distance
	
	#handles stretch and forces
	if distance < restDist + .1:
		suspensionForce = stretch * strength
		dampingForce = (velocityY * damping)
	else:
		dampingForce = 0
	
	#applies forces
	totalForce = ((suspensionForce) - (dampingForce)) * dir
	car.apply_force(totalForce, contactPoint - car.global_position)
	
	#debugging tools
	#print('stretch ', stretch)
	#print('totalforce ', totalForce)
	#print('susFroce ', (stretch * strength))
	#print('dampfroce ', (velocityY * damping))

func handleSlide(delta):
	var tireDir = self.global_basis.x
	var tireVel: float = (car.linear_velocity + car.angular_velocity.cross(contactPoint - car.global_position)).dot(tireDir)
	var currentMult: float 
	if tireVel < 0:
		currentMult = -staticMult
	else:
		staticMult =  staticMult
	
	var fricForce = tireVel * slidingFric + currentMult
	
	car.apply_force(-tireDir * fricForce, contactPoint - car.global_position)

func drive(power):
	if self.is_colliding():
		car.apply_force(power * car.global_basis.z, contactPoint - car.global_position)

#dont look its bad but it works
func brake():
	if self.is_colliding():
		var tireDir = self.global_basis.z
		var tireVel: float = car.linear_velocity.dot(tireDir)
		var normalVel: Vector3 = car.linear_velocity.normalized()
		
		var brakeForce = -tireVel * car.brakeForce
		var normalBrake = -normalVel * car.constantBrakeForce
		
		#gets magnitude of cars velocity and sets it to zero if under .1
		if sqrt(pow(car.linear_velocity.x,2) + pow(car.linear_velocity.y, 2) + pow(car.linear_velocity.z, 2)) < .2:
			car.linear_velocity = Vector3.ZERO
			brakeForce = 0
			normalBrake = Vector3.ZERO
		
		#print('normal force:', normalBrake, 'brake force:', brakeForce)
		car.apply_force(tireDir * brakeForce + normalBrake, contactPoint - car.global_position)
