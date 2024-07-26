class_name trashRecipticle
extends RigidBody3D

@export var trashArr: Array[PackedScene]
@export var trashSpawnPosY: float
@export var trashSpawnArea: Vector2
@export var capacity: float
@export var globalIndex: int = 0

var pickedUp: bool = false
var spawning: bool = false

func spawnTrash():
	if capacity >= 0:
		var newTrash: trash = trashArr.pick_random().instantiate()
		add_child(newTrash)
		newTrash.position = Vector3(randf_range(-trashSpawnArea.x, trashSpawnArea.x), trashSpawnPosY, randf_range(-trashSpawnArea.y, trashSpawnArea.y))
		capacity -= newTrash.space
		newTrash.top_level = true

