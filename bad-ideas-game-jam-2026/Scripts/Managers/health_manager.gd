extends Node
class_name HealthManager

@export var thirst_timer : Timer
var max_thirst : int = 5 #60
var max_dehydration : int = 3 #30
var water_value : int = 25
var current_thirst : int
var current_dehydration : int = 0


#var pee_level : int
#var pee_max : int
### the number of bottles of water the pee meeter can hold 
#var bladder_multiplier : float = 2.25
#var bladder_fill_time : int
func _ready() -> void:
	current_thirst = max_thirst

func restart_thirst_timer(): 
	thirst_timer.stop()
	thirst_timer.wait_time = max_thirst
	thirst_timer.start()
	
func drink():
	var water : int = water_value
	current_dehydration -= water
	if current_dehydration < 0: 
		water = -current_dehydration
		current_dehydration = 0
	current_thirst += water
	if current_thirst > max_thirst: 
		current_thirst = max_thirst
	if Global.blur.visible == true and current_dehydration >= 0:
		Global.blur.hide()


func _on_thirst_timer_timeout() -> void:
	if current_thirst > 0:
		decrease_thirst()
	else: increase_dehydration()

func decrease_thirst():
	current_thirst -= 1
	Global.health_tv.update_value(current_thirst, max_thirst, Global.health_tv.Metric.THIRST)

func increase_dehydration():
	if Global.blur.is_blurred == false:
		Global.blur.transiton_in()
	current_dehydration += 1
	if current_dehydration > max_dehydration:
		pass_out()

func pass_out():
	Global.blur.fade_to_black()
	thirst_timer.stop()
	for box in Global.box_manager.boxes: 
		Global.score_manager.score_box(box)
		box.queue_free()
	var todays_missed_boxes = Global.current_boxes_per_day - Global.score_manager.count_boxes_sent_by_day.back()
	Global.score_manager.count_missed_boxes += todays_missed_boxes
	Global.score_manager.count_missed_boxes_by_day[Global.score_manager.count_missed_boxes_by_day.size() - 1] += todays_missed_boxes
	await get_tree().create_timer(1).timeout
	Global.ui.show_metrics_card()
	Global.blur.rect.material.set_shader_parameter("blur_strength", 0)
	Global.ui.metrics_card.writeup(Global.ui.metrics_card.Writeup.SLACKING)
	
