class_name terrainHanlder
extends Node

@export var clipmap: MeshInstance3D
@export var player: RigidTruck

func _physics_process(delta):
	#handles clipmap
	clipmap.global_position = player.global_position.round() * Vector3(1, 0, 1)



