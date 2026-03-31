extends CanvasLayer
class_name MetricsReport

@export var missing_items_label :Label
@export var incorrect_items_label :Label
@export var shipped_items_label :Label
@export var writeup_label : Label
@export var tape_label : Label
@export var address_label : Label
@export var missing_items_graph : ScoreGraph
@export var incorrect_items_graph : ScoreGraph
@export var mistakes_graph : ScoreGraph
@export var graphs : VBoxContainer
@export var report_control : Control 
@export var sub_window :  SubViewport
@export var burn_texture : TextureRect
var burn_duration : float = 4
var is_tutorial_day: bool = false

var missing_items_max_ratio : float = .25
var incorrect_items_max_ratio : float =.25
var bad_tape_max_rato : float = 1.0/Global.current_boxes_per_day
var no_address_max_rato : float = 1.0/Global.current_boxes_per_day
enum Writeup {SLACKING, URIN, DRINKING, PEEING, MISSING, INCORRECT, TAPE, ADDRESS}
var falloff :Dictionary[ Writeup, int ] = {Writeup.SLACKING : 6, Writeup.URIN: 4, Writeup.PEEING : 4, Writeup.MISSING : 6, Writeup.INCORRECT : 6, Writeup.TAPE : 6, Writeup.ADDRESS : 6}
var count_writeups : Dictionary[ Writeup, int ] =  {Writeup.SLACKING : 0, Writeup.URIN: 0, Writeup.PEEING : 0, Writeup.MISSING : 0, Writeup.INCORRECT : 0, Writeup.TAPE : 0, Writeup.ADDRESS : 0}
var writeups : Array[Array]
var is_fired : bool = false
var max_matching_writeups: int = 3
var max_total_writeups: int = 6


func _ready() -> void:
	init_todays_writeups()
	Global.mertics_report = self
	
func init_todays_writeups():
	var new_writeups : Array[Writeup] = []
	writeups.append(new_writeups)

func close_metrics_card():
	writeup_label.hide()
	self.hide()

func _on_continue_button_button_down() -> void:
	
	if is_fired and is_tutorial_day == false:
		burn()
	else:
		Global.score_manager.reset_todays_metrics()
		init_todays_writeups()
		close_metrics_card()
		Global.start_new_day()
	
	if is_tutorial_day: 
		is_tutorial_day = false
		writeups[0] = []

func fill_metrics_card(): 
	# play tutorial
	if Global.tutorial_manager.tutorial_status[TutorialManager.Tutorials.METRICS] == false:
				Global.tutorial_manager.display_overseer_text(Global.tutorial_manager.metrics, TutorialManager.Tutorials.METRICS)
				Global.tutorial_manager.end_tutorial()
	if get_incorrect_ratio(Global.score_manager.count_sent_items_by_day.size() - 1) > incorrect_items_max_ratio:
		writeup(Writeup.INCORRECT)
	if get_missing_ratio(Global.score_manager.count_sent_items_by_day.size() - 1) > missing_items_max_ratio:
		writeup(Writeup.MISSING)
	if get_bad_tape_ratio(Global.score_manager.count_sent_items_by_day.size() - 1)  > bad_tape_max_rato:
		writeup(Writeup.TAPE)
	if get_no_address_ratio(Global.score_manager.count_sent_items_by_day.size() - 1)  > no_address_max_rato:
		writeup(Writeup.ADDRESS)
	display_writeups()
	shipped_items_label.text = "Shipped Merchandise: %s units" %Global.score_manager.count_sent_items_by_day.back()
	missing_items_label.text = "Missing Merchandise: %s units" %Global.score_manager.count_missing_items_by_day.back()
	incorrect_items_label.text = "Incorrect Merchandise Shipped: %s units" %Global.score_manager.count_incorrect_items_by_day.back()
	tape_label.text = "Unacceptable Tape Applications: %s" %Global.score_manager.count_untaped_items_by_day.back()
	address_label.text = "Missing Shipping Labels: %s" %Global.score_manager.count_no_address_by_day.back()
	if Global.score_manager.count_incorrect_items_by_day.size() < 2:
		graphs.hide()
		return
	
	graphs.show()
	await get_tree().process_frame
	graphs.custom_minimum_size.y = floor(DisplayServer.window_get_size().y/2.0)

	var missing_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		missing_over_time.append(Vector2(day, get_missing_ratio(day)))
	print("\nmissing over time:")
	print(missing_over_time)
	missing_items_graph.update_graph(missing_over_time)
	
# incorrect items over / all shipped items  
	var incorrect_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		incorrect_over_time.append(Vector2(day, get_incorrect_ratio(day)))
	print("\nincorrect over time: %a")
	print(incorrect_over_time)
	
	incorrect_items_graph.update_graph(incorrect_over_time)
	
	var mistakes_over_time : Array[Vector2] = []
	var biggest_mistake_ratio : float = 0.0
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		var mistake_count = Global.score_manager.count_incorrect_items_by_day[day] + Global.score_manager.count_missing_items_by_day[day] 
		print("mistakes over_time = %s /%s + %s"%[float(mistake_count),float(Global.score_manager.count_sent_items_by_day[day]) ,float(Global.score_manager.count_missing_items_by_day[day])])
		mistakes_over_time.append(Vector2(day, float(mistake_count) / (float(Global.score_manager.count_sent_items_by_day[day] + float(Global.score_manager.count_missing_items_by_day[day])))))
		if mistakes_over_time.back().y > biggest_mistake_ratio : biggest_mistake_ratio = mistakes_over_time.back().y
	print("\nmistakes_over_time: %a")
	print(mistakes_over_time)
	if biggest_mistake_ratio > 1.0: 
		mistakes_graph.update_graph(mistakes_over_time, 0, floor(snapped(biggest_mistake_ratio, .1) * 10))
	else:
		mistakes_graph.update_graph(mistakes_over_time)

