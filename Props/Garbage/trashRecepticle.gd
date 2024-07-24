class_name trashRecipticle
extends RigidBody3D

@export var trash: Array[PackedScene]
@export var trashSpawnPosY: float
@export var trashSpawnArea: Vector2
@export var rotationTreshold: float = 90
@export var trashSpawnFrames: int = 4

var pickedUp: bool = false
var spawning: bool = false
var currentTrashFrames: int

func _ready():
	currentTrashFrames = trashSpawnFrames

func _physics_process(delta):
	if global_rotation_degrees.x >= rotationTreshold or global_rotation_degrees.z >= rotationTreshold and pickedUp:
		spawnTrash()

func spawnTrash():
	print('spawn trash')
	if currentTrashFrames <= 0:
		currentTrashFrames = trashSpawnFrames
		var newTrash: RigidBody3D = trash.pick_random().instantiate()
		add_child(newTrash)
		newTrash.position = Vector3(randf_range(-trashSpawnArea.x, trashSpawnArea.x), trashSpawnPosY, randf_range(-trashSpawnArea.y, trashSpawnArea.y))
	else:
		currentTrashFrames -= 1

