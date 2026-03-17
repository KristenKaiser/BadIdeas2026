extends Node

@export var conveyer_speed: float =.1
var conveyer_speed_increase: float =.05
var slow_conveyer_speed: float =.1
var fast_conveyer_speed: float = 1
var box_drop_speed: float =.8
var grid_size : float  = .1 # 1.0/6.0
var base_boxes_per_day : int = 1 #7
var current_boxes_per_day : int 

const MERCH_MANAGER = preload("uid://cpxhjnah05wv6")
var merch_manager : MerchManager 

const CAMERA_MANAGER = preload("uid://w47oe1a1j5pu")
var camera_manager : CameraManager

const BOX_MANAGER = preload("uid://bo1cyd553pjcu")
var box_manager : BoxManager

const SCORE_MANAGER = preload("uid://7ho1x50016pi")
var score_manager : ScoreManager

var ui : UI

func _ready() -> void:
	current_boxes_per_day = base_boxes_per_day
	start_game()

func start_game():
	merch_manager = MERCH_MANAGER.instantiate()
	add_child(merch_manager)
	
	camera_manager = CAMERA_MANAGER.instantiate()
	add_child(camera_manager)
	
	box_manager = BOX_MANAGER.instantiate()
	add_child(box_manager)
	
	score_manager = SCORE_MANAGER.instantiate()
	add_child(score_manager)
	
	
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey:
			if OS.get_keycode_string(event.keycode) == "T" and event.pressed:
				conveyer_speed = fast_conveyer_speed
			if OS.get_keycode_string(event.keycode) == "T" and event.pressed == false:
				conveyer_speed = slow_conveyer_speed
			if OS.get_keycode_string(event.keycode) == "P" and event.pressed:
				if conveyer_speed == 0:
					conveyer_speed = slow_conveyer_speed
				else:
					conveyer_speed = 0
	
