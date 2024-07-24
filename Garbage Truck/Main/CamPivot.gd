class_name CamHandler
extends Node3D

@export var strength: float
@export var mouseSense: float
@export var restRot: Vector3
@export var cam: Camera3D
@export var camArm: SpringArm3D
@export var lookSpot: Node3D
@export var zoomPos: Vector3
@export var zoomRot: Vector3

@onready var camHandler: Node3D = get_parent()
@onready var truck: RigidBody3D = self.get_parent().get_parent()

var looking: bool = false
var zoomed: bool = false
var mouseMovement: Vector2 = Vector2.ZERO
var strengthMult: float = 1
var yaw: float = deg_to_rad(180)
var pitch: float = deg_to_rad(-35)

func _ready():
	rotation = restRot
	camArm.top_level = true
	camArm.rotation = restRot

func _physics_process(delta):
	if Input.is_action_just_pressed("zoom") and not zoomed:
		zoomed = true
		cam.reparent(get_parent())
		cam.position = zoomPos
		cam.rotation = zoomRot
	elif Input.is_action_just_pressed("zoom") and zoomed:
		cam.reparent(camArm)
		zoomed = false
	
	if Input.is_action_pressed("freeL") and not zoomed:
		camArm.global_rotation.y = yaw
		camArm.global_rotation.x = pitch
		pitch = clamp(pitch, deg_to_rad(-80), deg_to_rad(80))
		camArm.global_position = global_position
	elif not zoomed:
		yaw = camArm.global_rotation.y
		pitch = camArm.global_rotation.x
		rotation = restRot
		handleRegMovement(delta)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_action_pressed("freeL"):
		yaw += -event.relative.x * mouseSense
		pitch += -event.relative.y * mouseSense

func handleRegMovement(delta):
	var targetQuat: Quaternion = Quaternion.from_euler(global_rotation)
	var currentQuat: Quaternion = camArm.global_transform.basis.get_rotation_quaternion()
	
	var interpolatedQuat = lerp(currentQuat, targetQuat, delta * strength)
	var interpolatedPos = lerp(camArm.global_position, global_position, delta * strength)
	
	camArm.global_transform = Transform3D(Basis(interpolatedQuat), interpolatedPos)
	cam.look_at(lookSpot.global_position)
