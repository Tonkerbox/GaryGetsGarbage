extends JoltHingeJoint3D

@export var speed: float = 5

@onready var dumpster: RigidBody3D = get_node(node_b)

var locked: bool = true

func _physics_process(delta):
	handleJoint()

func handleJoint():
	if Input.is_action_pressed("dumpUp"):
		motor_target_velocity = speed
		locked = false
	elif Input.is_action_pressed("dumpDown"):
		if not locked:
			motor_target_velocity = -speed
		else:
			motor_target_velocity = 0
		if abs(dumpster.rotation_degrees.x) <= 1:
			locked = true
		else:
			locked = false
	else:
		motor_target_velocity = 0
	
	
	if locked:
		limit_upper = deg_to_rad(.1)
		dumpster.rotation_degrees.x = 0
	else:
		limit_upper = deg_to_rad(70)
