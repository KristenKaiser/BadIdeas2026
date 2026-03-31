extends Control
class_name UI

@export var metrics_card : MetricsReport


func _ready() -> void:
	Global.ui = self
	
func show_metrics_card():
	Global.healh_manager.is_health_tracking_paused = true
	metrics_card.show()
	metrics_card.fill_metrics_card()
