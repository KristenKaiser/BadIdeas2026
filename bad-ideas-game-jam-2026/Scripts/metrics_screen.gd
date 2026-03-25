extends Screen
class_name MetricsScreen
@export var boxes_sent_label : Label
@export var missing_item_label : Label
@export var wrong_item_label : Label
enum Metric {BOXES, MISSING, WRONG}

func _ready() -> void:
	Global.metrics_tv = self
	Global.tv_manager.metrics_tv = parent_tv


func update_value(value: int, metric : Metric):
	match metric:
		Metric.BOXES:
			boxes_sent_label.text = "Boxes Sent : %s"%value 
		Metric.MISSING:
			missing_item_label.text = "Missing Items: %s"%value 
		Metric.WRONG:
			wrong_item_label.text = "Wrong Items: %s"%value 
 
