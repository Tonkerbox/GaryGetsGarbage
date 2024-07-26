class_name propHandler
extends Node

#handles spawning and despawning buildings and trees (static objects)
#buildings are responsible over their own trash objects
#other "spawners" are considered building and will also be responsible

@export var chunkSize: int = 100
@export var chunkFrames: int = 10
@export var trees: Array[PackedScene]
@export var buildings: Array[PackedScene]
@export var player: RigidTruck
@export var treeFreq: Vector2i 
@export var buildFreq: Vector2i

var playerChunk: Vector3 = Vector3.ZERO
var currentChunkPos: Vector3i
var currentChunkCoords: Array[Vector2i]
var currentBuildingCoords: Array[Vector2i]
var generatedChunks: Dictionary
var chunkSnap: Vector3i
var chunkDict: Dictionary
var buildingDic: Dictionary

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
	var buildAm: int = rand.randi_range(buildFreq.x, buildFreq.y)
	
	currentBuildingCoords = []
	spawnBuildings(buildAm, rand, worldPos)
	spawnTrees(trees, treeAm, rand, worldPos)

#spawns buildings
func spawnBuildings(amount: int, rand: RandomNumberGenerator, worldPos: Vector2i):
	var takenPos: Array[Vector2i] = []
	var buildingsInChunk: Array[StaticBody3D] = []
	
	while amount > 0:
		#if building is in a certain distance of another building it wont spawn and will rerun while loop while not taking down amoumnt
		var canSpawn: bool = true
		var xPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var yPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var pos: Vector2i = Vector2i(xPos, yPos) + worldPos
		
		#checks if building has already been spawned based off of a previous pos
		if not buildingDic.has(pos):
			#if not makes sure building isnt conflicting with other buildings
			for buildPos in currentBuildingCoords:
				if (abs(buildPos.x - pos.x) < 20) or (abs(buildPos.y - pos.y) < 20):
					canSpawn = false
			
			#if not conflicting spawns buildings first instance and adds it to buildings in chunk
			if canSpawn:
				var newBuilding: building = createObject(buildings[rand.randi_range(0, buildings.size() - 1)], pos, rand)
				currentBuildingCoords.append(pos)
				buildingsInChunk.append(newBuilding)
				amount -= 1
				newBuilding.firstInstance() #heres the first instance building
		else:
			#if building has already spawned 
			var newBuilding: building = createObject(buildings[rand.randi_range(0, buildings.size() - 1)], pos, rand)
			currentBuildingCoords.append(pos)
			buildingsInChunk.append(newBuilding)
			amount -= 1
			newBuilding.instance(buildingDic.get(pos)) #spawns new building and passes it its dictionary containing its garbage information
	
	#adds building and worldpos to regular chunkdict (non permanent)
	if not chunkDict.has(worldPos):
		chunkDict[worldPos] = buildingsInChunk
	else:
		chunkDict[worldPos] += buildingsInChunk


func spawnTrees(group: Array[PackedScene], amount: int, rand: RandomNumberGenerator, worldPos: Vector2i):
	var takenPos: Array[Vector2i] = []
	var objectsInChunk: Array[StaticBody3D] = []
	while amount > 0:
		var xPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var yPos: float = rand.randi_range(-chunkSize/2, chunkSize/2)
		var pos: Vector2i = Vector2i(xPos, yPos) + Vector2i(worldPos.x, worldPos.y)
		#print(pos)
		
		if not pos in takenPos:
			takenPos.append(pos)
			objectsInChunk.append(createObject(group[rand.randi_range(0, group.size() - 1)], pos, rand))
			amount -= 1
	
	chunkDict[worldPos] += objectsInChunk

#default spawning for all static objects
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
	#if its a building it will store the buildings trahs information in a dictionary based off of its int pos
	#obj.destory() is calling the building to destroy its trash and add the trashs information to the building dict
	for obj in chunkDict.get(coord):
		if obj.is_in_group('building'):
			buildingDic[Vector2i(obj.global_position.x, obj.global_position.z)] = obj.destroy()
			obj.queue_free()
		else:
			obj.queue_free()
	chunkDict.erase(coord)
