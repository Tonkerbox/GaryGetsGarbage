extends Node

@export var chunkSize: int = 175
@export var chunkFrames: int = 10
@export var naturePropSpawnRate: float = 1
@export var chunkGrid: int = 1
@export var treeSpawnRate: float = 5
@export var physicsSpawnRate: float = 2
@export var trees: Array[PackedScene]
@export var physicsObjects: Array[PackedScene]

@onready var player: RigidTruck = get_parent()

var chunkSnap: Vector3i
var chunkCords: Array[Vector3i]
var currentChunkCoords: Vector3i
var chunkDick: Dictionary
var currentChunkPart: int = 0

func _ready():
	randomize()
	await Global.groundVal.changed
	chunkSnap = Vector3i(chunkSize, 0, chunkSize)
	generateChunks()

func _physics_process(delta):
	if not Vector3i(player.global_position.snapped(chunkSnap) * Vector3(1, 0, 1)) == currentChunkCoords:
		generateChunks()

func generateChunks():
	currentChunkCoords = player.global_position.snapped(chunkSnap) * Vector3(1, 0, 1)
	var oldChunks: Array[Vector3i] = chunkCords
	var newChunks: Array[Vector3i] = []
	for x in range(-chunkGrid, chunkGrid + 1):
		for z in range(-chunkGrid, chunkGrid + 1):
			newChunks.append(Vector3i(x, 0, z) * chunkSize + currentChunkCoords)
	
	for coord in oldChunks:
		if not coord in newChunks:
			deleteChunk(coord)
	
	chunkCords = newChunks
	
	for coord in chunkCords:
		if not coord in oldChunks:
			currentChunkPart = 0
			for chunk in range(chunkFrames):
				generateChunk(coord)
				currentChunkPart += 1

func generateChunk(coord: Vector3i):
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	var objectsInChunk: Array[Node3D]
	var chunkPart: float = chunkSize/chunkFrames
	for x in range(-chunkSize/2 + chunkPart * currentChunkPart, -chunkSize/2 + chunkPart * (currentChunkPart + 1)):
		for z in range(-chunkSize/2 + chunkPart * currentChunkPart, -chunkSize/2 + chunkPart * (currentChunkPart + 1)):
			print(x,",",z)
			print('generated', currentChunkPart)
			var height: float = Global.getHeight((x), (z))
			random.seed = height * x/z + x * z - height + 69 * height + 420 * height * x / (z + 69) + 42069 / (z + 420)
			var spawnVal = random.randf_range(0, 100)
			
			if spawnVal <= treeSpawnRate:
				var newTree: Node3D = trees.pick_random().instantiate()
				get_parent().get_parent().add_child(newTree)
				newTree.global_position = Vector3((x), height, (z))
				newTree.global_rotation.y = random.randf_range(0, 360)
				newTree.global_rotation.z = random.randf_range(-.1, .1)
				newTree.global_rotation.x = random.randf_range(-.1, .1)
				
				objectsInChunk.append(newTree)
			elif spawnVal <= physicsSpawnRate + treeSpawnRate:
				var newPhysics: Node3D = physicsObjects.pick_random().instantiate()
				get_parent().get_parent().add_child(newPhysics)
				newPhysics.global_position = Vector3((x), height + 1, (z))
				
				objectsInChunk.append(newPhysics)
	
	chunkDick[coord] = objectsInChunk


func deleteChunk(coord: Vector3i):
	print(chunkDick.get(coord))
	for obj in chunkDick.get(coord):
		obj.queue_free()
	chunkDick.erase(coord)