func get_incorrect_ratio(day : int)-> float:
	if Global.score_manager.count_sent_items_by_day[day] == 0 : 
		return 1.0 
	return float(Global.score_manager.count_incorrect_items_by_day[day])/float(Global.score_manager.count_sent_items_by_day[day])

func get_missing_ratio(day : int)-> float:
	var requested_items_count : float = float(Global.score_manager.count_sent_items_by_day[day] + Global.score_manager.count_missing_items_by_day[day] - Global.score_manager.count_incorrect_items_by_day[day])
	if requested_items_count == 0:
		return 1.0
	return float(Global.score_manager.count_missing_items_by_day[day])/ requested_items_count

func get_bad_tape_ratio(day : int)-> float:
	if Global.score_manager.count_boxes_sent_by_day[day] == 0 : 
		return 1.0 
	return Global.score_manager.count_untaped_items_by_day[day]/float(Global.score_manager.count_boxes_sent_by_day[day])

func get_no_address_ratio(day : int)-> float:
	if Global.score_manager.count_boxes_sent_by_day[day] == 0 : 
		return 1.0 
	return Global.score_manager.count_no_address_by_day[day]/float(Global.score_manager.count_boxes_sent_by_day[day])

func writeup(reason : Writeup):
	print("WRITEUP %s"% Writeup.find_key(reason))
	writeups[writeups.size() - 1].append(reason)

func display_writeups():
	reset_writeup_count()
	writeup_label.text = "TODAYS WRITEUP(S)"
	if writeups[writeups.size() - 1].is_empty():
		writeup_label.text += "\nNONE"
		#return
	writeup_label.show()
	for day in range(writeups.size() - 1, -1, -1):
		if day == writeups.size() - 2:
			writeup_label.text += "\n\nPREVIOUS WRITEUP(S)"
		for citation in range(writeups[day].size()):
			var days_to_falloff = get_days_to_falloff(day, writeups[day][citation])
			if days_to_falloff <= 0: 
				continue
			writeup_label.text +="\n"
			count_writeups[writeups[day][citation]] += 1
			match writeups[day][citation]:
				Writeup.SLACKING:
					writeup_label.text += "WRITEUP REASON - CONDUCT: FOUND SLEEPING/UNCONCIOUS ON THE JOB\n     Days until writeup attrits : "
				Writeup.URIN:
					writeup_label.text += "WRITEUP REASON - CONDUCT: SANITATION NON-COMPLIANCE : URIN FOUND ON CUBICAL FLOOR\n     Days until writeup attrits : " 
				Writeup.DRINKING: 
					writeup_label.text += "WRITEUP REASON - CONDUCT: HYDRATION WHILE ON COMPANY TIME\n     Days until writeup attrits : " 
				Writeup.PEEING: 
					writeup_label.text += "WRITEUP REASON - CONDUCT: URINATION WHILE ON COMPANY TIME\n     Days until writeup attrits : " 
				Writeup.MISSING:
					writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF ITEMS MISSING EXCEEDEDS MAXIMUM OF " + \
						str(int(missing_items_max_ratio * 100)) + "%\n     Days until writeup attrits : " 
				Writeup.INCORRECT:
					writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF INCORRECT ITEMS SHIPPED EXCEEDEDS MAXIMUM OF " +\
						str(int(incorrect_items_max_ratio * 100)) +"%\n     Days until writeup attrits : " 
				Writeup.TAPE:
					writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF UNACCEPTABLE TAPE APPLICATIONS EXCEEDEDS MAXIMUM OF ONE PER DAY\n     Days until writeup attrits : " 
				Writeup.ADDRESS:
					writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF MISSING ADDRESS LABELS EXCEEDEDS MAXIMUM OF ONE PER DAY\n     Days until writeup attrits : " 
			writeup_label.text += str(days_to_falloff)
	if get_is_fired(): 
		is_fired = true
		print("FIRED!!!")

func get_days_to_falloff(day: int, writeup_type: Writeup)-> int:
	var days_since_writeup = writeups.size() - 1 - day
	return falloff[writeup_type] - days_since_writeup
	
func reset_writeup_count():
	for key in count_writeups:
		count_writeups[key] = 0

func get_is_fired()-> bool:
	var count : int = 0 
	for key in count_writeups:
		if count_writeups[key] >= max_matching_writeups :
			return true
		count += count_writeups[key]
	if count >= max_total_writeups:
		return true
	return false
	
func burn():
	sub_window.size  = get_viewport().get_visible_rect().size
	report_control.reparent(sub_window)

	var tween = create_tween()
	tween.tween_property(burn_texture.material, "shader_parameter/burn_progress", 1.0, burn_duration)


func _on_pay_again_button_down() -> void:
	Global.restart_game()
