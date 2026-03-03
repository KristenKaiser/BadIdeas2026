extends Node

const MERCH_MANAGER = preload("uid://cpxhjnah05wv6")
var merch_manager : MerchManager 

const CAMERA_MANAGER = preload("uid://w47oe1a1j5pu")
var camera_manager : CameraManager


func _ready() -> void:
	start_game()

func start_game():
	merch_manager = MERCH_MANAGER.instantiate()
	add_child(merch_manager)
	
	camera_manager = CAMERA_MANAGER.instantiate()
	add_child(camera_manager)
	
	
	
