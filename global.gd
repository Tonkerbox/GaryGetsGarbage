extends Node

@onready var groundVal: NoiseTexture2D = preload("res://WorldStuff/Shaders/HeightMap.tres")
@onready var amplitude: float = ProjectSettings.get_setting("shader_globals/amplitude").value
var groundTex: Image

func _ready():
	#sets up ground stuff
	await groundVal.changed
	print(amplitude)
	groundTex = groundVal.get_image()

func getHeight(x, z):
	return groundTex.get_pixel(fposmod(x, groundTex.get_width()), fposmod(z, groundTex.get_height())).r * amplitude
