extends Screen
class_name HealthScreen
@export var thisrt_label :Label
@export var pee_label :Label
enum Metric {THIRST, PEE}

func _ready() -> void:
	Global.health_tv = self
	Global.tv_manager.health_tv = parent_tv


func update_value(value: int, max_val : int, metric : Metric):
	match metric:
		Metric.THIRST:
			thisrt_label.text = "Thirst Level : %s / %s"%[value, max_val] 
		Metric.PEE:
			pee_label.text = "Pee Level: %s / %s"%[value, max_val] 
	
