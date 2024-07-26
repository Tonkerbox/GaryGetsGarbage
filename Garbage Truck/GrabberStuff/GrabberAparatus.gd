extends RigidBody3D

@export var armJoint: JoltHingeJoint3D
@export var armSpeed: float
@export var tongRestPos: Vector3
@export var tongDeployPos: Vector3
@export var tongDeploySpeed: float = .2
@export var trashDumpSpeed: float = .1

@onready var dumpTimer: Timer
@onready var tongHandler: Area3D
@onready var tongJoint: JoltGeneric6DOFJoint3D

var tongsDeployed: bool = false
var grabbedObject: trashRecipticle = null
var cumXRot: float = 0

func _ready():
	dumpTimer = $Timer
	tongHandler = $tongHandler
	tongJoint = $TongJoint

func _physics_process(delta):
	handleArm()
	handleTongs()
	handleDumping()

func handleDumping():
	if grabbedObject != null:
		if dumpTimer.is_stopped():
			dumpTimer.start(trashDumpSpeed)
	else:
		dumpTimer.stop()

func handleTongs():
	if Input.is_action_just_released("deployTons"):
		var tongTween: Tween = get_tree().create_tween()
		if tongsDeployed == false:
			tongTween.tween_property(tongHandler, "position", tongDeployPos, tongDeploySpeed).set_trans(Tween.TRANS_CUBIC)
			tongsDeployed = true
		else:
			tongTween.tween_property(tongHandler, "position", tongRestPos, tongDeploySpeed).set_trans(Tween.TRANS_CUBIC)
			tongsDeployed = false

func handleArm():
	var armAxis: float = Input.get_action_strength("armUp") - Input.get_action_strength("armDown")
	armJoint.motor_target_velocity = armAxis * armSpeed

func _on_tong_handler_body_entered(body):
	if body.is_in_group('grabbable'):
		#var tempPos = body.global_position
		grabbedObject = body
		#grabbedObject.reparent(get_parent())
		#grabbedObject.global_position = tempPos
		grabbedObject.pickedUp = true
		tongJoint.node_a = self.get_path()
		tongJoint.node_b = body.get_path()

func _on_tong_handler_body_exited(body):
	if body == grabbedObject:
		grabbedObject.pickedUp = false
		tongJoint.node_a = ""
		tongJoint.node_b = ""
		#grabbedObject.reparent(get_parent().get_parent())
		grabbedObject = null

func _on_timer_timeout():
	var rotQuat = transform.basis.get_rotation_quaternion()
	if abs(rotQuat.x) > .8:
		grabbedObject.spawnTrash()
	dumpTimer.start(trashDumpSpeed)
