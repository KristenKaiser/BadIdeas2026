extends Node3D
class_name MainScene
@export var main_camera : Camera3D

func _ready() -> void:
	Global.main_scene = self 
