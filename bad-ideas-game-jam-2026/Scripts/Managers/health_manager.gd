extends Node
class_name HealthManager

var disable_hydration_testing : bool = false


@export var hydration_timer : Timer
var max_hydration : int = 60
var max_dehydration : int = 30
var water_value : int = 25
var current_hydration : int
var current_dehydration : int = 0

var pee_escrow : int = 0
var pee_transfer_rate : int = 2

var pee_level : int

### the number of bottles of water the pee meeter can hold 
var bladder_multiplier : float = 2.25


func _ready() -> void:
	if disable_hydration_testing: 
		hydration_timer.stop()
	current_hydration = max_hydration

func restart_hydration_timer(): 
	hydration_timer.stop()
	hydration_timer.wait_time = max_hydration
	hydration_timer.start()
	
func drink():
	var water : int = water_value
	current_dehydration -= water
	if current_dehydration <  0 : 
		water = -current_dehydration
		current_dehydration = 0
	current_hydration += water
	if current_hydration > max_hydration: 
		water = current_hydration - max_hydration
		current_hydration = max_hydration
	else: water = 0
	if Global.blur.is_blurred == true and current_dehydration >= 0:
		Global.blur.transition_out()
	pee_escrow += water_value - water


func _on_hydration_timer_timeout() -> void:
	if current_hydration > 0:
		decrease_hydration()
	else: increase_dehydration()
	if pee_escrow > 0:
		convert_water_to_pee()

func decrease_hydration():
	current_hydration -= 1
	Global.health_tv.update_value(current_hydration, max_hydration, Global.health_tv.Metric.THIRST)

func increase_dehydration():
	if Global.blur.is_blurred == false:
		Global.blur.transiton_in()
	current_dehydration += 1
	if current_dehydration > max_dehydration:
		pass_out()

func pass_out():
	Global.blur.fade_to_black()
	hydration_timer.stop()
	for box in Global.box_manager.boxes: 
		Global.score_manager.score_box(box)
		box.queue_free()
	var todays_missed_boxes = Global.current_boxes_per_day - Global.score_manager.count_boxes_sent_by_day.back()
	Global.score_manager.count_missed_boxes += todays_missed_boxes
	Global.score_manager.count_missed_boxes_by_day[Global.score_manager.count_missed_boxes_by_day.size() - 1] += todays_missed_boxes
	await get_tree().create_timer(1).timeout
	Global.ui.metrics_card.writeup(Global.ui.metrics_card.Writeup.SLACKING)
	Global.ui.show_metrics_card()
	Global.blur.rect.material.set_shader_parameter("blur_strength", 0)
	

func convert_water_to_pee():
	if pee_escrow < pee_transfer_rate:
		pee_level += pee_escrow
		pee_escrow = 0
	else: 
		pee_level += pee_transfer_rate
		pee_escrow -= pee_transfer_rate
	Global.health_tv.update_value(pee_level, ceil(water_value  * bladder_multiplier), Global.health_tv.Metric.PEE)
	#check for too much pee
	if pee_level > water_value * bladder_multiplier: 
		wet_self()
	
func pee():
	pee_level -= water_value
	if pee_level < 0: 
		pee_level = 0 
	Global.health_tv.update_value(pee_level, ceil(water_value  * bladder_multiplier), Global.health_tv.Metric.PEE)

func wet_self():
	pee_level = 0
	pee_escrow = 0
	Global.ui.metrics_card.writeup(Global.ui.metrics_card.Writeup.URIN)
