class_name propHandler
extends Node

@export var chunkSize: int = 100
@export var chunkFrames: int = 10
@export var trees: Array[PackedScene]
@export var player: RigidTruck
@export var treeFreq: Vector2i 

var playerChunk: Vector3 = Vector3.ZERO
var currentChunkPos: Vector3i
var currentChunkCoords: Array[Vector2i]
var chunkSnap: Vector3i
var chunkDict: Dictionary

func _ready():
	await Global.groundVal.changed
	chunkSnap = Vector3i(chunkSize, 0, chunkSize)
	GenerateChunks()

func _physics_process(delta):
	if not Vector3i(player.global_position.snapped(chunkSnap) * Vector3(1, 0, 1)) == currentChunkPos:
		GenerateChunks()

func GenerateChunks():
	currentChunkPos = player.global_position.snapped(chunkSnap) * Vector3(1, 0, 1)
	var newChunks: Array[Vector2i] = []
	var oldChunks: Array[Vector2i] = currentChunkCoords
	#print('Current Chunk Pos:', currentChunkPos)
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			#print('appened chunk', Vector2i(x,y) + Vector2i(currentChunkPos.x, currentChunkPos.z))
			newChunks.append(Vector2i(x, y) * chunkSize + Vector2i(currentChunkPos.x, currentChunkPos.z))
	
	for chunkPos in newChunks:
		if not chunkPos in currentChunkCoords:
				GenerateChunk(chunkPos)
	
	for chunkPos in oldChunks:
		if not chunkPos in newChunks:
			despawnChunk(chunkPos)
	
	currentChunkCoords = newChunks

func GenerateChunk(chunkPos):
	#print('generated chunk:', chunkPos)
	var worldPos: Vector2i = chunkPos
	var rand: RandomNumberGenerator = RandomNumberGenerator.new()
	var height: float = Global.getHeight((worldPos.x), (worldPos.y))
	var objects: Array[Node3D] = []
	var x = worldPos.x
	var z = worldPos.y
	rand.seed = height * x/z + x * z - height + 69 * height + 420 * height * x / (z + 69) + 42069 / (z + 420)
	
	var treeAm: int = rand.randi_range(treeFreq.x, treeFreq.y)
	
	spawnGroup(trees, treeAm, rand, height, worldPos)

func spawnGroup(group: Array[PackedScene], amount: int, rand: RandomNumberGenerator, height: float, worldPos: Vector2i):
	var takenPos: Array[Vector2i] = []
	var objectsInChunk: Array[Node3D] = []
	while amount > 0:
		var xPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var yPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var pos: Vector2i = Vector2i(xPos, yPos) + Vector2i(worldPos.x, worldPos.y)
		#print(pos)
		
		if not pos in takenPos:
			takenPos.append(pos)
			objectsInChunk.append(createObject(group[rand.randi_range(0, group.size() - 1)], pos, rand))
			amount -= 1
	
	chunkDict[worldPos] = objectsInChunk


func createObject(object: PackedScene, pos: Vector2i, rand: RandomNumberGenerator) -> Node3D:
	var height: float = Global.getHeight(pos.x, pos.y)
	var newObject: Node3D = object.instantiate()
	get_parent().add_child(newObject)
	newObject.global_position = Vector3(pos.x, height, pos.y)
	newObject.global_rotation.y = rand.randf_range(0, 360)
	newObject.global_rotation.z = rand.randf_range(-.1, .1)
	newObject.global_rotation.x = rand.randf_range(-.1, .1)
	
	return newObject

func despawnChunk(coord):
	#print('Despawning chunk:')
	#print(chunkDict.get(coord))
	for obj in chunkDict.get(coord):
		obj.queue_free()
	chunkDict.erase(coord)
