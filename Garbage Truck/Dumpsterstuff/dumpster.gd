class_name Dumpster
extends RigidBody3D

@export var dumpsterJoint: JoltHingeJoint3D
@export var dumpAngle: float = 35
@export var maxSpace: float = 1000
@export var mintopperHeight: float = 0
@export var maxtopperHeight: float = 100
@export var topperScaleHeight: float = 0
@export var minTopperScaleHeight:float = 0
@export var topperScaleReg: float = .6
@export var topperScaleSmol: float = .5

@onready var lid: RigidBody3D = $Lid
@onready var joint: JoltHingeJoint3D = $mainJoint
@onready var topper: MeshInstance3D = $TopperMesh
@onready var dumpTimer: Timer = $DumpTimer

var jointOffset: Vector3
var locked: bool = true
var lidSpeed: float = 0
var lidThresh: float = 1
var currentSpace: float = 0
var dumpSpeed: float = .05
var trashList: Array[int] = []
var dumping: bool = false

func _ready():
	jointOffset = joint.position - lid.position

func _physics_process(delta):
	handleLid()
	handleTopper(delta)
	handleDump()

func handleDump():
	var rotQuat = transform.basis.get_rotation_quaternion()
	if abs(rad_to_deg(rotQuat.x)) >= dumpAngle/2 and dumpTimer.is_stopped():
		dumpTimer.start(dumpSpeed)
		dumping = true
	elif abs(rad_to_deg(rotQuat.x)) <= dumpAngle/2:
		dumpTimer.stop()
		dumping = false

func handleTopper(delta):
	var desiredPos: float = (currentSpace/maxSpace) * (maxtopperHeight - mintopperHeight) + mintopperHeight
	desiredPos = clamp(desiredPos, mintopperHeight, maxtopperHeight)
	topper.position.y = lerpf(topper.position.y, desiredPos, delta * .5)
	if topper.position.y > topperScaleHeight and not topper.scale.x == topperScaleReg:
		topper.scale.x = topperScaleReg
	elif topper.position.y < minTopperScaleHeight and not topper.scale.x == .4:
		topper.scale.x = .4
	elif topper.position.y < topperScaleHeight and not topper.scale.x == topperScaleSmol:
		topper.scale.x = topperScaleSmol

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

func _on_trash_col_body_entered(body: Node3D):
	if body.is_in_group('trash') and not dumping:
		if currentSpace <= maxSpace:
			currentSpace += body.space
			trashList.append(body.sceneNum)
		body.queue_free()

func _on_dump_timer_timeout():
	if trashList.size() > 0:
		var newTrash: trash = Global.trashArray[trashList.pop_front()].instantiate()
		currentSpace -= newTrash.space
		add_child(newTrash)
		newTrash.position = Vector3(randf_range(-1, 1), .5, randf_range(-1, 1))
		newTrash.top_level = true
