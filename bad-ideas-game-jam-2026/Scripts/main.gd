extends Node3D
@export var main_camera : Camera3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_camera.current = true
