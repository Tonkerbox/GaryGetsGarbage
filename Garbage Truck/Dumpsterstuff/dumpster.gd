class_name Dumpster
extends RigidBody3D

@export var dumpsterJoint: JoltHingeJoint3D

@onready var lid: RigidBody3D = $Lid
@onready var joint: JoltHingeJoint3D = $mainJoint

var jointOffset: Vector3
var locked: bool = true
var lidSpeed: float = 0
var lidThresh: float = 1

func _ready():
	jointOffset = joint.position - lid.position

func _physics_process(delta):
	handleLid()

func handleLid():
	if not dumpsterJoint.locked:
		joint.limit_lower = deg_to_rad(-130)
		locked = false
	elif abs(lid.rotation_degrees.x) <= lidThresh:
		joint.limit_lower = 0
		locked = true
	
	if locked:
		lid.rotation_degrees.x = 0
		lid.position = joint.position - jointOffset
