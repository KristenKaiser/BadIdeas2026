extends Node
class_name ScoreManager

var count_boxes_sent : int = 0 
var count_missing_items : int = 0 
var count_sent_items : int = 0 
var count_untaped : int = 0
var count_incorrect_items : int = 0 
var count_no_address : int = 0
var count_missed_boxes : int = 0
var count_boxes_sent_by_day : Array[int]
var count_missing_items_by_day : Array[int]
var count_sent_items_by_day : Array[int]
var count_incorrect_items_by_day : Array[int]
var count_untaped_items_by_day : Array[int]
var count_no_address_by_day: Array[int] 
var count_missed_boxes_by_day : Array[int]



func _ready() -> void:
	reset_todays_metrics()
	
func reset_todays_metrics():
	count_boxes_sent_by_day.append(0)
	count_incorrect_items_by_day.append(0)
	count_missing_items_by_day.append(0)
	count_sent_items_by_day.append(0)
	count_untaped_items_by_day.append(0)
	count_no_address_by_day.append(0)
	count_missed_boxes_by_day.append(0)
	
	

func score_box(box : Box):
	var requested_items : Dictionary[String , int] = box.order_form.requested_items.duplicate()
	var sent_items : Dictionary[String , int] = box.held_objects.duplicate()
	count_boxes_sent += 1
	count_boxes_sent_by_day[count_boxes_sent_by_day.size() - 1] += 1
	for request in requested_items:
		if sent_items.has(request):
			count_sent_items += sent_items[request]
			count_sent_items_by_day[count_sent_items_by_day.size() - 1] += sent_items[request]
			var missing_items = requested_items[request] - sent_items[request]
			if missing_items < 0:
				count_incorrect_items += abs(missing_items)
				count_incorrect_items_by_day[count_incorrect_items_by_day.size() - 1] += abs(missing_items)
			else: 
				count_missing_items += missing_items
				count_missing_items_by_day[count_missing_items_by_day.size() - 1] += missing_items
		else: 
			count_missing_items += requested_items[request]
			count_missing_items_by_day[count_missing_items_by_day.size() - 1] += requested_items[request]
		sent_items.erase(request)
	for item in sent_items:
		count_sent_items += sent_items[item]
		count_sent_items_by_day[count_sent_items_by_day.size() - 1] += sent_items[item]
		count_incorrect_items += sent_items[item]
		count_incorrect_items_by_day[count_incorrect_items_by_day.size() - 1] += sent_items[item]
	if box.is_taped == false: 
		count_untaped += 1
		count_untaped_items_by_day[count_untaped_items_by_day.size() - 1] += 1
	if box.is_addressed == false: 
		count_no_address += 1
		count_no_address_by_day[count_untaped_items_by_day.size() - 1] += 1
	
	Global.metrics_tv.update_value(count_boxes_sent, Global.metrics_tv.Metric.BOXES)
	Global.metrics_tv.update_value(count_missing_items, Global.metrics_tv.Metric.MISSING)
	Global.metrics_tv.update_value(count_incorrect_items, Global.metrics_tv.Metric.WRONG)
	Global.box_manager.boxes.erase(box)
func end_round():
	reset_todays_metrics()
	

	
