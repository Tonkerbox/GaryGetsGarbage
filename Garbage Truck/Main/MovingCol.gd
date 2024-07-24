extends Node3D

@export var colSize: int
@export var fidelity: float = 1
@export var onstart: bool = false

@onready var object: RigidBody3D = get_parent()
@onready var static1: StaticBody3D = $colBody
@onready var static2: StaticBody3D = $colBody2
@onready var colObj: CollisionShape3D = $colBody/col
@onready var colObj2: CollisionShape3D = $colBody2/col
@onready var colShape: ConcavePolygonShape3D = colObj.shape
@onready var colShape2: ConcavePolygonShape3D = colObj2.shape
@onready var planeInstance: MeshInstance3D = $plane
var planeMesh: PlaneMesh
var planeFaces: Array
var snap: Vector3
var firstCol: bool = true

func _ready():
	if onstart:
		await Global.groundVal.changed
	static1.top_level = true
	static2.top_level = true
	setUp()

func _physics_process(delta):
	var roundedPos = object.global_position.snapped(snap) * Vector3(1, 0, 1)
	if not global_position == roundedPos:
		global_position = roundedPos
		updateFaces()

func setUp():
	#print('set up')
	planeMesh = planeInstance.mesh
	planeMesh.size = Vector2(colSize, colSize)
	planeMesh.subdivide_depth = colSize*fidelity  - 1
	planeMesh.subdivide_width = colSize*fidelity  - 1
	#print(planeMesh)
	planeFaces = planeMesh.get_faces()
	snap = Vector3(1, 0, 1) * planeMesh.size.x * 60/64
	self.top_level = true
	updateFaces()

func updateFaces():
	for i in planeFaces.size():
		var globalVert = planeFaces[i] + global_position
		#i tried lol
		#var vertTween: Tween = get_tree().create_tween()
		#vertTween.tween_property(planeFaces[i], "position", Global.getHeight(globalVert.x, globalVert.z), .1)
		planeFaces[i].y = Global.getHeight(globalVert.x, globalVert.z)
	if firstCol:
		static1.global_position = global_position
		colShape.set_faces(planeFaces)
		firstCol = false
	elif not firstCol:
		static2.global_position = global_position
		colShape2.set_faces(planeFaces)
		firstCol = true
