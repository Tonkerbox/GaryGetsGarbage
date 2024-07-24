extends RigidBody3D

@export var armJoint: JoltHingeJoint3D
@export var armSpeed: float
@export var tongRestPos: Vector3
@export var tongDeployPos: Vector3
@export var tongDeploySpeed: float = .2

@onready var tongHandler: Area3D
@onready var tongJoint: JoltGeneric6DOFJoint3D

var tongsDeployed: bool = false
var grabbedObject: trashRecipticle = null

func _ready():
	tongHandler = $tongHandler
	tongJoint = $TongJoint

func _physics_process(delta):
	handleArm()
	handleTongs()

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
		grabbedObject = body
		grabbedObject.pickedUp = true
		tongJoint.node_a = self.get_path()
		tongJoint.node_b = body.get_path()

func _on_tong_handler_body_exited(body):
	if body == grabbedObject:
		grabbedObject.pickedUp = false
		grabbedObject = null
		tongJoint.node_a = ""
		tongJoint.node_b = ""
