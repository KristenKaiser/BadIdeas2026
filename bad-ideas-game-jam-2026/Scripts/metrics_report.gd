extends CanvasLayer
class_name MetricsReport

@export var missing_items_label :Label
@export var incorrect_items_label :Label
@export var shipped_items_label :Label
@export var writeup_label : Label
@export var missing_items_graph : ScoreGraph
@export var incorrect_items_graph : ScoreGraph
@export var mistakes_graph : ScoreGraph
@export var graphs : VBoxContainer

var missing_items_max_ratio : float = .25
var incorrect_items_max_ratio : float =.25
enum Writeup {SLACKING, URIN, DRINKING, PEEING, MISSING, INCORRECT}
var writeups : Array[Array]


func _ready() -> void:
	init_todays_writeups()
	
func init_todays_writeups():
	var new_writeups : Array[Writeup] = []
	writeups.append(new_writeups)

func close_metrics_card():
	writeup_label.hide()
	self.hide()

func _on_continue_button_button_down() -> void:
	Global.score_manager.reset_todays_metrics()
	init_todays_writeups()
	close_metrics_card()

func fill_metrics_card(): 
	if get_incorrect_ratio(Global.score_manager.count_sent_items_by_day.size() - 1) > incorrect_items_max_ratio:
		writeup(Writeup.INCORRECT)
	if get_missing_ratio(Global.score_manager.count_sent_items_by_day.size() - 1) > missing_items_max_ratio:
		writeup(Writeup.MISSING)
	display_writeups()
	shipped_items_label.text = "Shipped Merchandise: %s units" %Global.score_manager.count_sent_items_by_day.back()
	missing_items_label.text = "Missing Merchandise: %s units" %Global.score_manager.count_missing_items_by_day.back()
	incorrect_items_label.text = "Incorrect Merchandise Shipped: %s units" %Global.score_manager.count_incorrect_items_by_day.back()
	if Global.score_manager.count_incorrect_items_by_day.size() < 2:
		graphs.hide()
		return

	var missing_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		missing_over_time.append(Vector2(day, get_missing_ratio(day)))
		#var requested_items_count : float = float(Global.score_manager.count_sent_items_by_day[day] + Global.score_manager.count_missing_items_by_day[day] - Global.score_manager.count_incorrect_items_by_day[day])
		#missing_over_time.append(Vector2(day, float(Global.score_manager.count_missing_items_by_day[day])/ requested_items_count))
	print("\nmissing over time:")
	print(missing_over_time)
	missing_items_graph.update_graph(missing_over_time)
	
# incorrect items over / all shipped items  
	var incorrect_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		incorrect_over_time.append(Vector2(day, get_incorrect_ratio(day)))
		#incorrect_over_time.append(Vector2(day, float(Global.score_manager.count_incorrect_items_by_day[day])/float(Global.score_manager.count_sent_items_by_day[day])))
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
	return float(Global.score_manager.count_incorrect_items_by_day[day])/float(Global.score_manager.count_sent_items_by_day[day])

func get_missing_ratio(day : int)-> float:
	var requested_items_count : float = float(Global.score_manager.count_sent_items_by_day[day] + Global.score_manager.count_missing_items_by_day[day] - Global.score_manager.count_incorrect_items_by_day[day])
	return float(Global.score_manager.count_missing_items_by_day[day])/ requested_items_count
	

func writeup(reason : Writeup):
	print("WRITEUP %s"% Writeup.find_key(reason))
	writeups[writeups.size() - 1].append(reason)

func display_writeups():
	if writeups[writeups.size() - 1].is_empty():
		return
	writeup_label.show()
	for citation in range(writeups[writeups.size() - 1].size()):
		writeup_label.text +="\n"
		match writeups[writeups.size() - 1][citation]:
			Writeup.SLACKING:
				writeup_label.text += "WRITEUP REASON - FOUND SLACKING ON THE JOB"
			Writeup.URIN:
				writeup_label.text += "WRITEUP REASON - SANITATION NON-COMPLIANCE"
			Writeup.DRINKING: 
				writeup_label.text += "WRITEUP REASON - HYDRATION WHILE ON COMPANY TIME"
			Writeup.PEEING: 
				writeup_label.text += "WRITEUP REASON - URINATION WHILE ON COMPANY TIME"
			Writeup.MISSING:
				writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF ITEMS MISSING EXCEEDEDS MAXIMUM OF " + str(int(missing_items_max_ratio * 100)) + "%"
			Writeup.INCORRECT:
				writeup_label.text += "WRITEUP REASON - PREFORMANCE : TODAY'S NUMBER OF INCORRECT ITEMS SHIPPED EXCEEDEDS MAXIMUM OF " + str(int(incorrect_items_max_ratio * 100)) +"%"
