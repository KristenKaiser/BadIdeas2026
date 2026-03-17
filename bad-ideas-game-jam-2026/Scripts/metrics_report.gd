extends CanvasLayer
class_name MetricsReport

@export var missing_items_label :Label
@export var incorrect_items_label :Label
@export var shipped_items_label :Label
@export var missing_items_graph : ScoreGraph
@export var incorrect_items_graph : ScoreGraph
@export var mistakes_graph : ScoreGraph
@export var graphs : VBoxContainer


func close_metrics_card():
	self.hide()

func _on_continue_button_button_down() -> void:
	Global.score_manager.reset_todays_metrics()
	close_metrics_card()
	Global.box_manager.box_dropper.drop_box()


func fill_metrics_card(): 
	shipped_items_label.text = "Shipped Merchandise: %s units" %Global.score_manager.count_sent_items_by_day.back()
	missing_items_label.text = "Missing Merchandise: %s units" %Global.score_manager.count_missing_items_by_day.back()
	incorrect_items_label.text = "Incorrect Merchandise Shipped: %s units" %Global.score_manager.count_incorrect_items_by_day.back()
	if Global.score_manager.count_incorrect_items_by_day.size() < 2:
		graphs.hide()
		return

# missing items / total requested items 
	var missing_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		var requested_items_count : float = float(Global.score_manager.count_sent_items_by_day[day] + Global.score_manager.count_missing_items_by_day[day] - Global.score_manager.count_incorrect_items_by_day[day])
		missing_over_time.append(Vector2(day, float(Global.score_manager.count_missing_items_by_day[day])/ requested_items_count))
	print("\nmissing over time:")
	print(missing_over_time)
	missing_items_graph.update_graph(missing_over_time)
	
# incorrect items over / all shipped items  
	var incorrect_over_time: Array[Vector2] = []
	for day in range(Global.score_manager.count_sent_items_by_day.size()):
		incorrect_over_time.append(Vector2(day, float(Global.score_manager.count_incorrect_items_by_day[day])/float(Global.score_manager.count_sent_items_by_day[day])))
	print("\nincorrect over time: %a")
	print(incorrect_over_time)
	
	incorrect_items_graph.update_graph(incorrect_over_time)
	
	# (missing items + incorrect items) / (missing items + incorrect items + correct items)
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
		
