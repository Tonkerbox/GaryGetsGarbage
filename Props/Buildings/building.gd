class_name building
extends StaticBody3D

#mostly handles spawning in and despawning trash cans

@export var trashCanScenes: Array[PackedScene]
@export var trashAmountRange: Vector2i
@export var trashRadMin: float

var trashCans: Array[trashRecipticle] = []

#runs on first instance of spawining in building (sets up trash in trash dict in prop handler)
func firstInstance():
	#figures out how to spawn trash and adds it to trash cans array (will be used later to add to trash dict)
	var trashAm: int = randi_range(trashAmountRange.x , trashAmountRange.y)
	for i in range(trashAm):
		var radius: float = randf_range(trashRadMin, 20)
		var pos: Vector2 = Vector2(radius * cos(randf_range(0, 2*PI)), radius * sin(randf_range(0, 2*PI)))
		var newCan: trashRecipticle = trashCanScenes.pick_random().instantiate()
		get_parent().add_child(newCan)
		newCan.global_position = Vector3(pos.x, 4, pos.y) + global_position
		newCan.global_rotation = Vector3(0, randf_range(0, 2*PI), 0)
		trashCans.append(newCan)

#for future me this is how the dictionary goes {Transform: [trashIndex, SpaceLeft, rotation]}
#if its not a trash can type then {Transform (like a barrel): [physicsIndex, -1, rotation]}
#runs after building has already been instanced
func instance(trashDic: Dictionary):
	#takes trash dic from building based on vector3 and spawns trash can according to data in dictionary
	for garbagePos: Vector3 in trashDic:
		var trashIndex: int = trashDic.get(garbagePos)[0]
		var trashSpace: float = trashDic.get(garbagePos)[1]
		var trashRot: Vector3 = trashDic.get(garbagePos)[2]
		var newCan: trashRecipticle = Global.trashCanArray[trashIndex].instantiate()
		get_parent().add_child(newCan)
		newCan.global_position = garbagePos
		newCan.global_rotation = trashRot
		newCan.capacity = trashSpace
		trashCans.append(newCan)

#takes individual cans from trash cans array and adds valuable data (capacity and transform) to that dictionary
#dictionary is based on garbage cans global position
func destroy() -> Dictionary:
	var trashDict: Dictionary
	for can in trashCans:
		trashDict[can.global_position] = [can.globalIndex, can.capacity, can.global_rotation]
		can.queue_free()
	return trashDict
