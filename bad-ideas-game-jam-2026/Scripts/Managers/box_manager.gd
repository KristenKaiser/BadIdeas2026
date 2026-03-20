extends Node
class_name BoxManager

var boxes : Array[Box]
var box_dropper : BoxDropper
@export var sizes : Dictionary [String, Vector3i]
var box_odds : Dictionary[String, float]
var box_empty_fill: Dictionary[String, int]
#@export var difficulties: Array[Difficulty]

func _ready() -> void:
	for size in sizes:
		box_odds[size] = 0
		var box_area : int = sizes[size].x * sizes[size].z
		box_empty_fill[size] = int(floor(box_area * .5))
		

func add_box(box : Box):
	boxes.append(box)
	if box.get_parent() != null:
		box.reparent(self)
	else:
		add_child(box)


func add_box_to_available():
	var largest_active_box : String = get_largest_active_box()
	var smallest_inactive_box : String = get_smallest_inactive_box()
	
	if largest_active_box == "": 
		box_odds[smallest_inactive_box] = 1
	else: 
		box_odds[smallest_inactive_box] = box_odds[largest_active_box] * 2

func get_smallest_inactive_box()-> String:
	var smallest_inactive_box : String = ""
	var smallest_inactive_box_area : int = -1 
	
	for box in box_odds: 
		if box_odds[box] == 0 :
			var temp_box_area : int = sizes[box].x * sizes[box].z
			
			if temp_box_area < smallest_inactive_box_area or smallest_inactive_box_area == -1:
				smallest_inactive_box = box
				smallest_inactive_box_area = temp_box_area
	return smallest_inactive_box
	
func get_largest_active_box()-> String:
	var largest_active_box : String = ""
	var largest_active_box_area : int = 0 
	
	for box in box_odds: 
		if box_odds[box] != 0 :
			var temp_box_area : int = sizes[box].x * sizes[box].z
			
			if temp_box_area > largest_active_box_area:
				largest_active_box = box
				largest_active_box_area = temp_box_area
	return largest_active_box
	
func decrease_empty_box_space(box : String) -> bool :
	if box_empty_fill[box] == 0 : return false
	else: 
		box_empty_fill[box] -= 1
		return true


func generate_box_sizes() -> Array:
	var largest_active_box : String = get_largest_active_box()
	var smallest_inactive_box : String = get_smallest_inactive_box()
	
	if largest_active_box == "": 
		add_box_to_available()
		return create_box_odds_array()
	if decrease_empty_box_space(largest_active_box) == false: 
		if smallest_inactive_box != "":
			add_box_to_available()
		else:
			pass
			## TODO increase conveyrer speed
	return create_box_odds_array()

func create_box_odds_array()->Array[String]:
	var box_array : Array[String]= []
	for item in box_odds: 
		for i in range(box_odds[item]):
			box_array.append(item)
	return box_array
	
	
func ship(box : Box):
	Global.score_manager.score_box(box)
	if Global.score_manager.count_boxes_sent % Global.current_boxes_per_day != 0:
		Global.box_manager.box_dropper.drop_box()
	
	await get_tree().create_timer(1).timeout
	for child in box.get_children():
		child.queue_free()
	box.queue_free()
	if (Global.score_manager.count_boxes_sent + Global.score_manager.count_missed_boxes) % Global.current_boxes_per_day == 0:
		Global.ui.show_metrics_card()
	
